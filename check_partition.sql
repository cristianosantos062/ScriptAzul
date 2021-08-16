 /*
 SELECT
    'GuardAppEvent:Start',
    'GuardAppEventType: REQ000002080432',
    'GuardAppEventStrValue: REQ000002080432';
	
    GO
    SELECT
    'GuardAppEvent:Released';	
*/

--SELECT t.name AS TableName, i.name AS IndexName, p.partition_number, p.partition_id, i.data_space_id,
--	f.function_id, f.type_desc, r.boundary_id, r.value AS BoundaryValue
SELECT t.name AS TableName, i.name AS IndexName, p.partition_number, p.rows, r.value AS BoundaryValue, f.name, s.name
FROM sys.tables AS t
	JOIN sys.indexes AS i ON t.object_id = i.object_id
	JOIN sys.partitions AS p ON i.object_id = p.object_id AND i.index_id = p.index_id
	JOIN sys.partition_schemes AS s ON i.data_space_id = s.data_space_id
	JOIN sys.partition_functions AS f ON s.function_id = f.function_id
	LEFT JOIN sys.partition_range_values AS r ON f.function_id = r.function_id and r.boundary_id = p.partition_number
WHERE t.name = 'TDWTRADING_OFERTA_COMPRA' AND i.name=  'HST.IC01_TDWTRADING_OFERTA_COMPRA'
ORDER BY r.value DESC;


DECLARE @table sysname  = 'TB3INEGOCIACAO_ATIVO_PT'
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
	WHERE t.object_id = 876035098 AND i.type <= 1  and rows > 0
		--AND CAST(r.value as datetime)  BETWEEN '2021-03-07'  AND '2021-04-09'
	ORDER BY CAST(r.value as datetime) asc