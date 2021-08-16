 select 'sqlcmd -S ' + LTRIM(RTRIM(SERVERWITHPORT)) + ' -U GestaoAmbienteSQL -Q"SET NOCOUNT ON; SET ANSI_WARNINGS OFF; select CAST(SERVERPROPERTY(''ComputerNamePhysicalNetBIOS'') as nvarchar) ComputerNamePhysicalNetBIOS,CAST(SERVERPROPERTY(''InstanceName'') as nvarchar) InstanceName,(select (virtual_address_space_committed_kb/1048576 ) FROM sys.dm_os_process_memory ) as Total_Memory_UsedBySQLServer_gb	,(total_physical_memory_kb/1048576)Phy_Memory_usedby_Sqlserver_gb	,(available_physical_memory_kb/1048576 )available_physical_memory_gb, 	from sys.dm_os_sys_memory" -W -h -1 -P rDBUNX5T >> C:\DBA\MEMORY_USED\memory_used.txt' FROM ADM_INFO.INFO.TB_HOSTNAME_INSTANCE WHERE SERVERWITHPORT NOT IN ('172.16.16.18','172.16.16.18','BMFSB801CIFP\SQL1,1434','SQLCORPA\SQLCORA,1433','BMFSB802CIFP\DEFAULT,1433','BMFSB8037SQLP\SQL1,1434','INFRACORP2\DEFAULT,1433','SECCORP1\SECCORA,1433','SQLCORPBP\SQLCORPBP,1435')

 select 'sqlcmd -S ' + LTRIM(RTRIM(SERVERWITHPORT)) + ' -U GestaoAmbienteSQL -Q"SET NOCOUNT ON; SET ANSI_WARNINGS OFF; select CAST(SERVERPROPERTY(''ComputerNamePhysicalNetBIOS'') as nvarchar) ComputerNamePhysicalNetBIOS,CAST(SERVERPROPERTY(''InstanceName'') as nvarchar) InstanceName,(select (virtual_address_space_committed_kb/1048576 ) FROM sys.dm_os_process_memory ) as Total_Memory_UsedBySQLServer_gb	,(total_physical_memory_kb/1048576)Phy_Memory_usedby_Sqlserver_gb	,(available_physical_memory_kb/1048576 )available_physical_memory_gb, 	from sys.dm_os_sys_memory" -W -1 -P rDBUNX5T -s; -o C:\DBA\MEMORY_USED\memory_used.log >> C:\DBA\MEMORY_USED\memory_used.txt' FROM ADM_INFO.INFO.TB_HOSTNAME_INSTANCE WHERE SERVERWITHPORT NOT IN ('172.16.16.18','172.16.16.18','BMFSB801CIFP\SQL1,1434','SQLCORPA\SQLCORA,1433','BMFSB802CIFP\DEFAULT,1433','BMFSB8037SQLP\SQL1,1434','INFRACORP2\DEFAULT,1433','SECCORP1\SECCORA,1433','SQLCORPBP\SQLCORPBP,1435')


 select 'sqlcmd -S '+instance_name+' -U GestaoAmbienteSQL -Q"SET NOCOUNT ON; SET ANSI_WARNINGS OFF; select CAST(SERVERPROPERTY(''ComputerNamePhysicalNetBIOS'') as nvarchar) ComputerNamePhysicalNetBIOS,CAST(SERVERPROPERTY(''ServerName'') as nvarchar) ServerName,(select (virtual_address_space_committed_kb/1048576 ) FROM sys.dm_os_process_memory ) as Total_Memory_UsedBySQLServer_gb	,(total_physical_memory_kb/1048576)Phy_Memory_usedby_Sqlserver_gb	,(available_physical_memory_kb/1048576 )available_physical_memory_gb, ((select (virtual_address_space_committed_kb/1048576 ) FROM sys.dm_os_process_memory )/(total_physical_memory_kb/1048576)) as Perc_Used	from sys.dm_os_sys_memory" -W -h -1 -P rDBUNX5T -s; >> E:\DBA\MEMORY_USED\memory_used.txt'
	from [DBO].[TB_STORAGE_INFOS] S
	inner join [CTRL].[LISTCONNECT] L ON S.idInstance = L.idInstance
where s.IdProduct = 2


 select
(physical_memory_in_use_kb/1024)Phy_Memory_usedby_Sqlserver_MB,
(locked_page_allocations_kb/1024 )Locked_pages_used_Sqlserver_MB,
(virtual_address_space_committed_kb/1024 )Total_Memory_UsedBySQLServer_MB,
process_physical_memory_low,
process_virtual_memory_low
 FROM sys.dm_os_process_memory

-- (physical_memory_in_use_kb/1048576)Phy_Memory_usedby_Sqlserver_GB,
--(locked_page_allocations_kb/1048576 )Locked_pages_used_Sqlserver_GB,
--(virtual_address_space_committed_kb/1048576 )Total_Memory_UsedBySQLServer_GB,
--process_physical_memory_low,
--process_virtual_memory_low
 select
(total_physical_memory_kb/1024)Phy_Memory_usedby_Sqlserver_gb,
(available_physical_memory_kb/1024 )available_physical_memory_gb
 from sys.dm_os_sys_memory