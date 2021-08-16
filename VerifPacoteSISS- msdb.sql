DECLARE @nome_do_pacote SYSNAME
SET @nome_do_pacote = 'SSIS_CIP_CARGA_RTC_NSIDR_IMBARQ5'
select cast(cast(cast(packagedata as varbinary(max)) as varchar(max)) as xml) from sysssispackages where [name] = @nome_do_pacote

SELECT   @@SERVERNAME ServerName_Global_Variable
,SERVERPROPERTY('ServerName') ServerName
,SERVERPROPERTY('InstanceName') InstanceName
,SERVERPROPERTY('MachineName') MachineName
,SERVERPROPERTY('ComputerNamePhysicalNetBIOS') ComputerNamePhysicalNetBIOS
GO
kill 165
EXEC [dbo].[sp_WhoIsActive]
		--@not_filter = 'NSPP93969',				
		--,@not_filter_type = 'host',	-- session, program, database, login, and host
		@filter = 'msdb',
		@filter_type  = 'database',		-- session, program, database, login, and host
 		@get_outer_command =	1,
		--,@get_locks = 1,
		@show_sleeping_spids  = 1,
		@get_plans = 1,
		@output_column_list =	'[dd hh:mm:ss.mss][session_id][database_name][login_name][host_name][start_time][wait_info][status][sql_command][blocking_session_id][open_tran_count][CPU][reads][writes][percent_complete][sql_command][query_plan][sql_text]'
		--@destination_table =	'#Resultado_WhoisActive',
		--Help! Descomentar a linha abaixo
		--,@help = 1

select * from sys.sysprocesses where program_name like 'Microsoft SQL Server Management Studio%'