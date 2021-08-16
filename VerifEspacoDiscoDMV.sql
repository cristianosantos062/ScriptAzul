/*
 SELECT
    'GuardAppEvent:Start',
    'GuardAppEventType: METADADOS',
    'GuardAppEventStrValue: METADADOS';

SELECT
    'GuardAppEvent:Released';	
*/

 SQLBAL00101P.cetip.com.br

--> *********** Mostra todos os volumes montado no servidor

SELECT DISTINCT VS.volume_mount_point [Montagem],
                VS.logical_volume_name AS [Volume],
                CAST(CAST(VS.total_bytes AS DECIMAL(19, 2))/1024 /1024 /1024 AS DECIMAL (10, 2)) AS [Total (GB)],
                CAST(CAST(VS.available_bytes AS DECIMAL(19, 2))/1024 /1024 /1024 AS DECIMAL (10, 2)) AS [Espaço Disponível (GB)],
                CAST((CAST(VS.available_bytes AS DECIMAL(19, 2)) / CAST(VS.total_bytes AS DECIMAL(19, 2)) * 100) AS DECIMAL(10, 2)) AS [Espaço Disponível ( % )],
                CAST((100 - CAST(VS.available_bytes AS DECIMAL(19, 2)) / CAST(VS.total_bytes AS DECIMAL(19, 2)) * 100) AS DECIMAL (10, 2)) AS [Espaço em uso ( % )]
FROM sys.master_files AS MF CROSS APPLY [sys].[dm_os_volume_stats](MF.database_id, MF.FILE_ID) AS VS
WHERE CAST(VS.available_bytes AS DECIMAL(19, 2)) / CAST(VS.total_bytes AS DECIMAL(19, 2)) * 100 < 100
  --AND VS.logical_volume_name = 'MSSQL$SQLBOVA\DATAFILE02'
  AND VS.volume_mount_point LIKE ' F:\SQLBAL002CP_F_ECB_DADOS01%'

  F:\SQLBAL002CP_F_ECB_DADOS01

sp_spaceused 'hst.TDWTM_ALOCACAO_DETALHE'
select DB_NAME(dbid) as Dbname , name, filename, (size*8/1024) size from sys.sysaltfiles 
	where filename LIKE 'F:\SQLCORPOP_F_DADOS\%'



SELECT
S.[name] AS [Logical Name]
,S.[file_id] AS [File ID]
, S.[physical_name] AS [File Name]
,CAST(CAST(G.name AS VARBINARY(256)) AS sysname) AS [FileGroup_Name]
,CONVERT (varchar(10),(S.[size]*8)) + ' KB' AS [Size]
,CASE WHEN S.[max_size]=-1 THEN 'Unlimited' ELSE CONVERT(VARCHAR(10),CONVERT(bigint,S.[max_size])*8) +' KB' END AS [Max Size]
,CASE s.is_percent_growth WHEN 1 THEN CONVERT(VARCHAR(10),S.growth) +'%' ELSE Convert(VARCHAR(10),S.growth*8) +' KB' END AS [Growth]
,Case WHEN S.[type]=0 THEN 'Data Only'
WHEN S.[type]=1 THEN 'Log Only'
WHEN S.[type]=2 THEN 'FILESTREAM Only'
WHEN S.[type]=3 THEN 'Informational purposes Only'
WHEN S.[type]=4 THEN 'Full-text '
END AS [usage]
,DB_name(S.database_id) AS [Database Name]
FROM sys.master_files AS S
LEFT JOIN sys.filegroups AS G ON ((S.type = 2 OR S.type = 0)
AND (S.drop_lsn IS NULL)) AND (S.data_space_id=G.data_space_id)
WHERE S.[physical_name] like ' F:\SQLBAL002CP_F_ECB_DADOS01%'


SELECT databasename AS [Database Name]
      ,name AS [Logical Name]
      ,filename AS [Physical File Name]
      ,growth AS [Auto-grow Setting] FROM #info 
WHERE (usage = 'data only' AND growth = '1024 KB') 
   OR (usage = 'log only' AND growth = '10%')
ORDER BY databasename


ALTER TABLE tableName REBUILD WITH (DATA_COMPRESSION=ROW)
ALTER INDEX EWI5SLN1 ON dbo.EWMISLN1 REBUILD WITH ( DATA_COMPRESSION = PAGE ) ;
GO

	select DB_NAME(database_id), * from  sys.master_files where physical_name like 'F:\SQLBAL002CP_F_ECB_DADos01%'
	order by size desc

SELECT DISTINCT dovs.logical_volume_name AS LogicalName,dovs.volume_mount_point AS Drive,
	CONVERT(INT,dovs.available_bytes/10737426432.0) AS FreeSpaceInGB
FROM sys.master_files mf
	CROSS APPLY sys.dm_os_volume_stats(mf.database_id, mf.FILE_ID) dovs
ORDER BY FreeSpaceInGB ASC
GO

sp_spaceused 'RPA'


DBCC FREEPROCCACHE ()
sp_helpdb 'ECB_BALCAOPROD'
select 152303424/1024
select 2392608/1024


ALTER TABLE Logs REBUILD WITH (DATA_COMPRESSION =  PAGE)
DBCC SHRINKFILE (F_ECB_LOG01, EMPTYFILE);

DBCC SHRINKFILE ('ECB_BALCAOPROD_Data', 304542)

SELECT name ,size/128.0 - CAST(FILEPROPERTY(name, 'SpaceUsed') AS int)/128.0 AS AvailableSpaceInMB
FROM sys.database_files;

433895488 KB
307.200
DBCC SQLPERF(logspace)
DBCC LOGINFO;
BAckup log ECB_BALCAOPROD WITH TRUNCATE_ONLY

SELECT * INTO [dbo].[LogsNew] FROM Logs WHERE TimeStamp > '2021-06-15'


DBCC SHRINKFILE (N'ECB_BALCAOPROD_Log' , 120000, TRUNCATEONLY)
GO



USE [IntegraB3]
GO

/****** Object:  Index [PK_Logs]    Script Date: 17/06/2021 10:29:39 ******/
ALTER TABLE [dbo].[LogsNew] ADD  CONSTRAINT [PK_Logs] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 95) ON [PRIMARY]
GO

INSERT INTO LogsNew ([Id], [Message], [MessageTemplate], [Level], [TimeStamp], [Exception], [Properties])
SELECT [Id], [Message], [MessageTemplate], [Level], [TimeStamp], [Exception], [Properties] FROM Logs WHERE TimeStamp > '2021-06-15'

select top 100 * from Logs
sp_help 'logs'
sp_spaceused 'logs'
select * from sys.sysaltfiles where filename LIKE 'H:\MSSQL$SQLBOVA\DATAFILE02%'
ORDER BY size DESC

SELECT MIN(TimeStamp) FROM Logs (NOLOCK)
sp_spaceused 'logs'

SELECT name, recovery_model_desc  
   FROM sys.databases  
      WHERE name = 'model' ;  
GO

SELECT * FROM sys.sysdatabases

DBCC SHRINKFILE(2,


--->>>> Tamanho da tabelas
SELECT
	s.Name AS SchemaName,
	t.Name AS TableName,
	p.rows AS RowCounts,
	CAST(ROUND((SUM(a.used_pages) / 128.00), 2) AS NUMERIC(36, 2)) AS Used_MB,
	CAST(ROUND((SUM(a.total_pages) - SUM(a.used_pages)) / 128.00, 2) AS NUMERIC(36, 2)) AS Unused_MB,
	CAST(ROUND((SUM(a.total_pages) / 128.00), 2) AS NUMERIC(36, 2)) AS Total_MB
FROM sys.tables t
	INNER JOIN sys.indexes i ON t.OBJECT_ID = i.object_id
	INNER JOIN sys.partitions p ON i.object_id = p.OBJECT_ID AND i.index_id = p.index_id
	INNER JOIN sys.allocation_units a ON p.partition_id = a.container_id
	INNER JOIN sys.schemas s ON t.schema_id = s.schema_id
GROUP BY t.Name, s.Name, p.Rows
--ORDER BY s.Name, t.Name
ORDER BY Used_MB DESC
GO

SELECT MIN(DATA_PREG) FROM TDIMOVI_AVIS_NEG_ACAO (NOLOCK)
--->>> Nome fisico de servidor
SELECT   @@SERVERNAME ServerName_Global_Variable
,SERVERPROPERTY('ServerName') ServerName
,SERVERPROPERTY('InstanceName') InstanceName
,SERVERPROPERTY('MachineName') MachineName
,SERVERPROPERTY('ComputerNamePhysicalNetBIOS') ComputerNamePhysicalNetBIOS
GO

SELECT DISTINCT
    objects.name AS Table_name,
    indexes.name AS Index_name,
    dm_db_index_usage_stats.user_seeks,
    dm_db_index_usage_stats.user_scans,
    dm_db_index_usage_stats.user_updates
FROM
    sys.dm_db_index_usage_stats
    INNER JOIN sys.objects ON dm_db_index_usage_stats.OBJECT_ID = objects.OBJECT_ID
    INNER JOIN sys.indexes ON indexes.index_id = dm_db_index_usage_stats.index_id AND dm_db_index_usage_stats.OBJECT_ID = indexes.OBJECT_ID
WHERE
    --dm_db_index_usage_stats.user_lookups = 0
     --dm_db_index_usage_stats.user_seeks = 0
    --AND  dm_db_index_usage_stats.user_scans = 0
	 objects.OBJECT_ID = OBJECT_ID('TCSLANC_FINA')
ORDER BY
    dm_db_index_usage_stats.user_updates DESC

xp_readerrorlog
---
SELECT DB_NAME() AS DbName, 
    name AS FileName, 
    type_desc,
    CAST( size/128.0 AS DECIMAL(11,2) ) AS CurrentSizeMB,  
    CAST( (size/128.0  - CAST(FILEPROPERTY(name, 'SpaceUsed') AS int)/128.0) AS DECIMAL(11,2) ) AS FreeSpaceMB
FROM sys.database_files
WHERE type IN (0,1);


select * FROM sys.sysaltfiles WHERE filename LIKE 'H:\MSSQL$SQLBOVA\DATAFILE03%'

select * from sys.sysaltfiles where filename like '%ldf%'

--> *********** Mostra todos os arquivos no volume
--> *********** Percentual de uso por arquivo por volumes montado no servidor

DECLARE @dir NVARCHAR(260) ;
SELECT  @dir = 'J:\DATATARIFACAO02\' ;
--EXEC xp_dirtree @dir, 1, 1 ;
IF RIGHT(@dir, 1) <> '\' 
    SELECT  @dir = @dir + '\' ;

IF OBJECT_ID('tempdb..#dirtree', 'U') IS NOT NULL 
    DROP TABLE #dirtree ;
CREATE TABLE #dirtree
(
 id INT PRIMARY KEY
        IDENTITY,
 subdirectory NVARCHAR(260),
 depth INT,
 is_file BIT
) ;

INSERT  INTO #dirtree EXEC xp_dirtree @dir, 1, 1 ;

--SELECT  * FROM    #dirtree ;

WITH    files
          AS (
              SELECT    id,
                        subdirectory,
                        depth,
                        is_file, subdirectory AS path
              FROM      #dirtree
              WHERE     is_file = 1
                        --AND depth <> 1
             )
    SELECT  *   FROM    files 
	 
DROP TABLE #dirtree


select * from sys.sysaltfiles where filename like 'N:\SQLSINFEP_N_Dados20%'
order by size desc


sp_spaceused

Select
		ServerProperty ('ComputerNamePhysicalNetBIOS') as 'Active_Node'
        , Db_Name (mf.database_id) as 'DBName'
        , Case When mf.type = 0 Then 'Dados' Else 'Log' End as 'Archive_Type'
        , mf.name as 'Logical_name'
        , mf.physical_name  as 'Physical_name'
        , Cast (mf.size / 128. as Decimal(19,2)) as 'Space_allocated_MB'
        , Isnull (Cast ((FileProperty (mf.name, 'SpaceUsed') / 128.) as Decimal(19,2)), 0) as 'Spaced_Used_MB'

		, ((mf.size/FileProperty (mf.name, 'SpaceUsed')) / 128.)*100 as 'Percent_Used'
		, CAST ( ((((FileProperty (mf.name, 'SpaceUsed')/mf.size) / 128.)*100)) as DECIMAL(19,2)) as 'Percent_Used'

        , Case When (max_size in (-1,268435456)) Then 'unlimited' Else Cast((max_size/128) as Varchar) End as 'Max_Size'
        , Case When (is_percent_growth = 1) Then growth Else (growth / 128) End as 'Growth'
 --       , Case is_percent_growth When 1 Then 'PERCENT' When 0 Then 'MB' End as 'Percent_Growth'
        , fg.name 'Filegroup_Name'
--        , Getdate () as 'LogDate'
        From
                sys.master_files mf 
                Inner Join master.sys.databases db On (mf.database_id = db.database_id)
                Left Join sys.filegroups fg               On (fg.data_space_id = mf.data_space_id)
        Where 
                db.database_id = db_id()
        And mf.state_desc = 'ONLINE';

SELECT name ,ROUND(((size/128.0)/1024 - (CAST(FILEPROPERTY(name, 'SpaceUsed') AS int)/128.0)/1024.0),2) AS AvailableSpaceInMB, physical_name
FROM sys.database_files  
ORDER BY name;

select * from sys.sysfiles
select * from sys.sysaltfiles where filename like '%PERCEPTION43_Data%'

-- Shrink the file to MB.
DBCC SHRINKFILE('CS_data_05', 105000)


SELECT * FROM [ADM_BDADOS].[dbo].[TB_TIME_DISKS_DETAILS] WHERE volume_mount_point = 'N:\MSSQL$SQLBOVA\DATAFILE03\'
SELECT DB_NAME(database_id) AS database_name, 
    type_desc, 
    name AS FileName, 
    size/128.0 AS CurrentSizeMB
FROM sys.master_files
WHERE database_id > 6 AND type IN (0,1) AND Name like '%ADM_BDADOS%'


select * from sys.sysprocesses where loginame like '%p-aalonso%'

SELECT   @@SERVERNAME ServerName_Global_Variable
,SERVERPROPERTY('ServerName') ServerName
,SERVERPROPERTY('InstanceName') InstanceName
,SERVERPROPERTY('MachineName') MachineName
,SERVERPROPERTY('ComputerNamePhysicalNetBIOS') ComputerNamePhysicalNetBIOS


select count(last_execution_time) from TB_TIME_PROCS_DETAILS where last_execution_time < '2020-11-01 00:00:00.000'

sp_estimate_data_compression_savings   
      'dbo'    
   , 'TB_TIME_PROCS_DETAILS'   
   , NULL, NULL, 'PAGE'

   ALTER TABLE dbo.TB_TIME_PROCS_DETAILS REBUILD PARTITION = ALL  
WITH (DATA_COMPRESSION = PAGE); 


select * from sys.sysprocesses where nt_username like 'p-aalonso%'

select 'ALTER TABLE dbo.'+name+' REBUILD PARTITION = ALL WITH (DATA_COMPRESSION = PAGE);
GO' from sys.tables WHERE type = 'U' AND name NOT LIKE '*SYS*'
 
select 'ALTER TABLE dbo.'+OBJECT_NAME(id)+' REBUILD PARTITION = ALL WITH (DATA_COMPRESSION = PAGE);
GO' from sys.sysindexes WHERE indid in (1,0) 
ORDER BY rowcnt DESC


DBCC SHRINKFILE (HFSMP_3,EMPTYFILE)
GO
ALTER DATABASE HFSMP  
REMOVE FILE HFSMP_3;  
GO
