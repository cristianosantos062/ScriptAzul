SELECT sh.[name] as [schema_name]
	, so.[name] as [table_name]
	, st.[name] as [stats_name]
	, st.[stats_id]
	, sc.[stats_column_id]
	, cl.[name] as [column_name]
	, st.[auto_created]
	, st.[filter_definition]
	, sp.[last_updated]
	, sp.[rows]
	, CAST((sp.[rows_sampled]*1.00/sp.[rows]*1.00)*100 as decimal(8,2)) as [pct_sampled]
	, sp.[steps]
	, 'DBCC SHOW_STATISTICS (''' + sh.[name] + '.' + so.[name] + ''', ''' + st.[name] + ''')' as [dbcc_showstats_cmd]
	, 'DROP STATISTICS ' + sh.[name] + '.' + so.[name] + '.' + st.[name] + '' as [drop_stat_cmd]
FROM sys.stats st
JOIN sys.stats_columns sc ON st.[object_id] = sc.[object_id] AND st.[stats_id] = sc.[stats_id]
JOIN sys.columns cl ON sc.[object_id] = cl.[object_id] AND sc.[column_id] = cl.[column_id]
JOIN sys.objects so ON so.[object_id] = st.[object_id]
JOIN sys.schemas sh ON so.[schema_id] = sh.[schema_id]
CROSS APPLY sys.dm_db_stats_properties(st.[object_id], st.[stats_id]) sp
WHERE sh.[name] = 'hst' AND so.[name] IN ('TDWTRADING_OFERTA_COMPRA', 'TDWTRADING_OFERTA_VENDA')
--AND st.[stats_id] <> 1
ORDER BY sh.[name], so.[name], st.[stats_id], sc.[column_id]