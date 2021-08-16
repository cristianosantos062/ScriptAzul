 /*
 SELECT
    'GuardAppEvent:Start',
    'GuardAppEventType: INC000003135668',
    'GuardAppEventStrValue: INC000003135668';
	
    GO
    SELECT
    'GuardAppEvent:Released';	
*/
--DBCC SQLPERF('sys.dm_os_wait_stats',CLEAR);

select  'ALTER INDEX ALL ON '+OBJECT_NAME(object_id)+' REBUILD WITH (SORT_IN_TEMPDB = ON, ALLOW_PAGE_LOCKS = ON);
go' from sys.tables
where object_id > 10000 and name is not null



--->>> Atualizaco de statistics
update statistics TDIMVTO_COTR_BTC_MES  with RESAMPLE
update statistics [hst].[TDWNEAR_POSICAO_INVESTIDOR_GARANTIDA_PARTICIPANTE_NEGOCIACAO_PARTICIPANTE_DIRETO]   with fullscan
DBCC SHOW_STATISTICS('TDICTRL_PRDT',IE02_TDICTRL_PRDT) WITH HISTOGRAM
GO
SELECT 'drop table '+QUOTENAME(name)+'
go' from sys.tables where name like '%trace%'

SELECT name, create_date from sys.tables where name like '%trace%'

SELECT OBJECT_NAME(id),text FROM sys.syscomments where text like '%SPU_UPDATE_STATISTICS_TABLE%'

select * from sys.procedures where name like 'spu_alt_%'

SELECT MAX(DT_COLETA)  FROM HIST_TB_TIME_PROCS_DETAILS_20210319
--->>> Nome fisico de servidor
SELECT   @@SERVERNAME ServerName_Global_Variable
,SERVERPROPERTY('ServerName') ServerName
,SERVERPROPERTY('InstanceName') InstanceName
,SERVERPROPERTY('MachineName') MachineName
,SERVERPROPERTY('ComputerNamePhysicalNetBIOS') ComputerNamePhysicalNetBIOS
GO

select * from adm.TDWCONFIGURACAO_SSIS WHERE configurationfilter like 'ssis_sisc%'

select convert(XML,convert(varbinary(max),packagedata)),* from sysssispackages where name LIKE 'SSIS_SISC%'

--->>> SELECT sys.sysprocesses
Select 'KILL '+ cast(spid as varchar(5))+'
GO'from sys.sysprocesses where loginame = 'alteryxusrp'  --AND dbid = 68
--where nt_username = '%p-aalonso%'
and spid > 50
order by cpu desc;
--group by hostname
GO

select db_id('YMFSAC_CBLC')

Select * from sys.sysprocesses where loginame like '%aalonso%'

Select * from sys.sysprocesses  where status = 'sleeping'  AND dbid = 68

--->>> SELECT sys.dm_exec_requests
select * from sys.dm_exec_requests where session_id > 50  and database_id=db_id()
order by cpu_time desc --, database_id = 69
GO
--->>>Execution Plan por SPID
select SUBSTRING(qt.TEXT, (qs.statement_start_offset/2)+1, qs.statement_end_offset),qs.plan_handle
     FROM sys.dm_exec_requests qs
    CROSS APPLY sys.dm_exec_sql_text(qs.sql_handle) qt
   -- where qs.session_id=90
GO

--->>>SELECT plan cach Text/Plan
select * from sys.dm_exec_cached_plans 
select * from sys.dm_exec_query_plan(0x060006007490181C20FEA94C9D02000001000000000000000000000000000000000000000000000000000000)
select * from sys.dm_exec_query_plan(0x060006007490181CA082F34A2A02000001000000000000000000000000000000000000000000000000000000)
select * from sys.dm_exec_sql_text(0x03004900051A4B1D1C285701D4AA000001000000)
GO

sp_query_store_remove_plan  @plan_id = 506941

sp_query_store_unforce_plan @query_id = 563044 , @plan_id = 234055 

234055	563044
506941	563044

--->>>SELECT plan cach per Object
SELECT cp.plan_handle, cp.objtype, cp.usecounts, 
DB_NAME(st.dbid) AS [DatabaseName]
FROM sys.dm_exec_cached_plans AS cp CROSS APPLY sys.dm_exec_sql_text(plan_handle) AS st 
WHERE OBJECT_NAME (st.objectid)
LIKE N'%SPCS_PR_MSG_CBL0507%' OPTION (RECOMPILE); 
GO

--->>> Remove the specific query plan from the cache using the plan handle from the above query 
DBCC FREEPROCCACHE (0x050049004C13AF2B40144D830C01000001000000000000000000000000000000000000000000000000000000);
DBCC FREEPROCCACHE ()
--->>>SELECT sys.sysindexes 
select OBJECT_NAME(id),reserved, used, rowcnt
 from sys.sysindexes 
order by used desc
GO

--->>>ALTER TABLE DATA_COMPRESSION
--ALTER TABLE HIST_TB_TIME_PROCS_DETAILS_20210319 REBUILD WITH (DATA_COMPRESSION =  PAGE)
ALTER TABLE TB_TIME_PROCS_DETAILS REBUILD WITH (DATA_COMPRESSION =  PAGE)TB_TIME_PROCS_DETAILS
select * from [msdb]..[sysjobsteps]
-- sp_spaceused '[mf].[CP_HIST_NEGOCIOS_ESPECIFICADOS]'

SELECT OBJECT_NAME(id), text FRom sys.syscomments WHERE text LIKE '%INSERT INTO DBO.#CS_MVTO_CUST_EFET%'

--->>>Pacotes DTSX
select convert(XML,convert(varbinary(max),packagedata)),* from sysssispackages where name = 'SSIS_m_tdwtem_negocio'

--->>>Index Fragmentation
SELECT S.name as 'Schema',
		T.name as 'Table',
		I.name as 'Index',
		DDIPS.avg_fragmentation_in_percent,
		DDIPS.page_count
FROM sys.dm_db_index_physical_stats (DB_ID(), NULL, NULL, NULL, NULL) AS DDIPS
	INNER JOIN sys.tables T on T.object_id = DDIPS.object_id
	INNER JOIN sys.schemas S on T.schema_id = S.schema_id
	INNER JOIN sys.indexes I ON I.object_id = DDIPS.object_id
		AND DDIPS.index_id = I.index_id
WHERE DDIPS.database_id = DB_ID()
	AND I.name is not null
	AND S.name = 'mf'
	AND T.name = 'CP_HIST_NEGOCIOS_ESPECIFICADOS'
	AND DDIPS.avg_fragmentation_in_percent > 0
ORDER BY DDIPS.avg_fragmentation_in_percent desc
GO
----<<<   MONITORACAO ADM_BDADOS >>>>--------------------------------------------------


select count(1) from hst.ADWTC_NEGOCIO_DEFINITIVO_TEST_PERF

--Data Source=RTC;User ID=PR01STASIV2U;Provider=OraOLEDB.Oracle.1;UseSessionFormat=True;Password=
--OPEN SYMMETRIC KEY SIN_KEY_SI_DW DECRYPTION BY CERTIFICATE CERT_SI_DW
--SELECT Desc_Conexao + CONVERT(nvarchar(4000), DecryptByKey(Desc_Senha)) AS Decrypted FROM adm.TDWCONEXAO_CONFIGURACAO where Nome_Conexao = 'RTCConn'


--UPDATE ADM_BDADOS.dbo.TB_PROCESS_DETAIL SET CPU =  LTRIM(RTRIM(CPU))
--	FROM ADM_BDADOS.dbo.TB_PROCESS_DETAIL
SELECT * FROM ADM_BDADOS.dbo.TB_PROCESS_DETAIL
WHERE 1=1 
--AND database_name = 'SI_DW'
AND collection_time >= '2021-07-12 06:10:00.000' 
AND  collection_time <= '2021-07-12 06:11:00.000' 
ORDER BY [dd hh:mm:ss.mss] DESC

--13h e terminou por volta de 14h30 do dia 19/05
select CONVERT(nvarchar(11),dt_coleta,110) dt, dbname, SUM(cpu) cpu from TB_MONIT_CPU WHERE dbname NOT IN ('ADM_BDADOS','master','tempdb','msdb','')
--AND dt_coleta  BETWEEN '2021-03-01 00:00:00.000' AND '2021-03-31 23:59:59.983'
--AND dbname = 'CS'
GROUP BY dbname, CONVERT(nvarchar(11),dt_coleta,110)
ORDER BY dt

select * from sys.tables where name like 'TDWDVA_%'

SELECT start_time, [dd hh:mm:ss.mss], database_name, wait_info, sql_command,sql_text, query_plan,*  FROM ADM_BDADOS.dbo.TB_PROCESS_DETAIL
WHERE  start_time 
	BETWEEN '2021-07-21 12:42:15.497' 
	AND '2021-07-21 12:44:18.497' 
	AND database_name = 'SI_DW'
	AND CONVERT(varchar(8000),sql_command) LIKE '%SPCS_PR_MSG_CBL0507%'

select * from sys.dm_server_services
SELECT TOP 5 * FROM ADM_BDADOS.dbo.TB_PROCESS_DETAIL
--AND session_id = 696
--DELETE 
--DELETE  FROM ADM_BDADOS.dbo.TB_PROCESS_DETAIL where collection_time <= '2021-03-03 00:00:00.000'
--DELETE FROM ADM_BDADOS.dbo.TB_PROCESS_DETAIL where login_name = 'GestaoAmbienteSQL'
 go

 select top 5000 * from sysssislog whee source 
 order by starttime desc

 -- JOIN sysprocesses
 SELECT  dt.collection_time, sp.spid, dt.[dd hh:mm:ss.mss], sp.loginame,
        dt.login_name, dt.session_id
FROM    sys.sysprocesses sp JOIN [ADM_BDADOS].[dbo].[TB_PROCESS_DETAIL] dt
            ON sp.loginame = dt.login_name
WHERE   --sp.loginame = 'my_login_name'
         sp.status = 'runnable'
        AND sp.spid > 50
        AND dt.collection_time > DATEADD(MM, -10, GETDATE());

--kill 83          
-- Locks
EXEC sp_LockRaiz
-- Conexoes ativas
EXEC [dbo].[sp_WhoIsActive]
		--@not_filter = '83',				
		--@not_filter_type = 'session',	-- session, program, database, login, and host
		--@filter = 'SI_DW',
		--@filter_type  = 'database',		-- session, program, database, login, and host
 		--@get_outer_command =	0,
		--,@get_locks = 1,
		@show_sleeping_spids  = 1,
		@get_plans = 1,
		@output_column_list =	'[dd hh:mm:ss.mss][session_id][database_name][login_name][host_name][start_time][wait_info][status][sql_command][blocking_session_id][open_tran_count][CPU][reads][writes][percent_complete][sql_command][query_plan][sql_text]'
		--@destination_table =	'#Resultado_WhoisActive',
		--Help! Descomentar a linha abaixo
		--,@help = 1

		kill 326
SELECT * INTO stg.ADWALOCACAO_D0_INC000003135668 FROM stg.ADWALOCACAO_D0

SELECT * INTO stg.ADWALOCACAO_D1_INC000003135668 FROM stg.ADWALOCACAO_D1

sp_spaceused 'stg.ADWALOCACAO_D1_INC000003135668'
sp_spaceused 'stg.ADWALOCACAO_D0_INC000003135668'
sp_spaceused 'stg.ADWALOCACAO_D0'
sp_spaceused 'stg.ADWALOCACAO_D1'

truncate table stg.ADWALOCACAO_D0

truncate table stg.ADWALOCACAO_D1


SELECT   @@SERVERNAME ServerName_Global_Variable
,SERVERPROPERTY('ServerName') ServerName
,SERVERPROPERTY('InstanceName') InstanceName
,SERVERPROPERTY('MachineName') MachineName
,SERVERPROPERTY('ComputerNamePhysicalNetBIOS') ComputerNamePhysicalNetBIOS
GO
		
select
	SERVERPROPERTY('ComputerNamePhysicalNetBIOS') ComputerNamePhysicalNetBIOS
	,SERVERPROPERTY('InstanceName') InstanceName,
(physical_memory_in_use_kb/1048576)Phy_Memory_usedby_Sqlserver_MB,
(locked_page_allocations_kb/1048576 )Locked_pages_used_Sqlserver_MB,
(virtual_address_space_committed_kb/1048576 )Total_Memory_UsedBySQLServer_MB,
process_physical_memory_low,
process_virtual_memory_low
 FROM sys.dm_os_process_memory

 select SERVERPROPERTY('ComputerNamePhysicalNetBIOS') ComputerNamePhysicalNetBIOS
	,SERVERPROPERTY('ServerName') InstanceName
	,(select (virtual_address_space_committed_kb/1048576 ) FROM sys.dm_os_process_memory ) as Total_Memory_UsedBySQLServer_gb
	,(total_physical_memory_kb/1048576)Phy_Memory_usedby_Sqlserver_gb
	,(available_physical_memory_kb/1048576 )available_physical_memory_gb
	--, ((select (virtual_address_space_committed_kb/1048576 ) FROM sys.dm_os_process_memory )/(total_physical_memory_kb/1048576)) as Perc_Used
 from sys.dm_os_sys_memory


 select SERVERPROPERTY('ComputerNamePhysicalNetBIOS') ComputerNamePhysicalNetBIOS
	,SERVERPROPERTY('InstanceName') InstanceName
	,(select (virtual_address_space_committed_kb/1048576 ) FROM sys.dm_os_process_memory ) as Total_Memory_UsedBySQLServer_gb
	,
process_physical_memory_low,
process_virtual_memory_low
 FROM sys.dm_os_process_memory

(total_physical_memory_kb/1048576)Phy_Memory_usedby_Sqlserver_gb,
(available_physical_memory_kb/1048576 )available_physical_memory_gb
 from sys.dm_os_sys_memory


UPDATE STATISTICS CESTA_ITENS  WITH RESAMPLE
		 UPDATE STATISTICS  NEGOCIADOR  WITH RESAMPLE
		 UPDATE STATISTICS BOLETO_PROTOCOLO  WITH RESAMPLE


select * from sys.sysprocesses where kpid <>0

USE DW_BALCAO
GO
TRUNCATE TABLE hst.ADWBALAGENDA_EVENTO
GO
'[hst].[TDWTRADING_OFERTA_COMPRA]'
--APSBCO00201P ou usuario cnoest
select * from sys.dm_exec_requests where session_id =121

dbcc sqlperf('logspace')

exec sp_WhoIsActive 
		@not_filter = 'CORPORATE\aalonso'				
		,@not_filter_type = 'login'	-- session, program, database, login, and host
		--,@filter = 'corporate\aalonso'
		--,@filter_type  = 'login'		-- session, program, database, login, and host
		,@show_sleeping_spids  = 2
		,@get_full_inner_text = 0
		,@get_outer_command =	1
		,@get_locks = 1
		,@get_avg_time = 0
		,@get_plans = 1
		,@output_column_list =	'[dd hh:mm:ss.mss][session_id][database_name][login_name][host_name][start_time][wait_info[status][session_id][blocking_session_id][open_tran_count][CPU][reads][writes][percent_complete][sql_command][query_plan][sql_text][locks]'
		--Help! Descomentar a linha abaixo
		--,@help = 1

WITH DB_CPU_Stats
AS
	(SELECT DatabaseID, DB_Name(DatabaseID) AS [Database Name], SUM(total_worker_time) AS [CPU_Time_Ms]
		FROM sys.dm_exec_query_stats AS qs
		CROSS APPLY (SELECT CONVERT(int, value) AS [DatabaseID]
		FROM sys.dm_exec_plan_attributes(qs.plan_handle)
		WHERE attribute = N'dbid') AS F_DB
	GROUP BY DatabaseID
	)
SELECT ROW_NUMBER() OVER(ORDER BY [CPU_Time_Ms] DESC) AS [CPU Rank],
	[Database Name], [CPU_Time_Ms] AS [CPU Time (ms)],
	CAST([CPU_Time_Ms] * 1.0 / SUM([CPU_Time_Ms]) OVER() * 100.0 AS DECIMAL(5, 2)) AS [CPU Percent]
FROM DB_CPU_Stats WHERE DatabaseID <> 32767 -- ResourceDB
ORDER BY [CPU Rank] OPTION (RECOMPILE);



exec [ADM_BDADOS].[dbo].[sp_ADMGeraCMDRestore]
		 @dbname	= 'ADM_BDADOS'	-- Nome do banco original
		,@dbdest	= 'ADM_BDADOS'	-- Nome do banco que sera restaurado o backup
		,@DirDest	= 'E:\DBA\'		-- Diretorio onde serao criados os arquivos do banco

SELECT distinct session_id, 
		DATEDIFF(mi,START_TIME,GETDATE()) MinRun,
		(ESTIMATED_COMPLETION_TIME/1000) AS [Sec/Fin],
		percent_complete AS [%],
 		blocking_session_id as [Blk_ID],
		(SELECT SUBSTRING(text, statement_start_offset/2 + 1,
			(CASE WHEN statement_end_offset = -1 
				THEN LEN(CONVERT(nvarchar(MAX),text)) * 2 
					ELSE statement_end_offset 
				END - statement_start_offset)/2)
		 FROM sys.dm_exec_sql_text(a.sql_handle)) Cmd,
	   wait_time,
	  last_wait_type,
	  TOTAL_ELAPSED_TIME as total_time,
	  DB_NAME(SP.DBID) BANCO,
	  OBJECT_NAME(OBJECTID, A.DATABASE_ID) objname,
	  hostname,
	--  REPLACE(T.TEXT,CHAR(13) + Char(10) ,' ') TEXT,
	  ltrim(T.TEXT) text,
	  A.status,
	  SP.loginame,
	  START_TIME,
	  COMMAND,
	  hostprocess,
	  plan_handle,
	  a.sql_handle,
	  sp.waitresource
FROM  
  sys.dm_exec_requests a
  INNER JOIN sys.databases b ON a.database_id = b.database_id
  INNER JOIN sys.sysprocesses sp ON sp.spid = a.session_id
  cross apply sys.dm_exec_sql_text(a.sql_handle) t
WHERE   
  SPID <> @@spid
  AND hostname <> SERVERPROPERTY('ComputerNamePhysicalNetBIOS')
  AND hostname NOT LIKE 'SQLDIAG%'
  --AND DB_NAME(SP.DBID) in( 'SI_DW')
ORDER BY 2 Desc

select * from sys.procedures where name = 'SPCS_PR_MSG_CBL0507'

SELECT  er.session_id ,
        host_name ,
        program_name ,
        original_login_name ,
        er.reads ,
        er.writes ,
        er.cpu_time ,
        wait_type ,
        wait_time ,
        wait_resource ,
        blocking_session_id ,
        st.text
FROM    sys.dm_exec_sessions es
        LEFT JOIN sys.dm_exec_requests er ON er.session_id = es.session_id
        OUTER APPLY sys.dm_exec_sql_text(er.sql_handle) st
WHERE   blocking_session_id > 0
UNION
SELECT  es.session_id ,
        host_name ,
        program_name ,
        original_login_name ,
        es.reads ,
        es.writes ,
        es.cpu_time ,
        wait_type ,
        wait_time ,
        wait_resource ,
        blocking_session_id ,
        st.text
FROM    sys.dm_exec_sessions es
        LEFT JOIN sys.dm_exec_requests er ON er.session_id = es.session_id
        OUTER APPLY sys.dm_exec_sql_text(er.sql_handle) st
WHERE   es.session_id IN ( SELECT   blocking_session_id
                           FROM     sys.dm_exec_requests
                           WHERE    blocking_session_id > 0 );




/*
select TOP 100 cp.plan_handle,qp.objectid, qp.query_plan, OBJECT_NAME(qp.objectid) as name from sys.dm_exec_cached_plans cp
CROSS APPLY SYS.dm_exec_query_plan(cp.plan_handle) qp
--WHERE qp.objectid = 775934086 and qp.dbid = (select database_id from sys.databases where name = @banco)
WHERE qp.dbid = (select database_id from sys.databases where name = @banco)
*/


DECLARE @banco SYSNAME = 'SI_EXTERNO'
		,@proc SYSNAME = N'SPU_INS_ADWRANK_POSICAO_DEPOSITARIA'

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

DROP TABLE #t

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


-- sp_helptext 'VDNINST_INFO_MEIO'

---sp_helptext 'VDNINST_INFO_MEIO'

--Author: Saleem Hakani (http://sqlcommunity.com)
--Query to find top 50 high CPU queries and it's details

SELECT TOP 50
	Convert(varchar, qs.creation_time, 109) as Plan_Compiled_On, 
	qs.execution_count as 'Total Executions', 
	qs.total_worker_time as 'Overall CPU Time Since Compiled',
	Convert(Varchar, qs.last_execution_time, 109) as 'Last Execution Date/Time',
	cast(qs.last_worker_time as varchar) +'   ('+ cast(qs.max_worker_time as Varchar)+' Highest ever)' as 'CPU Time for Last Execution (Milliseconds)',
	Convert(varchar,(qs.last_worker_time/(1000))/(60*60)) + ' Hrs (i.e. ' + convert(varchar,(qs.last_worker_time/(1000))/60) + ' Mins & ' + convert(varchar,(qs.last_worker_time/(1000))%60) + ' Seconds)' as 'Last Execution Duration', 
	qs.last_rows as 'Rows returned',
	qs.total_logical_reads/128 as 'Overall Logical Reads (MB)', 
	qs.max_logical_reads/128 'Highest Logical Reads (MB)', 
	qs.last_logical_reads/128 'Logical Reads from Last Execution (MB)',
	qs.total_physical_reads/128 'Total Physical Reads Since Compiled (MB)', 
	qs.last_dop as 'Last DOP used',
	qs.last_physical_reads/128 'Physical Reads from Last Execution (MB)',
	t.[text] 'Query Text', 
	qp.query_plan as 'Query Execution Plan', 
	DB_Name(t.dbid) as 'Database Name', 
	t.objectid as 'Object ID', 
	t.encrypted as 'Is Query Encrypted'
	--qs.plan_handle --Uncomment this if you want query plan handle
FROM sys.dm_exec_query_stats qs 
CROSS APPLY sys.dm_exec_sql_text(plan_handle) AS t
CROSS APPLY sys.dm_exec_query_plan(plan_handle) AS qp
ORDER BY qs.last_worker_time DESC
Go

-- Tempo de CPU
SELECT  creation_time 
        ,last_execution_time
		,last_worker_time
		,last_elapsed_time
		,((total_elapsed_time / execution_count)/1000) AS [Time]
        ,total_physical_reads
        ,total_logical_reads 
        ,total_logical_writes
        , execution_count
        , total_worker_time
        , total_elapsed_time
        , total_elapsed_time / execution_count avg_elapsed_time
        ,SUBSTRING(st.text, (qs.statement_start_offset/2) + 1,
         ((CASE statement_end_offset
          WHEN -1 THEN DATALENGTH(st.text)
          ELSE qs.statement_end_offset END
            - qs.statement_start_offset)/2) + 1) AS statement_text
--		,qp.query_plan
FROM sys.dm_exec_query_stats AS qs
CROSS APPLY sys.dm_exec_sql_text(qs.sql_handle) st
--CROSS APPLY sys.dm_exec_query_plan(qs.query_plan_hash) qp
ORDER BY last_execution_time DESC,total_elapsed_time / execution_count DESC;

/*----
SELECT TOP 15 
   object_name(t.objectid, t.dbid) objeto,
   db_name(t.dbid) banco,
   qs.creation_time, 
   qs.execution_count, 
   qs.total_worker_time as total_cpu_time, 
   qs.max_worker_time as max_cpu_time, 
   qs.total_elapsed_time, 
   qs.max_elapsed_time, 
   qs.total_logical_reads, 
   qs.max_logical_reads, 
   qs.total_physical_reads, 
   qs.max_physical_reads,
   t.[text], 
   qp.query_plan, 
   t.dbid, 
   t.objectid, 
   t.encrypted, 
   qs.plan_handle, 
   qs.plan_generation_num 
 FROM 
   sys.dm_exec_query_stats qs 
   CROSS APPLY sys.dm_exec_sql_text(plan_handle) AS t 
   CROSS APPLY sys.dm_exec_query_plan(plan_handle) AS qp 
 ORDER BY 
   qs.total_worker_time DESC
*/

