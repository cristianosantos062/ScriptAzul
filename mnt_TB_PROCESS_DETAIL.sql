 /*
 SELECT
    'GuardAppEvent:Start',
    'GuardAppEventType: METADADOS',
    'GuardAppEventStrValue: METADADOS - Limpeza Monitoracao PROCESS_DETAIL';
	
    GO
    SELECT
    'GuardAppEvent:Released';	
*/


SELECT $PARTITION.pfc_TB_PROCESS_DETAIL(a.[collection_time]) AS [Nro_Partition],
       COUNT(*) AS [Rows],
       (SELECT TOP 1 CAST([collection_time] as date) FROM dbo.TB_PROCESS_DETAIL b WHERE a.[collection_time] = b.[collection_time]) AS [Periodo]
  FROM dbo.TB_PROCESS_DETAIL a
 GROUP BY $PARTITION.pfc_TB_PROCESS_DETAIL(a.[collection_time]), a.collection_time
 --ROUP BY [Periodo]
 ORDER BY 1
GO

DECLARE @table sysname  = 'TB_PROCESS_DETAIL'
	SELECT p.partition_number, r.value, p.rows
		FROM sys.tables AS t  (NOLOCK)
		JOIN sys.indexes AS i  (NOLOCK)
			ON t.object_id = i.object_id  
		JOIN sys.partitions AS p (NOLOCK) 
			ON i.object_id = p.object_id AND i.index_id = p.index_id   
		JOIN  sys.partition_schemes AS s   (NOLOCK)
			ON i.data_space_id = s.data_space_id  
		JOIN sys.partition_functions AS f   (NOLOCK)
			ON s.function_id = f.function_id  
		LEFT JOIN sys.partition_range_values AS r   (NOLOCK)
			ON f.function_id = r.function_id and r.boundary_id = p.partition_number  
	WHERE t.name = @table AND i.type <= 1  and rows > 0
		--AND CAST(r.value as datetime)  BETWEEN '2021-03-07'  AND '2021-04-09'
	ORDER BY CAST(r.value as datetime) asc

SELECT 
    partition_number,
    row_count, *
FROM sys.dm_db_partition_stats
WHERE object_id = OBJECT_ID('dbo.TB_PROCESS_DETAIL');

TRUNCATE TABLE dbo.TB_PROCESS_DETAIL WITH (PARTITIONS (1 TO 56))

sp_help 'TB_PROCESS_DETAIL'
SELECT MIN(collection_time) FROM ADM_BDADOS.dbo.TB_PROCESS_DETAIL (NOLOCK)

SELECT * FROM ADM_BDADOS.dbo.TB_PROCESS_DETAIL (NOLOCK)
WHERE database_name = 'CS'
AND collection_time >= '2021-06-22 15:56:00.000' 
--AND  collection_time <= '2021-06-22 15:59:59.997' 
AND  CAST(sql_command AS nvarchar(MAX) ) LIKE '%SPCS_PR_SPB_FIRE_RECEIVE%'
ORDER BY [dd hh:mm:ss.mss] DESC

--13h e terminou por volta de 14h30 do dia 19/05
select CONVERT(nvarchar(11),dt_coleta,110) dt, dbname, SUM(cpu) cpu from TB_MONIT_CPU WHERE dbname NOT IN ('ADM_BDADOS','master','tempdb','msdb','')
--AND dt_coleta  BETWEEN '2021-03-01 00:00:00.000' AND '2021-03-31 23:59:59.983'
--AND dbname = 'CS'
GROUP BY dbname, CONVERT(nvarchar(11),dt_coleta,110)
ORDER BY dt
[DERIVATIVO].[TB3IPOSICAO_FUTURO_PT]
select * from sys.tables where name like 'TDWDVA_%'

SELECT start_time, [dd hh:mm:ss.mss], database_name, wait_info, sql_command,sql_text, query_plan  FROM ADM_BDADOS.dbo.TB_PROCESS_DETAIL
WHERE  start_time 
	BETWEEN '2021-05-12 02:30:00.000' 
	AND '2021-05-12 03:38:00.000' 
	AND database_name = 'SI_DW'
	AND CONVERT(varchar(8000),sql_command) LIKE '%SPU_INS_ADWALOCACAO_DMENOS1%'
