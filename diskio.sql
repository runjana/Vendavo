-- Get I/O utilization by database (Query 31) (IO Usage By Database)
 WITH Aggregate_IO_Statistics
 AS
 (SELECT DB_NAME(database_id) AS [Database Name],
 CAST(SUM(num_of_bytes_read + num_of_bytes_written)/1048576 AS DECIMAL(12, 2)) AS io_in_mb
 FROM sys.dm_io_virtual_file_stats(NULL, NULL) AS [DM_IO_STATS]
 GROUP BY database_id)
 SELECT ROW_NUMBER() OVER(ORDER BY io_in_mb DESC) AS [I/O Rank], [Database Name], io_in_mb AS [Total I/O (MB)],
        CAST(io_in_mb/ SUM(io_in_mb) OVER() * 100.0 AS DECIMAL(5,2)) AS [I/O Percent]
 FROM Aggregate_IO_Statistics
 ORDER BY [I/O Rank] OPTION (RECOMPILE);
  
 -- Helps determine which database is using the most I/O resources on the instance
 
 
 /*****	Script: Database Wise CPU Utilization report *****/
/*****	Support: SQL Server 2008 and Above *****/
/*****	TestedOn: SQL Server 2008 R2 and 2014 *****/
/*****	Output: 
SNO: Serial Number
DBName: Databse Name 
CPU_Time(Ms): CPU Time in Milliseconds
CPUPercent: Let’s say this instance is using 50% CPU and one of the database is      using 80%. It means the actual CPU usage from the database is calculated as: (80 / 100) * 50 = 40 %
*****/
WITH DB_CPU AS
(SELECT	DatabaseID, 
		DB_Name(DatabaseID)AS [DatabaseName], 
		SUM(total_worker_time)AS [CPU_Time(Ms)] 
FROM	sys.dm_exec_query_stats AS qs 
CROSS APPLY(SELECT	CONVERT(int, value)AS [DatabaseID]  
			FROM	sys.dm_exec_plan_attributes(qs.plan_handle)  
			WHERE	attribute =N'dbid')AS epa GROUP BY DatabaseID) 
SELECT	ROW_NUMBER()OVER(ORDER BY [CPU_Time(Ms)] DESC)AS [SNO], 
	DatabaseName AS [DBName], [CPU_Time(Ms)], 
	CAST([CPU_Time(Ms)] * 1.0 /SUM([CPU_Time(Ms)]) OVER()* 100.0 AS DECIMAL(5, 2))AS [CPUPercent] 
FROM	DB_CPU 
WHERE	DatabaseID > 4 -- system databases 
	AND DatabaseID <> 32767 -- ResourceDB 
ORDER BY SNO OPTION(RECOMPILE); 