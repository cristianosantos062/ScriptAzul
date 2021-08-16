/****** Object:  Table [dbo].[TBTEMPDB_USAGE]    
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[TBTEMPDB_USAGE](
	[dt_coleta] [datetime] NOT NULL,
	[session_id] [smallint] NULL,
	[request_id] [int] NULL,
	[database_id] [nvarchar](128) NULL,
	[Total_User_Objects] [decimal](16, 2) NULL,
	[net_user_objects] [decimal](16, 2) NULL,
	[total_internal_objects] [decimal](16, 2) NULL,
	[net_internal_objects] [decimal](16, 2) NULL,
	[total_allocation] [decimal](16, 2) NULL,
	[net_allocation] [decimal](16, 2) NULL,
	[query_text] [nvarchar](max) NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
CREATE CLUSTERED INDEX [IDX01_TBTEMPDB_USAGE] ON [dbo].[TBTEMPDB_USAGE]([dt_coleta])
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[TBTEMPDB_USAGE_QUERY](
	[dt_coleta] [datetime] NOT NULL,
	[host_name] [nvarchar](128) NULL,
	[login_name] [nvarchar](128) NOT NULL,
	[program_name] [nvarchar](128) NULL,
	[QueryExecContextDBID] [smallint] NULL,
	[QueryExecContextDBNAME] [nvarchar](128) NULL,
	[ModuleObjectId] [int] NULL,
	[Query_Text] [nvarchar](max) NULL,
	[session_id] [smallint] NULL,
	[request_id] [int] NULL,
	[exec_context_id] [int] NULL,
	[OutStanding_user_objects_page_counts] [bigint] NULL,
	[OutStanding_internal_objects_page_counts] [bigint] NULL,
	[start_time] [datetime] NOT NULL,
	[command] [nvarchar](32) NOT NULL,
	[open_transaction_count] [int] NOT NULL,
	[percent_complete] [real] NOT NULL,
	[estimated_completion_time] [bigint] NOT NULL,
	[cpu_time] [int] NOT NULL,
	[total_elapsed_time] [int] NOT NULL,
	[reads] [bigint] NOT NULL,
	[writes] [bigint] NOT NULL,
	[logical_reads] [bigint] NOT NULL,
	[granted_query_memory] [int] NOT NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
CREATE CLUSTERED INDEX [IDX01_TBTEMPDB_USAGE_QUERY] ON [dbo].[TBTEMPDB_USAGE_QUERY]([dt_coleta])
GO
******/

-- Drop stored procedure if it already exists
IF EXISTS (
  SELECT * 
    FROM INFORMATION_SCHEMA.ROUTINES 
   WHERE SPECIFIC_SCHEMA = N'dbo'
     AND SPECIFIC_NAME = N'spMonitTempDB' 
)
   DROP PROCEDURE dbo.spMonitTempDB
GO

CREATE PROCEDURE dbo.spMonitTempDB
AS
SEt NOCOUNT ON
	INSERT INTO [ADM_BDADOS].[dbo].[TBTEMPDB_USAGE_QUERY]([dt_coleta],[host_name], [login_name], [program_name], [QueryExecContextDBID], [QueryExecContextDBNAME], [ModuleObjectId], [Query_Text], [session_id], [request_id], [exec_context_id], [OutStanding_user_objects_page_counts], [OutStanding_internal_objects_page_counts], [start_time], [command], [open_transaction_count], [percent_complete], [estimated_completion_time], [cpu_time], [total_elapsed_time], [reads], [writes], [logical_reads], [granted_query_memory])
	SELECT GETDATE( ) AS [dt_coleta],
		   es.host_name,
		   es.login_name,
		   es.program_name,
		   st.dbid AS QueryExecContextDBID,
		   DB_NAME(st.dbid) AS QueryExecContextDBNAME,
		   st.objectid AS ModuleObjectId,
		   SUBSTRING(st.text, er.statement_start_offset/2 + 1, (CASE
																	WHEN er.statement_end_offset = -1 THEN LEN(CONVERT(nvarchar(MAX), st.text)) * 2
																	ELSE er.statement_end_offset
																END - er.statement_start_offset)/2) AS Query_Text,
		   tsu.session_id,
		   tsu.request_id,
		   tsu.exec_context_id,
		   (tsu.user_objects_alloc_page_count - tsu.user_objects_dealloc_page_count) AS OutStanding_user_objects_page_counts,
		   (tsu.internal_objects_alloc_page_count - tsu.internal_objects_dealloc_page_count) AS OutStanding_internal_objects_page_counts,
		   er.start_time,
		   er.command,
		   er.open_transaction_count,
		   er.percent_complete,
		   er.estimated_completion_time,
		   er.cpu_time,
		   er.total_elapsed_time,
		   er.reads,
		   er.writes,
		   er.logical_reads,
		   er.granted_query_memory 
		   --	INTO [ADM_BDADOS].[dbo].[TBTEMPDB_USAGE_QUERY]
	FROM sys.dm_db_task_space_usage tsu

	INNER JOIN sys.dm_exec_requests er ON (tsu.session_id = er.session_id
										   AND tsu.request_id = er.request_id)
	INNER JOIN sys.dm_exec_sessions es ON (tsu.session_id = es.session_id) CROSS APPLY sys.dm_exec_sql_text(er.sql_handle) st
	WHERE (tsu.internal_objects_alloc_page_count+tsu.user_objects_alloc_page_count) > 0
	ORDER BY (tsu.user_objects_alloc_page_count - tsu.user_objects_dealloc_page_count)+(tsu.internal_objects_alloc_page_count - tsu.internal_objects_dealloc_page_count) DESC


	INSERT INTO [ADM_BDADOS].[dbo].[TBTEMPDB_USAGE] ([dt_coleta], [session_id], [request_id], [database_id], [Total_User_Objects], [net_user_objects], [total_internal_objects], [net_internal_objects], [total_allocation], [net_allocation], [query_text])
	SELECT  GETDATE( ) AS [dt_coleta],
			COALESCE(T1.session_id, T2.session_id) [session_id] ,        T1.request_id ,
			DB_NAME(COALESCE(T1.database_id, T2.database_id)) [database_id],
			COALESCE(T1.[total_user_objects], 0)
			+ T2.[total_user_objects] [Total_User_Objects] ,
			COALESCE(T1.[net_user_objects], 0)
			+ T2.[net_user_objects] [net_user_objects] ,
			COALESCE(T1.[total_internal_objects], 0)
			+ T2.[total_internal_objects] [total_internal_objects] ,
			COALESCE(T1.[net_internal_objects], 0)
			+ T2.[net_internal_objects] [net_internal_objects] ,
			COALESCE(T1.[total_allocation], 0) + T2.[total_allocation] [total_allocation] ,
			COALESCE(T1.[net_allocation], 0) + T2.[net_allocation] [net_allocation] ,
			COALESCE(T1.[query_text], T2.[query_text]) [query_text]
	FROM    ( SELECT    TS.session_id ,
						TS.request_id ,
						TS.database_id ,
						CAST(TS.user_objects_alloc_page_count / 128 AS DECIMAL(15,
																  2)) [total_user_objects] ,
						CAST(( TS.user_objects_alloc_page_count
							   - TS.user_objects_dealloc_page_count ) / 128 AS DECIMAL(15,
																  2)) [net_user_objects] ,
						CAST(TS.internal_objects_alloc_page_count / 128 AS DECIMAL(15,
																  2)) [total_internal_objects] ,
						CAST(( TS.internal_objects_alloc_page_count
							   - TS.internal_objects_dealloc_page_count ) / 128 AS DECIMAL(15,
																  2)) [net_internal_objects] ,
						CAST(( TS.user_objects_alloc_page_count
							   + internal_objects_alloc_page_count ) / 128 AS DECIMAL(15,
																  2)) [total_allocation] ,
						CAST(( TS.user_objects_alloc_page_count
							   + TS.internal_objects_alloc_page_count
							   - TS.internal_objects_dealloc_page_count
							   - TS.user_objects_dealloc_page_count ) / 128 AS DECIMAL(15,
																  2)) [net_allocation] ,
						T.text [query_text]
			  FROM      sys.dm_db_task_space_usage TS
						INNER JOIN sys.dm_exec_requests ER ON ER.request_id = TS.request_id
															  AND ER.session_id = TS.session_id
						OUTER APPLY sys.dm_exec_sql_text(ER.sql_handle) T
			) T1
			RIGHT JOIN ( SELECT SS.session_id ,
								SS.database_id ,
								CAST(SS.user_objects_alloc_page_count / 128 AS DECIMAL(15,
																  2)) [total_user_objects] ,
								CAST(( SS.user_objects_alloc_page_count
									   - SS.user_objects_dealloc_page_count )
								/ 128 AS DECIMAL(15, 2)) [net_user_objects] ,
								CAST(SS.internal_objects_alloc_page_count / 128 AS DECIMAL(15,
																  2)) [total_internal_objects] ,
								CAST(( SS.internal_objects_alloc_page_count
									   - SS.internal_objects_dealloc_page_count )
								/ 128 AS DECIMAL(15, 2)) [net_internal_objects] ,
								CAST(( SS.user_objects_alloc_page_count
									   + internal_objects_alloc_page_count ) / 128 AS DECIMAL(15,
																  2)) [total_allocation] ,
								CAST(( SS.user_objects_alloc_page_count
									   + SS.internal_objects_alloc_page_count
									   - SS.internal_objects_dealloc_page_count
									   - SS.user_objects_dealloc_page_count )
								/ 128 AS DECIMAL(15, 2)) [net_allocation] ,
								T.text [query_text]
						 FROM   sys.dm_db_session_space_usage SS
								LEFT JOIN sys.dm_exec_connections CN ON CN.session_id = SS.session_id
								OUTER APPLY sys.dm_exec_sql_text(CN.most_recent_sql_handle) T
					   ) T2 ON T1.session_id = T2.session_id

GO

/******
Criacao do SQL Agent - Job MONIT-TEMPDB
******/
USE [msdb]
GO

/****** Object:  Job [MONITORA - TEMPDB]    Script Date: 15/06/2021 17:06:08 ******/
BEGIN TRANSACTION
DECLARE @ReturnCode INT
SELECT @ReturnCode = 0
/****** Object:  JobCategory [[ASS_Manutencao]]    Script Date: 15/06/2021 17:06:08 ******/
IF NOT EXISTS (SELECT name FROM msdb.dbo.syscategories WHERE name=N'[ASS_Manutencao]' AND category_class=1)
BEGIN
EXEC @ReturnCode = msdb.dbo.sp_add_category @class=N'JOB', @type=N'LOCAL', @name=N'[ASS_Manutencao]'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback

END

DECLARE @jobId BINARY(16)
EXEC @ReturnCode =  msdb.dbo.sp_add_job @job_name=N'MONITORA - TEMPDB', 
		@enabled=1, 
		@notify_level_eventlog=0, 
		@notify_level_email=0, 
		@notify_level_netsend=0, 
		@notify_level_page=0, 
		@delete_level=0, 
		@description=N'Monitora utilização do TEMPDB', 
		@category_name=N'[ASS_Manutencao]', 
		@owner_login_name=N'GestaoAmbienteSQL', @job_id = @jobId OUTPUT
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [EXEC dbo.spMonitTempDB]    Script Date: 15/06/2021 17:06:09 ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'EXEC dbo.spMonitTempDB', 
		@step_id=1, 
		@cmdexec_success_code=0, 
		@on_success_action=1, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'EXEC dbo.spMonitTempDB
go', 
		@database_name=N'ADM_BDADOS', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_update_job @job_id = @jobId, @start_step_id = 1
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobschedule @job_id=@jobId, @name=N'Monitora - TEMPDB', 
		@enabled=1, 
		@freq_type=4, 
		@freq_interval=1, 
		@freq_subday_type=1, 
		@freq_subday_interval=0, 
		@freq_relative_interval=0, 
		@freq_recurrence_factor=0, 
		@active_start_date=20210615, 
		@active_end_date=99991231, 
		@active_start_time=45, 
		@active_end_time=235959, 
		@schedule_uid=N'ab9ca5da-6396-4b0a-aa53-9f7d289efe89'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobserver @job_id = @jobId, @server_name = N'(local)'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
COMMIT TRANSACTION
GOTO EndSave
QuitWithRollback:
    IF (@@TRANCOUNT > 0) ROLLBACK TRANSACTION
EndSave:
GO
EXEC dbo.sp_start_job N'MONITORA - TEMPDB' ;  
GO
