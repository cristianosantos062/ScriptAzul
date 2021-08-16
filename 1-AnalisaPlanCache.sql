/*
	  SELECT
    'GuardAppEvent:Start',
    'GuardAppEventType:METADADOS',
    'GuardAppEventStrValue:METADADOS';

    GO
    SELECT
    'GuardAppEvent:Released';
*/

DECLARE @banco SYSNAME = 'CS'
		,@proc SYSNAME = N'SPCS_PR_GERA_ARQ_CSGJ'

/*
select TOP 100 cp.plan_handle,qp.objectid, qp.query_plan, OBJECT_NAME(qp.objectid) as name from sys.dm_exec_cached_plans cp
CROSS APPLY SYS.dm_exec_query_plan(cp.plan_handle) qp
--WHERE qp.objectid = 775934086 and qp.dbid = DB_ID('SI_DW')
WHERE qp.dbid = DB_ID('SI_DW')
*/
--sp_helptext 'SON6_RVDER.SP_ON6_SEL_LANC_LIQU_FINN'
/*Pega os parametros do chache das procedures*/
SELECT top 1 object_name(objectid,dbid)obj, qp.query_plan, cp.plan_handle, qs.last_execution_time
INTO #t
FROM SYS.dm_exec_cached_plans cp
CROSS APPLY SYS.dm_exec_query_plan(cp.plan_handle) qp
left join sys.dm_exec_query_stats qs on qs.plan_handle = cp.plan_handle 
--WHERE qp.objectid = OBJECT_ID('SPU_INS_XBPLC_POSICAO_ALUGUEL') AND dbid = (select database_id from sys.databases where name = 'SI_DW')
WHERE qp.objectid = (SELECT object_id FROM sys.objects where type = 'P' AND name = @proc) 
	AND dbid = (select database_id from sys.databases where name = @banco)

SELECT obj, plan_handle, query_plan,last_execution_time FROM #t;
WITH XMLNAMESPACES  (DEFAULT 'http://schemas.microsoft.com/sqlserver/2004/07/showplan') 
SELECT DISTINCT 
     n2.value('(@Column)[1]','sysname') AS ParameterName 
    ,n2.value('(@ParameterCompiledValue)[1]','varchar(max)') AS ParameterValue 
       ,last_execution_time
FROM #t  
    CROSS APPLY query_plan.nodes('//ParameterList') AS q1(n1) 
    CROSS APPLY n1.nodes('ColumnReference') as q2(n2)
 

-- Passo 2. Inclui o handle  (parte amarela)

select statement_start_offset, statement_end_offset, command = SUBSTRING (txt.text, q.statement_start_offset/2, 
(CASE WHEN q.statement_end_offset = -1
        THEN LEN(CONVERT(NVARCHAR(MAX), txt.text)) * 2
        ELSE q.statement_end_offset
END - q.statement_start_offset)/2),
  total_worker_time/execution_count/1000000. secs,
  cast(p.query_plan as xml)
from sys.dm_exec_query_stats q
cross apply sys.dm_exec_sql_text (sql_handle)txt
cross apply sys.dm_exec_text_query_plan (plan_handle, statement_start_offset, statement_end_offset) p
where q.plan_handle = (SELECT plan_handle FROM #t)

DROP TABLE #t

