set nocount on 
select  'GuardAppEvent:Start' 'GuardAppEvent:Start'	
		,'GuardAppEventType:METADADO' 'GuardAppEventType:METADADO'
	    ,'GuardAppEventStrValue:METADADO' 'GuardAppEventStrValue:METADADO' INTO #TBLASTRO;
/*
Eduardo de Oliveira Gomesx
Tempo restante QUERY
*/
USE MASTER 
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
  SPID <> @@spid
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

order by 8 desc
if object_id('tempdb..#TBLASTRO2') IS NOT NULL
  drop table #TBLASTRO2
if object_id('tempdb..#TBLASTRO') IS NOT NULL
  drop table #TBLASTRO
select	'GuardAppEvent:Released' 'GuardAppEvent:Released' INTO #TBLASTRO2; 
go
