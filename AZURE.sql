/*
SELECT
	'GuardAppEvent:Start',
	'GuardAppEventType:REQ000002021582',
	'GuardAppEventStrValue:REQ000002021582';

    GO
    SELECT
    'GuardAppEvent:Released';	
*/

DBCC FREEPROCCACHE
select hostname,count(*) from sys.sysprocesses WHERE hostname IN ('RD0050F2A7C173','RD0050F2A7E338','RD0050F2A798F9')
group by hostname
DECLARE @dtini datetime 
select getdate()

--2021-05-17 01:22:29.970
SET @dtini = DATEADD(hh,-6,getdate())
SELECT @dtini
SELECT DATEDIFF(hh,@dtini, GETDATE())
select * from sys.sysprocesses where spid = 325
EXEC sp_LockRaiz
-- Conexoes ativas
EXEC [dbo].[sp_WhoIsActive]
		--@filter = '187'
		--,@filter_type  = 'session'		-- session, program, database, login, and host
 		@get_outer_command =	1
		,@get_plans = 1
		,@output_column_list =	'[dd hh:mm:ss.mss][session_id][database_name][login_name][host_name][start_time][wait_info][status][session_id][blocking_session_id][open_tran_count][CPU][reads][writes][percent_complete][sql_command][query_plan][sql_text][lock]'
		--@destination_table =	'#Resultado_WhoisActive'
		--Help! Descomentar a linha abaixo
		--,@help = 1
SELECT  * FROM sys.sysprocesses
SELECT  * FROM sys.sysprocesses  where spid = 187

SELECT COUNT(*) FROM [CADASTRO].[TB3IPRODUTO_INVESTIDOR] (NOLOCK)

		-- 8f9c50b1-b90c-46de-b9c6-f5f9ac199263@f9cfd8cb-c4a5-4677-b65d-3150dda310c9

SELECT  * FROM sys.dm_exec_query_plan(0x050006003F7DEA11507F9191E401000001000000000000000000000000000000000000000000000000000000)
SELECT  * FROM sys.sysprocesses  where spid = 187
SELECT  * FROM sys.dm_exec_requests where session_id = 305
-->>>>> Errorlog
SELECT database_name,start_time,end_time,event_type, severity =
	CASE Severity
		WHEN 0 THEN 'Informational'
		WHEN 1 THEN 'WARNING'
		WHEN 2 THEN 'ERROR'
		ELSE 'No Data Avaliable'
	END,
description
FROM sys.event_log
WHERE severity in (1,2)  
ORDER BY start_time DESC


select type, name, sum(pages_kb) as total_kb from sys.dm_os_memory_clerks
group by type, name
order by total_kb DESC

 select * from sys.dm_os_sys_info

--> Session LOCK
SELECT TOP 10 r.session_id, r.plan_handle,
				r.sql_handle, 
				r.request_id,      
				r.start_time, 
				r.status,      
				r.command, 
				r.database_id,      
				r.user_id, 
				r.wait_type,      
				r.wait_time, 
				r.last_wait_type,      
				r.wait_resource, 
				r.total_elapsed_time,      
				r.cpu_time, 
				r.transaction_isolation_level,      
				r.row_count, 
				st.text
		--		qp.query_plan
	FROM sys.dm_exec_requests r  
	CROSS APPLY sys.dm_exec_sql_text(r.sql_handle) as st  
	--Cross apply sys.dm_exec_query_plan (r.plan_handle) qp
	WHERE r.blocking_session_id = 0       
		and r.session_id in       
		(SELECT distinct(blocking_session_id) FROM sys.dm_exec_requests)  
	GROUP BY r.session_id, r.plan_handle,      
			r.sql_handle, r.request_id,      
			r.start_time, r.status,      
			r.command, r.database_id,      
			r.user_id, r.wait_type,      
			r.wait_time, r.last_wait_type,      
			r.wait_resource, r.total_elapsed_time,      
			r.cpu_time, r.transaction_isolation_level,      
			r.row_count, st.text  
	ORDER BY r.total_elapsed_time desc

SELECT * FROM sys.dm_exec_plan_attributes (0x060006007A7F7210C09E88C0E801000001000000000000000000000000000000000000000000000000000000) 

SELECT OBJECT_NAME(object_id), forwarded_record_count, 
avg_fragmentation_in_percent,
page_count
from sys.dm_db_index_physical_stats
--(db_id(),default, default, default, 'DETAILED')
(db_id(),default, default, default, 'SAMPLED')
WHERE object_id = 1166627199
GO

SELECT a.object_id, object_name(a.object_id) AS TableName,
    a.index_id, name AS IndedxName, avg_fragmentation_in_percent
FROM sys.dm_db_index_physical_stats
    (DB_ID ()
        , OBJECT_ID(N'RENDA_VARIAVEL.TB3IPOSICAO_ACAO')
        , NULL
        , NULL
        , NULL) AS a
INNER JOIN sys.indexes AS b
    ON a.object_id = b.object_id
    AND a.index_id = b.index_id;
GO

-- use this script to get query text 
 
 SELECT qt.query_sql_text query_text 
 FROM sys.query_store_query q 
 JOIN sys.query_store_query_text qt ON q.query_text_id = qt.query_text_id 
 WHERE q.query_id = 590200


select er.session_id,
    db_name(er.database_id) database_id,
	  TOTAL_ELAPSED_TIME [TOTAL_TIME],
	   TOTAL_ELAPSED_TIME/6000,GETDATE() as [Data],
  DATEDIFF(MI,START_TIME,GETDATE()) MINUTESRUNNING,
  START_TIME,
 	 STATUS,
  WAIT_TYPE,
  LAST_WAIT_TYPE,
       st.text as TSQLCompleto,
       qp.query_plan as PlanoCompleto,
       SubsTring(st.text,er.statement_start_offset/2, (Case When er.statement_end_offset = -1 Then Len(Convert(nVarChar(max), st.text))*2
                                                                                                                  END
       - er.statement_start_offset)/2) as TrechoQueryEmExecusao,
       --tpq.query_plan as TrechoPlanoEmExecusao
       CAST(tpq.query_plan as XML) as TrechoPlanoEmExecusao
from sys.dm_exec_requests er
Cross apply sys.dm_exec_text_query_plan(er.plan_handle, er.statement_start_offset , er.statement_end_offset) tpq
Cross apply sys.dm_exec_query_plan (er.plan_handle) qp
Cross Apply sys.dm_exec_sql_text (er.sql_handle) st
WHERE er.session_id <> @@SPID
order by START_TIME asc

select * from sys.partitions

SELECT s.session_id,
	r.status,
	r.blocking_session_id,
	r.wait_type,
	wait_resource,
	r.wait_time / (1000 * 60) 'wait_time(Min)',
	r.cpu_time,
	r.logical_reads,
	r.reads,
	r.writes,
	r.total_elapsed_time / (1000 * 60) 'total_elapsed_time(Min)',
	--Substring(st.TEXT,(r.statement_start_offset / 2) + 1,
	--	((CASE r.statement_end_offset 	WHEN -1 THEN Datalength(st.TEXT) ELSE r.statement_end_offset 	END - r.statement_start_offset) / 2) + 1) AS statement_text,
	--	Coalesce(Quotename(Db_name(st.dbid)) + N'.' + Quotename(Object_schema_name(st.objectid, st.dbid)) + N'.' +
	--	Quotename(Object_name(st.objectid, st.dbid)), '') AS command_text,
	r.command,
	--qp.query_plan,
	s.login_name,
	s.host_name,
	s.program_name,
	s.last_request_end_time,
	s.login_time,
	r.open_transaction_count
FROM sys.dm_exec_sessions AS s
	JOIN sys.dm_exec_requests AS r ON r.session_id = s.session_id
	CROSS APPLY sys.Dm_exec_sql_text(r.sql_handle) AS st
	CROSS APPLY sys.dm_exec_query_plan(r.plan_handle) AS qp
--WHERE r.session_id != @@SPID
WHERE r.session_id = 187
ORDER BY r.cpu_time desc
 
/*

select   * from sys.dm_db_resource_stats
order by end_time desc

-- somente na master
select top 100 *   FROM sys.resource_stats 
order by start_time desc

select top 100 *   FROM sys.resource_usage
order by end_time desc
 
 select top 100 * from sys.dm_resource_governor_resource_pools_history_ex 
 order by statistics_start_time desc
 --snapshot_time desc

 select top 100 * from sys.event_log
 where database_name = 'azr-db-b3i-p'
   and event_category <> 'connectivity'
   order by end_time desc

  select top 100 * from sys.event_log_ex
  where database_name = 'azr-db-b3i-p'
  and event_category <> 'connectivity'
  order by start_time desc
 --sp_who2 active

 select * from sys.dm_xe_database_session_targets

 SELECT * from sys.database_event_sessions


 
 SELECT
    se.name                      AS [session-name],
    ev.event_name,
    ac.action_name,
    st.target_name,
    se.session_source,
    st.target_data,
    CAST(st.target_data AS XML)  AS [target_data_XML]
FROM
               sys.dm_xe_database_session_event_actions  AS ac

    INNER JOIN sys.dm_xe_database_session_events         AS ev  ON ev.event_name = ac.event_name
        AND CAST(ev.event_session_address AS BINARY(8)) = CAST(ac.event_session_address AS BINARY(8))

    INNER JOIN sys.dm_xe_database_session_object_columns AS oc
         ON CAST(oc.event_session_address AS BINARY(8)) = CAST(ac.event_session_address AS BINARY(8))

    INNER JOIN sys.dm_xe_database_session_targets        AS st
         ON CAST(st.event_session_address AS BINARY(8)) = CAST(ac.event_session_address AS BINARY(8))

    INNER JOIN sys.dm_xe_database_sessions               AS se
         ON CAST(ac.event_session_address AS BINARY(8)) = CAST(se.address AS BINARY(8))
WHERE
        oc.column_name = 'occurrence_number'
    --AND
    --    se.name        = 'eventsession_gm_azuresqldb51'
    AND
        ac.action_name = 'sql_text'
ORDER BY
    se.name,
    ev.event_name,
    ac.action_name,
    st.target_name,
    se.session_source
;

 DBCC USEROPTIONS 
*/


 
select	'GuardAppEvent:Released' 'GuardAppEvent:Released' 
go