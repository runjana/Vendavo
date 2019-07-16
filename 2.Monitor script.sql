CREATE FUNCTION [dbo].[fn_Split](
    @sInputList NVARCHAR(MAX) -- List of delimited items
  , @sDelimiter NVARCHAR(MAX) = ',' -- delimiter that separates items
) RETURNS @List TABLE (item NVARCHAR(MAX))

BEGIN
DECLARE @sItem NVARCHAR(MAX)
WHILE CHARINDEX(@sDelimiter,@sInputList,0) <> 0
 BEGIN
 SELECT
  @sItem=RTRIM(LTRIM(SUBSTRING(@sInputList,1,CHARINDEX(@sDelimiter,@sInputList,0)-1))),
  @sInputList=RTRIM(LTRIM(SUBSTRING(@sInputList,CHARINDEX(@sDelimiter,@sInputList,0)+LEN(@sDelimiter),LEN(@sInputList))))
 
 IF LEN(@sItem) > 0
  INSERT INTO @List SELECT @sItem
 END

IF LEN(@sInputList) > 0
 INSERT INTO @List SELECT @sInputList
RETURN
END

GO


----------------------------------------------------------------


IF OBJECT_ID('Monitoring.CollectData','P') IS NOT NULL
DROP PROCEDURE Monitoring.CollectData
GO 

CREATE PROCEDURE Monitoring.CollectData
AS
BEGIN
SET NOCOUNT ON


    DECLARE @CurrentTime datetime = GETDATE()
    DECLARE @StepName nvarchar(100)

    -- list of db's to monitor
    DECLARE @DBList TABLE (dbName nvarchar(100))
    INSERT INTO @DBList (dbName)
    SELECT item from dbo.fn_split((select value FROM dbo.SystemParameter sp WHERE name = 'MonitoringDatabaseList'),',') 

    -- Long duration
    ----------------
    SET @StepName = 'Long duration'
    IF Monitoring.NextExecutionTime(@StepName) <= @CurrentTime 
    BEGIN
	   insert into Monitoring.LongDuration (session_id,DatabaseName,host_name,program_name,command,status,QueryText,Current_Statement,logical_reads,writes,row_count,start_time,duration, wait_time,blocking_session_id,last_wait_type, CaptureDate)
	   SELECT a.session_id, 
			DB_NAME(a.database_id) DatabaseName, 
			s.host_name,
			s.program_name,
			command, 
			a.status,
			b.text as QueryText,
      SUBSTRING (b.text, a.statement_start_offset/2,
            (CASE WHEN a.statement_end_offset = -1
              THEN LEN(CONVERT(NVARCHAR(MAX), b.text)) * 2
              ELSE a.statement_end_offset 
              END - a.statement_start_offset
              )/2
            ) Current_Statement,
			a.logical_reads,
			a.writes, 
			a.row_count,  
			start_time,
			datediff(ss,start_time,getdate()) as duration,
			wait_time,  
			blocking_session_id, 
			last_wait_type,
			@CurrentTime -- GETDATE()
	   FROM sys.dm_exec_requests a 
	   INNER JOIN sys.dm_exec_sessions s ON a.session_id = s.session_id
	   OUTER APPLY sys.dm_exec_sql_text(a.sql_handle) b 
	   WHERE a.session_id > 50
	   and a.session_id <> @@SPID
	   AND  DB_NAME(a.database_id) IN  (SELECT dbName FROM @DBList) 
	   AND (a.logical_reads > 10000 or start_time <= dateadd(s,-10,getdate()))

	   UPDATE s SET LastExecutionTime = @CurrentTime
	   FROM Monitoring.Schedule s
	   WHERE StepName = @StepName
    END


    -- Performance counters
    -----------------------
    SET @StepName = 'Performance counters'
    IF Monitoring.NextExecutionTime(@StepName) <= @CurrentTime 
    BEGIN

	   DECLARE @PerfCounters TABLE
		  (
		    [Counter] NVARCHAR(770) ,
		    [CounterType] INT ,
		    [FirstValue] DECIMAL(38, 2) ,
		    [FirstDateTime] DATETIME ,
		    [SecondValue] DECIMAL(38, 2) ,
		    [SecondDateTime] DATETIME ,
		    [ValueDiff] AS ( [SecondValue] - [FirstValue] ) ,
		    [TimeDiff] AS ( DATEDIFF(SS, FirstDateTime, SecondDateTime) ) ,
		    [CounterValue] DECIMAL(38, 2)
		  );

	   DECLARE @CountersList TABLE (CounterName nvarchar(1000))
	   INSERT INTO @CountersList VALUES 
	   ('Page life expectancy'),('Lazy writes/sec'),('Page reads/sec'),('Page writes/sec'),('Free Pages'),('Free list stalls/sec'),
	   ('User Connections'),('Lock Waits/sec'),('Number of Deadlocks/sec'),('Transactions/sec'),('Forwarded Records/sec'),
	   ('Index Searches/sec'),('Full Scans/sec'),('Batch Requests/sec'),('SQL Compilations/sec'),('SQL Re-Compilations/sec'),
	   ('Total Server Memory (KB)'),('Target Server Memory (KB)'),('Page Splits/sec'),('Latch Waits/sec')

	   INSERT  INTO @PerfCounters ( [Counter] ,[CounterType] , [FirstValue] , [FirstDateTime] )
			 SELECT  RTRIM([object_name]) + N':' + RTRIM([counter_name]) + N':'
				    + RTRIM([instance_name]),
				    [cntr_type] ,
				    [cntr_value] ,
				    GETDATE()
			 FROM    sys.dm_os_performance_counters
			 WHERE   [counter_name] COLLATE Latin1_General_CI_AS_KS_WS IN (SELECT CounterName FROM @CountersList)
			 ORDER BY [object_name] + N':' + [counter_name] + N':' + [instance_name];

	   WAITFOR DELAY '00:00:10';

	   UPDATE  @PerfCounters
	   SET     [SecondValue] = [cntr_value] ,
			 [SecondDateTime] = GETDATE()
	   FROM    sys.dm_os_performance_counters
	   WHERE   [Counter] COLLATE Latin1_General_CI_AS_KS_WS = RTRIM([object_name]) + N':' + RTRIM([counter_name]) + N':' + RTRIM([instance_name]) 
			 AND [counter_name] COLLATE Latin1_General_CI_AS_KS_WS IN (SELECT CounterName FROM @CountersList) 

	   UPDATE  @PerfCounters
	   SET     [CounterValue] = [ValueDiff] / [TimeDiff]
	   WHERE   [CounterType] = 272696576;

	   UPDATE  @PerfCounters
	   SET     [CounterValue] = [SecondValue]
	   WHERE   [CounterType] <> 272696576;

	   INSERT  INTO Monitoring.PerformanceCounters ([Counter] ,[Value] ,[CaptureDate])
	   SELECT  [Counter], [CounterValue], [SecondDateTime]
	   FROM    @PerfCounters;

	   UPDATE s SET LastExecutionTime = @CurrentTime
	   FROM Monitoring.Schedule s
	   WHERE StepName = @StepName

    END
    
    -- Server configurations
    ------------------------
    SET @StepName = 'Server Configurations'
    IF Monitoring.NextExecutionTime(@StepName) <= @CurrentTime
    BEGIN

    INSERT INTO [Monitoring].[ServerConfigurations]
		  ( [ConfigurationID],[Name], [Value] ,[ValueInUse] ,[CaptureDate])
		  SELECT  [configuration_id], [name], [value], [value_in_use], @CurrentTime
		  FROM  [sys].[configurations];

	   UPDATE s SET LastExecutionTime = @CurrentTime
	   FROM Monitoring.Schedule s
	   WHERE StepName = @StepName

    END

    -- File info
    ------------
    SET @StepName = 'File info'
    IF Monitoring.NextExecutionTime(@StepName) <= @CurrentTime
    BEGIN

	    DECLARE @sqlstring NVARCHAR(MAX);
	    DECLARE @DBName NVARCHAR(257);
	   -- DECLARE @CaptureDate datetime = GETDATE()
	
	    DECLARE DBCursor CURSOR LOCAL FORWARD_ONLY STATIC READ_ONLY
	    FOR
		    SELECT  QUOTENAME([name])
		    FROM    [sys].[databases]
		    WHERE   [state] = 0 -- only active databases
		    AND [name] COLLATE Latin1_General_CI_AS_KS_WS IN (SELECT dbName FROM @DBList)
		    ORDER BY [name];

	    BEGIN
		    OPEN DBCursor;
		    FETCH NEXT FROM DBCursor INTO @DBName;
		    WHILE @@FETCH_STATUS <> -1 
			    BEGIN
				    --SET @sqlstring = N'USE ' + @DBName + ' ;
		 
			SET @sqlstring = N'
			 INSERT [Monitoring].[FileInfo] (
			 [DatabaseName],
			 [FileID],
			 [Type],
			 [DriveLetter],
			 [LogicalFileName],
			 [PhysicalFileName],
			 [SizeMB],
			 [SpaceUsedMB],
			 [FreeSpaceMB],
			 [MaxSize],
			 [IsPercentGrowth],
			 [Growth],
			 [CaptureDate]
			 )
			 SELECT ''' + @DBName
					    + ''' 
			 ,[file_id],
			  [type],
			 substring([physical_name],1,1),
			 [name],
			 [physical_name],
			 CAST([size] as DECIMAL(38,0))/128., 
			 CAST(FILEPROPERTY([name],''SpaceUsed'') AS DECIMAL(38,0))/128., 
			 (CAST([size] as DECIMAL(38,0))/128) - (CAST(FILEPROPERTY([name],''SpaceUsed'') AS DECIMAL(38,0))/128.),
			 [max_size],
			 [is_percent_growth],
			 [growth],
			  ''' + convert(nvarchar(max), @CurrentTime, 121) + '''
			 FROM ' + @DBName + '.[sys].[database_files];'
				    EXEC (@sqlstring)
				    FETCH NEXT FROM DBCursor INTO @DBName;
			    END

		    CLOSE DBCursor;
		    DEALLOCATE DBCursor;
	    END

	 UPDATE s SET LastExecutionTime = @CurrentTime
	   FROM Monitoring.Schedule s
	   WHERE StepName = @StepName

    END

    -- Wait statistics
    ------------------
    SET @StepName = 'Wait statistics'

    IF Monitoring.NextExecutionTime(@StepName) <= @CurrentTime
    BEGIN
    
     ; WITH [Waits] AS
         (SELECT
            [wait_type],
            [wait_time_ms] / 1000.0 AS [WaitS],
            ([wait_time_ms] - [signal_wait_time_ms]) / 1000.0 AS [ResourceS],
            [signal_wait_time_ms] / 1000.0 AS [SignalS],
            [waiting_tasks_count] AS [WaitCount],
            100.0 * [wait_time_ms] / SUM ([wait_time_ms]) OVER() AS [Percentage],
            ROW_NUMBER() OVER(ORDER BY [wait_time_ms] DESC) AS [RowNum]
         FROM sys.dm_os_wait_stats
         WHERE [wait_type] NOT IN (
            N'CLR_SEMAPHORE',   N'LAZYWRITER_SLEEP',
            N'RESOURCE_QUEUE',  N'SQLTRACE_BUFFER_FLUSH',
            N'SLEEP_TASK',      N'SLEEP_SYSTEMTASK',
            N'WAITFOR',         N'HADR_FILESTREAM_IOMGR_IOCOMPLETION',
            N'CHECKPOINT_QUEUE', N'REQUEST_FOR_DEADLOCK_SEARCH',
            N'XE_TIMER_EVENT',   N'XE_DISPATCHER_JOIN',
            N'LOGMGR_QUEUE',     N'FT_IFTS_SCHEDULER_IDLE_WAIT',
            N'BROKER_TASK_STOP', N'CLR_MANUAL_EVENT',
            N'CLR_AUTO_EVENT',   N'DISPATCHER_QUEUE_SEMAPHORE',
            N'TRACEWRITE',       N'XE_DISPATCHER_WAIT',
            N'BROKER_TO_FLUSH',  N'BROKER_EVENTHANDLER',
            N'FT_IFTSHC_MUTEX',  N'SQLTRACE_INCREMENTAL_FLUSH_SLEEP',
            N'DIRTY_PAGE_POLL')
         )
	    INSERT  INTO Monitoring.WaitStatistics ( [CaptureDate], [WaitType], [Wait_S], [Resource_S], [Signal_S], [WaitCount], [Percentage], [AvgWait_S], [AvgRes_S], [AvgSig_S])
      SELECT
         @CurrentTime,
         [W1].[wait_type] AS [WaitType], 
         CAST ([W1].[WaitS] AS DECIMAL(14, 2)) AS [Wait_S],
         CAST ([W1].[ResourceS] AS DECIMAL(14, 2)) AS [Resource_S],
         CAST ([W1].[SignalS] AS DECIMAL(14, 2)) AS [Signal_S],
         [W1].[WaitCount] AS [WaitCount],
         CAST ([W1].[Percentage] AS DECIMAL(4, 2)) AS [Percentage],
         CAST (([W1].[WaitS] / [W1].[WaitCount]) AS DECIMAL (14, 4)) AS [AvgWait_S],
         CAST (([W1].[ResourceS] / [W1].[WaitCount]) AS DECIMAL (14, 4)) AS [AvgRes_S],
         CAST (([W1].[SignalS] / [W1].[WaitCount]) AS DECIMAL (14, 4)) AS [AvgSig_S]
      FROM [Waits] AS [W1]
      INNER JOIN [Waits] AS [W2]
         ON [W2].[RowNum] <= [W1].[RowNum]
      GROUP BY [W1].[RowNum], [W1].[wait_type], [W1].[WaitS], 
         [W1].[ResourceS], [W1].[SignalS], [W1].[WaitCount], [W1].[Percentage]
      HAVING SUM ([W2].[Percentage]) - [W1].[Percentage] < 95;

	  UPDATE s SET LastExecutionTime = @CurrentTime
	 FROM Monitoring.Schedule s
	 WHERE StepName = @StepName

    END

    -- Delete old data
    SET @StepName = 'Delete old monitoring data'

    IF Monitoring.NextExecutionTime(@StepName) <= @CurrentTime
    BEGIN

	   --DECLARE @CurrentTime datetime = GETDATE()
	   DECLARE @DeleteOldData TABLE (ResultsetTable nvarchar(100), deleteOlderThanDate datetime)

	   ;WITH CTE as (
		  SELECT s.ResultsetTable, s.NumberOfDaysToKeepResults AS KeepDays
		  FROM Monitoring.Schedule s
		  WHERE s.NumberOfDaysToKeepResults > 0
		  AND isnull(s.ResultsetTable,'') <> ''
	   )
	   INSERT INTO @DeleteOldData (ResultsetTable,deleteOlderThanDate)
	   SELECT ResultsetTable,dateadd(dd,-KeepDays,@CurrentTime) - cast(@CurrentTime AS time) AS deleteOlderThanDate
	   FROM CTE

	   DECLARE @DeleteSQL NVARCHAR(MAX);
	   DECLARE @ResultsetTable nvarchar(100)
	   DECLARE @deleteOlderThanDate datetime

	   DECLARE DBCursor CURSOR LOCAL FORWARD_ONLY STATIC READ_ONLY
	   FOR
		  SELECT ResultsetTable,deleteOlderThanDate 
		  FROM @DeleteOldData
	   BEGIN
		  OPEN DBCursor;
			  FETCH NEXT FROM DBCursor INTO @ResultsetTable,@deleteOlderThanDate 
			  WHILE @@FETCH_STATUS <> -1 
			  BEGIN
			    SET @DeleteSQL = N'DELETE FROM Monitoring.' + @ResultsetTable + ' where CaptureDate < ''' + cast(@deleteOlderThanDate AS nvarchar(50)) + ''''
			    exec (@DeleteSQL)
	  
			    FETCH NEXT FROM DBCursor INTO @ResultsetTable,@deleteOlderThanDate; 
			  END
		  CLOSE DBCursor;
		  DEALLOCATE DBCursor;
	   END

	 UPDATE s SET LastExecutionTime = @CurrentTime
	 FROM Monitoring.Schedule s
	 WHERE StepName = @StepName

    END

END

GO