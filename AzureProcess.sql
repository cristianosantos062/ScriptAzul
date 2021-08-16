/*
	SELECT
	'GuardAppEvent:Start',
	'GuardAppEventType:METADADO',
	'GuardAppEventStrValue:METADADO - Execução de requisções no SQLAzure';
 
	select	'GuardAppEvent:Released' 'GuardAppEvent:Released' 
	go
*/


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

 SELECT * FROM sys.sysprocesses


 
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

select * from sys.dm_exec_requests where session_id = 148

select * from sys.sysprocesses where spid = 148

kill 148

SELECT distinct session_id, blocking_session_id,
    (SELECT SUBSTRING(text, statement_start_offset/2 + 1,
        (CASE WHEN statement_end_offset = -1 
            THEN LEN(CONVERT(nvarchar(MAX),text)) * 2 
                ELSE statement_end_offset 
            END - statement_start_offset)/2)
     FROM sys.dm_exec_sql_text(a.sql_handle)) TRECHO,
  PERCENT_COMPLETE,
  SPID,
    WAIT_TYPE,
  LAST_WAIT_TYPE,
  TOTAL_ELAPSED_TIME,
DATEDIFF(mi,START_TIME,GETDATE()) MINUTESRUNNING,
  DB_NAME(SP.DBID) BANCO,
  OBJECT_NAME(OBJECTID, A.DATABASE_ID) OBJECTNAME,
  HOSTNAME,
  REPLACE(T.TEXT,CHAR(13) + Char(10) ,' ') TEXT,
  ltrim(T.TEXT)TEXT,
  A.STATUS,
  SP.LOGINAME,

  START_TIME,
  PERCENT_COMPLETE,
  COMMAND,
  (ESTIMATED_COMPLETION_TIME/1000/60) AS MINUTESTOFINISH,
  --DATEADD(MS,ESTIMATED_COMPLETION_TIME,GETDATE()) AS STIMATEDCOMPLETIONTIME,  
 -- TOTAL_ELAPSED_TIME AS TOTAL_ELAPSED_TIME,
  hostprocess,
  plan_handle,
  sp.waitresource
  --sp.*
FROM  
  sys.dm_exec_requests a
  INNER JOIN sys.databases b ON a.database_id = b.database_id
  INNER JOIN sys.sysprocesses sp ON sp.spid = a.session_id
  cross apply sys.dm_exec_sql_text(a.sql_handle) t


WHERE   
  SPID =  232
/*
AND DB_NAME(SP.DBID) in( 'DI')
--*/
/*
AND text like '%TTEMDET_ARQ_DERV%'
--*/
/*
AND SP.LOGINAME = 'alteryxusrp'
--*/
/*
AND SP.HOSTNAME like '%SPP%'
--*/
/*
AND SP.HOSTPROCESS = 205132
--*/

-- CXSYNC_PORT

-->  Top 20 tempo de execucao
select er.session_id,
    db_name(er.database_id) database_id,
	  TOTAL_ELAPSED_TIME,
	   (TOTAL_ELAPSED_TIME/1000)/60,DATEADD(HH,-3,GETDATE()) as DT_BR,
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
--where db_name(er.database_id) like 'dbav%'
order by START_TIME asc

select * from sys.dm_exec_requests where session_id = 191

select * from sys.sysprocesses where spid=191

