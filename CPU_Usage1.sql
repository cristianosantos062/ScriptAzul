USE master
GO

-- ===========================================================
-- Author:      Eli Leiba
-- Create date: 19-09-2019
-- Description: Get the CPU usage percentage for the given database.
--              Result should be a decimal between 0 and 100
-- ===========================================================
CREATE FUNCTION dbo.udf_Get_DB_Cpu_Pct (@dbName sysname)
RETURNS decimal (6, 3)AS
BEGIN
 
   DECLARE @pct decimal (6, 3) = 0

   SELECT @pct = T.[CPUTimeAsPercentage]
   FROM
    (SELECT 
        [Database],
        CONVERT (DECIMAL (6, 3), [CPUTimeInMiliSeconds] * 1.0 / 
        SUM ([CPUTimeInMiliSeconds]) OVER () * 100.0) AS [CPUTimeAsPercentage]
     FROM 
      (SELECT 
          dm_execplanattr.DatabaseID,
          DB_Name(dm_execplanattr.DatabaseID) AS [Database],
          SUM (dm_execquerystats.total_worker_time) AS CPUTimeInMiliSeconds
       FROM sys.dm_exec_query_stats dm_execquerystats
       CROSS APPLY 
        (SELECT 
            CONVERT (INT, value) AS [DatabaseID]
         FROM sys.dm_exec_plan_attributes(dm_execquerystats.plan_handle)
         WHERE attribute = N'dbid'
        ) dm_execplanattr
       GROUP BY dm_execplanattr.DatabaseID
      ) AS CPUPerDb
    )  AS T
   WHERE T.[Database] = @dbName

   RETURN @pct
END
GO
/*
USE master
GO
SELECT dbo.udf_Get_DB_Cpu_Pct ('master')
GO
And the results are on my server:

cpu usage for one database
Report results for all databases in descending CPU usage order:

USE master
GO
SELECT d.name,dbo.udf_Get_DB_Cpu_Pct (d.name) as usagepct
FROM sysdatabases d
ORDER BY usagepct desc
GO
**/