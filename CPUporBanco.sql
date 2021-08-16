WITH DB_CPU_Stats
AS
(SELECT DatabaseID, DB_Name(DatabaseID) AS [Database Name], SUM(total_worker_time) AS [CPU_Time_Ms]
 FROM sys.dm_exec_query_stats AS qs
 CROSS APPLY (SELECT CONVERT(int, value) AS [DatabaseID]
              FROM sys.dm_exec_plan_attributes(qs.plan_handle)
              WHERE attribute = N'dbid') AS F_DB
 GROUP BY DatabaseID)
SELECT ROW_NUMBER() OVER(ORDER BY [CPU_Time_Ms] DESC) AS [CPU Rank],
       [Database Name], [CPU_Time_Ms] AS [CPU Time (ms)],
       CAST([CPU_Time_Ms] * 1.0 / SUM([CPU_Time_Ms]) OVER() * 100.0 AS DECIMAL(5, 2)) AS [CPU Percent]
FROM DB_CPU_Stats
WHERE DatabaseID <> 32767 -- ResourceDB
ORDER BY [CPU Rank] OPTION (RECOMPILE);

with cte as (
	SELECT CONVERT(DATETIME,CONVERT(CHAR(13),CONVERT(DATETIME,start_time,101),121)+':00') start_time, database_name, sum(CPU) cpu
	from (
	SELECT database_name, start_time, session_id, max(cast(replace(isnull(CPU,'0'),',', '') as float)) cpu
	FROM dbo.TB_PROCESS_DETAIL
	WHERE collection_time >= '2021-03-01'
	AND collection_time < '2021-03-06'
	and datepart(hour, start_time) between 8 and 20
	AND database_name != 'ADM_BDADOS'
	-- and session_id = 271
	and host_name ='WEBPOS01104P'
	group by database_name,start_time,session_id
) a
group by CONVERT(DATETIME,CONVERT(CHAR(13),CONVERT(DATETIME,start_time,101),121)+':00'), database_name),
cte1 as (select start_time, sum(cpu) cpu from cte group by start_time),
cte2 as (select cte.start_time, cte.database_name, cte.cpu, round((cte.cpu/cte1.cpu)*100,2) pct_cpu
from cte join cte1 on (cte1.start_time = cte.start_time)),
cte3 as (select start_time, database_name, cpu, pct_cpu, rank() over (partition by start_time order by pct_cpu desc) rnk from cte2)
select start_time, database_name, cpu, pct_cpu from cte3
where rnk <= 5
order by 1, 3 desc