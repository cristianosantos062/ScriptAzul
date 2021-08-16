/* MOSTRA PROCESSOS EM EXECUÇÃO - INCLUI SESSÕES COM TRANSACOES ABERTAS SEM REQUESTS ASSOCIADOS */
SELECT SS.session_id [spid],
       RQ.blocking_session_id [blocked_by],
       BL.blocking, -- Lista de sessões bloqueadas
       --RQ.dop,
       RQ.cpu_time,
       RQ.reads physical_reads,
       RQ.writes physical_writes,
       DB_NAME(RQ.database_id) AS [db_name],
       RQ.status,
       RQ.start_time, --, SS.login_time
       DATEDIFF(SECOND, RQ.start_time, getdate()) elapsed_time_sec,
       RQ.wait_type,
       RQ.wait_resource,
       RQ.wait_time, --, RQ.percent_complete
       RQ.command [cmd],
       SUBSTRING(st.TEXT, (rq.statement_start_offset/2)+1, ((CASE rq.statement_end_offset
                                                                 WHEN -1 THEN DATALENGTH(st.TEXT)
                                                                 ELSE rq.statement_end_offset
                                                             END - rq.statement_start_offset)/2)+1) [statement_text],
       ST.text [complete_text],
       SS.login_name,
       SS. host_name,
       SS.program_name,
       CASE
           WHEN RQ.request_id IS NOT NULL THEN 'Request Opened'
           WHEN RQ.request_id IS NULL
                AND SS.open_transaction_count > 0 THEN 'No Request Opened BUT Opened Tran'
           ELSE '-'
       END [request_status],
       QP.QUERY_PLAN
FROM sys.dm_exec_sessions SS
INNER JOIN sys.dm_exec_connections CO ON SS.session_id = CO.session_id -- EXCLUDE INTERNAL SESSIONS
LEFT OUTER JOIN sys.dm_exec_requests RQ ON SS.session_id = RQ.session_id
LEFT OUTER JOIN
  (SELECT DISTINCT blocking_session_id [session_id],
                   STUFF(
                           (SELECT ', ' + CAST(R2.session_id AS varchar(32))
                            FROM sys.dm_exec_requests R2
                            WHERE R1.blocking_session_id = R2.blocking_session_id
                              FOR XML PATH('')), 1, 2, '') [blocking]
   FROM sys.dm_exec_requests R1
   WHERE blocking_session_id > 0) BL ON SS.session_id = BL.session_id OUTER APPLY sys.dm_exec_sql_text(RQ.SQL_HANDLE) AS ST OUTER APPLY sys.dm_exec_query_plan(RQ.PLAN_HANDLE) AS QP
WHERE SS.session_id > 50
  AND SS.session_id <> @@spid
  AND (RQ.request_id IS NOT NULL
       OR (RQ.request_id IS NULL
           AND SS.open_transaction_count > 0))
ORDER BY RQ.cpu_time DESC -- Ordenado pelo maior consumidor de CPU

-- Query Store
SELECT
[qp].[plan_id],
[q].[query_id],
[qp].[is_forced_plan],
[qp].[count_compiles],
[rs].[execution_type_desc],
COALESCE(object_name([q].object_id), '-') [object_name],
[qt].[query_sql_text],
CONVERT(varchar(23), DATEADD(HOUR, -3, [rs].[last_execution_time]), 121) AS [last_execution_time_BRT],
[rs].[count_executions],
CAST([rs].[avg_duration]/1000000.00 AS DECIMAL(32,3)) AS [avg_duration_sec],
CAST([rs].[max_duration]/1000000.00 AS DECIMAL(32,3)) AS [max_duration_sec],
CAST(([rs].[avg_duration]*[rs].[count_executions])/1000000.00 AS DECIMAL(32,3)) AS [total_duration_sec],
CAST([rs].[avg_rowcount] AS DECIMAL(32,3)) AS [avg_rowcount],
[rs].[max_rowcount],
[ws].[wait_category_desc],
CAST([ws].[avg_query_wait_time_ms]/1000.00 AS DECIMAL(32,3)) [avg_wait_time_sec],
CAST([ws].[total_query_wait_time_ms]/1000.00 AS DECIMAL(32,3)) [total_wait_time_sec],
CAST(([ws].[total_query_wait_time_ms]/1000.00) / (([rs].[avg_duration]*[rs].[count_executions])/1000000.00) AS DECIMAL(32,2)) [total_wait_pct],
CONVERT(varchar(32), [rsi].[runtime_stats_interval_id]) + ' - ' +
CONVERT(varchar(16), DATEADD(HOUR, -3, [rsi].[start_time]), 121) + ' - ' +
CONVERT(varchar(16), DATEADD(HOUR, -3, [rsi].[end_time]), 121) AS [bucket_interval_BRT],
CAST(qp.query_plan as XML)
FROM [sys].[query_store_query] [q]
LEFT OUTER JOIN [sys].[query_store_query_text] [qt]
ON [qt].[query_text_id] = [q].[query_text_id]
LEFT OUTER JOIN [sys].[query_store_plan] [qp]
ON [q].[query_id] = [qp].[query_id]
LEFT OUTER JOIN [sys].[query_store_runtime_stats] [rs]
ON [qp].[plan_id] = [rs].[plan_id]
LEFT OUTER JOIN [sys].[query_store_runtime_stats_interval] [rsi]
ON [rs].[runtime_stats_interval_id] = [rsi].[runtime_stats_interval_id]
LEFT OUTER JOIN [sys].[query_store_wait_stats] [ws]
ON [ws].[runtime_stats_interval_id] = [rs].[runtime_stats_interval_id]
AND [ws].[plan_id] = [qp].[plan_id]
WHERE 1=1
---AND DATEADD(HOUR, -3, [rsi].[start_time]) BETWEEN '2021-07-15 10:00:00.000' AND '2021-07-15 14:59:59.999' -- By Bucket Interval Start Time
AND DATEADD(HOUR, -3, [rsi].[start_time]) > '2021-07-15 14:05:23.767' 
--AND [rs].[execution_type_desc] = 'Aborted'
AND [qt].[query_sql_text] LIKE '%EVENTO%'
ORDER BY DATEADD(HOUR, -3, [rsi].[start_time]), DATEADD(HOUR, -3, [rs].[last_execution_time])

SELECT * FROM [sys].[query_store_plan] [qp] WHERE query_id = 563044

SELECT
[qp].[plan_id],
[q].[query_id],[q].[last_compile_batch_sql_handle],
[qp].[is_forced_plan],
[qp].[count_compiles],
[rs].[execution_type_desc],
COALESCE(object_name([q].object_id), '-') [object_name],
[qt].[query_sql_text],
CONVERT(varchar(23), DATEADD(HOUR, -3, [rs].[last_execution_time]), 121) AS [last_execution_time_BRT],
[rs].[count_executions],
CAST([rs].[avg_duration]/1000000.00 AS DECIMAL(32,3)) AS [avg_duration_sec],
CAST([rs].[max_duration]/1000000.00 AS DECIMAL(32,3)) AS [max_duration_sec],
CAST(([rs].[avg_duration]*[rs].[count_executions])/1000000.00 AS DECIMAL(32,3)) AS [total_duration_sec],
CAST([rs].[avg_rowcount] AS DECIMAL(32,3)) AS [avg_rowcount],
[rs].[max_rowcount],
[ws].[wait_category_desc],
CAST([ws].[avg_query_wait_time_ms]/1000.00 AS DECIMAL(32,3)) [avg_wait_time_sec],
CAST([ws].[total_query_wait_time_ms]/1000.00 AS DECIMAL(32,3)) [total_wait_time_sec],
CAST(([ws].[total_query_wait_time_ms]/1000.00) / (([rs].[avg_duration]*[rs].[count_executions])/1000000.00) AS DECIMAL(32,2)) [total_wait_pct],
CONVERT(varchar(32), [rsi].[runtime_stats_interval_id]) + ' - ' +
CONVERT(varchar(16), DATEADD(HOUR, -3, [rsi].[start_time]), 121) + ' - ' +
CONVERT(varchar(16), DATEADD(HOUR, -3, [rsi].[end_time]), 121) AS [bucket_interval_BRT],
CAST(qp.query_plan as XML)
FROM [sys].[query_store_query] [q]
LEFT OUTER JOIN [sys].[query_store_query_text] [qt]
ON [qt].[query_text_id] = [q].[query_text_id]
LEFT OUTER JOIN [sys].[query_store_plan] [qp]
ON [q].[query_id] = [qp].[query_id]
LEFT OUTER JOIN [sys].[query_store_runtime_stats] [rs]
ON [qp].[plan_id] = [rs].[plan_id]
LEFT OUTER JOIN [sys].[query_store_runtime_stats_interval] [rsi]
ON [rs].[runtime_stats_interval_id] = [rsi].[runtime_stats_interval_id]
LEFT OUTER JOIN [sys].[query_store_wait_stats] [ws]
ON [ws].[runtime_stats_interval_id] = [rs].[runtime_stats_interval_id]
AND [ws].[plan_id] = [qp].[plan_id]
WHERE 1=1

AND [q].[query_id] = 563044
---AND DATEADD(HOUR, -3, [rsi].[start_time]) BETWEEN '2021-07-15 10:00:00.000' AND '2021-07-15 14:59:59.999' -- By Bucket Interval Start Time
AND DATEADD(HOUR, -3, [rsi].[start_time]) > '2021-07-15 09:00:00.000' 

AND [rs].[execution_type_desc] = 'Aborted'
AND [qt].[query_sql_text] LIKE '%EVENTO%'
ORDER BY DATEADD(HOUR, -3, [rsi].[start_time]), DATEADD(HOUR, -3, [rs].[last_execution_time])