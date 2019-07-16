-- instructions:
-- Replace string ##DatabaseName## with valid database name

GO
SET NOCOUNT ON;
GO

-- new schema
IF NOT EXISTS (SELECT null FROM sys.schemas WHERE name = 'Monitoring')
BEGIN
  EXEC ('CREATE SCHEMA [Monitoring]')
END
GO

-- scheduler table
--DROP TABLE Monitoring.Schedule


CREATE TABLE Monitoring.Schedule
(
   StepName nvarchar(100) NOT NULL,
   Occurrence int,
   OccurrencePeriod nvarchar(10) NOT null, --'Min,Hour,Day,Week,Month'
   StartTime time null,
   EndTime time null,
   LastExecutionTime datetime null,
   ResultsetTable nvarchar(100),
   NumberOfDaysToKeepResults int null,
   Description nvarchar(1000) null
)
GO

CREATE UNIQUE CLUSTERED INDEX PK_MonitoringSchedule_StepName ON Monitoring.Schedule(StepName)
GO

ALTER TABLE Monitoring.Schedule
ADD CONSTRAINT chk_MonitoringSchedule_OccurrencePeriod CHECK (OccurrencePeriod in ('minute','hour','day','week','month'))
GO

ALTER TABLE Monitoring.Schedule
ADD CONSTRAINT chk_MonitoringSchedule_Occurrence CHECK (Occurrence > 0)
GO

CREATE TABLE [Monitoring].[LongDuration](
	[session_id] [smallint] NOT NULL,
	[DatabaseName] [nvarchar](128) NULL,
	[host_name] [nvarchar](128) NULL,
	[program_name] [nvarchar](128) NULL,
	[command] [nvarchar](16) NOT NULL,
	[status] [nvarchar](30) NOT NULL,
	[QueryText] [nvarchar](max) NULL,
  [Current_Statement] [nvarchar](max) NULL,
	[logical_reads] [bigint] NOT NULL,
	[writes] [bigint] NOT NULL,
	[row_count] [bigint] NOT NULL,
	[query_plan] [xml] NULL,
	[start_time] [datetime] NOT NULL,
	[duration] [int] NULL,
	[wait_time] [int] NOT NULL,
	[blocking_session_id] [smallint] NULL,
	[last_wait_type] [nvarchar](60) NOT NULL,
	[CaptureDate] [datetime] NOT NULL
) ON [PRIMARY]
GO

CREATE TABLE [Monitoring].[PerformanceCounters](
	[Counter] [nvarchar](770) NULL,
	[Value] [decimal](38, 2) NULL,
	[CaptureDate] [datetime] NULL
) ON [PRIMARY]
GO

CREATE TABLE [Monitoring].[ServerConfigurations](
	[ConfigurationID] [int] NOT NULL,
	[Name] [nvarchar](35) NOT NULL,
	[Value] [sql_variant] NULL,
	[ValueInUse] [sql_variant] NULL,
	[CaptureDate] [datetime] NULL
) ON [PRIMARY]
GO

CREATE TABLE [Monitoring].[FileInfo](
	[DatabaseName] [sysname] NOT NULL,
	[FileID] [int] NOT NULL,
	[Type] [tinyint] NOT NULL,
	[DriveLetter] [nvarchar](1) NULL,
	[LogicalFileName] [sysname] NOT NULL,
	[PhysicalFileName] [nvarchar](260) NOT NULL,
	[SizeMB] [decimal](38, 2) NULL,
	[SpaceUsedMB] [decimal](38, 2) NULL,
	[FreeSpaceMB] [decimal](38, 2) NULL,
	[MaxSize] [decimal](38, 2) NULL,
	[IsPercentGrowth] [bit] NULL,
	[Growth] [decimal](38, 2) NULL,
	[CaptureDate] [datetime] NOT NULL
) ON [PRIMARY]
GO

CREATE TABLE [Monitoring].[WaitStatistics](
	[ID] [bigint] IDENTITY(1,1) NOT NULL,
	[CaptureDate] [datetime] NULL,
	[WaitType] [nvarchar](120) NULL,
	[Wait_S] [decimal](14, 2) NULL,
	[Resource_S] [decimal](14, 2) NULL,
	[Signal_S] [decimal](14, 2) NULL,
	[WaitCount] [bigint] NULL,
	[Percentage] [decimal](4, 2) NULL,
	[AvgWait_S] [decimal](14, 2) NULL,
	[AvgRes_S] [decimal](14, 2) NULL,
	[AvgSig_S] [decimal](14, 2) NULL
) ON [PRIMARY]

GO     


IF EXISTS (SELECT null FROM sys.objects WHERE name = 'NextExecutionTime') DROP FUNCTION Monitoring.NextExecutionTime
GO

CREATE FUNCTION Monitoring.NextExecutionTime(@StepName NVARCHAR(100))
RETURNS DATETIME
AS
BEGIN

DECLARE @NextExecution DATETIME
DECLARE @StartTime TIME
DECLARE @EndTime TIME

    SELECT @NextExecution = 
		CASE 
			WHEN OccurrencePeriod = 'minute' THEN DATEADD(mi, Occurrence, ISNULL(LastExecutionTime, '1900.01.01')) 
			WHEN OccurrencePeriod = 'hour' THEN DATEADD(hh, Occurrence, ISNULL(LastExecutionTime, '1900.01.01'))
			WHEN OccurrencePeriod = 'day' THEN DATEADD(dd, Occurrence, ISNULL(LastExecutionTime, '1900.01.01'))
			WHEN OccurrencePeriod = 'week' THEN DATEADD(wk, Occurrence, ISNULL(LastExecutionTime, '1900.01.01'))
			WHEN OccurrencePeriod = 'month' THEN DATEADD(mm, Occurrence, ISNULL(LastExecutionTime, '1900.01.01'))
		ELSE null
		END, 
	    @StartTime = ISNULL(StartTime, '00:00:00'), 
	    @EndTime = ISNULL(EndTime, '23:59:59.9999999')
    FROM Monitoring.Schedule s
    WHERE StepName = @StepName

    IF CAST(@NextExecution AS TIME) < @StartTime 
    SET @NextExecution = @NextExecution - CAST(@NextExecution AS TIME) + @StartTime

    IF CAST(@NextExecution AS TIME) > @EndTime
    SET @NextExecution = DATEADD(DD, 1, @NextExecution - CAST(@NextExecution AS TIME) + @StartTime)

RETURN @NextExecution

END
GO

CREATE TABLE [dbo].[SystemParameter](
	[Name] [varchar](50) NOT NULL,
	[Value] [nvarchar](max) NOT NULL,
	[Description] [nvarchar](500) NULL,
 CONSTRAINT [PK_SystemParameter] PRIMARY KEY CLUSTERED 
(
	[Name] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

-- should check if possible to have multiple dbs monitored on one db 
IF NOT EXISTS (SELECT * FROM dbo.SystemParameter  WHERE name = 'MonitoringDatabaseList')
--INSERT INTO dbo.SystemParameter (Name,value,Description) VALUES ('MonitoringDatabaseList','NBN_AC,Sandvik','List of databases used for performance monitoring')
INSERT INTO dbo.SystemParameter (Name,value,Description) VALUES ('MonitoringDatabaseList',DB_NAME(),'List of databases used for performance monitoring')
GO

-- developed monitoring steps
INSERT INTO Monitoring.Schedule VALUES ('Long duration', 10,'minute',null,null,null,'LongDuration',10,null)
INSERT INTO Monitoring.Schedule VALUES ('Performance counters', 6,'hour',null,null,null,'PerformanceCounters',10,null)
INSERT INTO Monitoring.Schedule VALUES ('Server configurations', 1,'day',null,null,null,'ServerConfigurations',70,null)
INSERT INTO Monitoring.Schedule VALUES ('File info', 1,'week',null,null,null,'FileInfo',10,null)
INSERT INTO Monitoring.Schedule VALUES ('Wait statistics', 1,'day',null,null,null,'WaitStatistics',10,null)
INSERT INTO Monitoring.Schedule VALUES ('Delete old monitoring data', 1,'day','00:00:00','01:00:00',null,null,0,'Used to delete old monitoring records and to maintain small size of monitoring tables')
GO



USE [msdb]
GO

BEGIN TRANSACTION
DECLARE @DBName NVARCHAR(70)
	SET @DBName = N'nbnPierce' 

DECLARE @DBJobName NVARCHAR(150)
	SET @DBJobName = N'PerformanceMonitoring' 

DECLARE @serverName nvarchar(128)
SELECT @serverName=@@SERVERNAME

DECLARE @ReturnCode INT
DECLARE @scheduleUID uniqueidentifier
SELECT @ReturnCode = 0


IF NOT EXISTS (SELECT name FROM msdb.dbo.syscategories WHERE name=N'[Uncategorized (Local)]' AND category_class=1)
BEGIN
EXEC @ReturnCode = msdb.dbo.sp_add_category @class=N'JOB', @type=N'LOCAL', @name=N'[Uncategorized (Local)]'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback

END

DECLARE @jobId BINARY(16)
EXEC @ReturnCode =  msdb.dbo.sp_add_job @job_name= @DBJobName,
		@enabled=1, 
		@notify_level_eventlog=0, 
		@notify_level_email=0, 
		@notify_level_netsend=0, 
		@notify_level_page=0, 
		@delete_level=0, 
		@description=N'No description available.', 
		@category_name=N'[Uncategorized (Local)]', 
		@job_id = @jobId OUTPUT
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback

EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'CollectData', 
		@step_id=1, 
		@cmdexec_success_code=0, 
		@on_success_action=1, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'exec Monitoring.CollectData', 
		@database_name= @DBName,
		@flags=0

IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_update_job @job_id = @jobId, @start_step_id = 1

IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobschedule @job_id=@jobId, @name= @DBJobName,
		@enabled=1, 
		@freq_type=4, 
		@freq_interval=1, 
		@freq_subday_type=4, 
		@freq_subday_interval=5, 
		@freq_relative_interval=0, 
		@freq_recurrence_factor=0, 
		@active_start_date=20190101, 
		@active_end_date=99991231, 
		@active_start_time=0, 
		@active_end_time=235959, 
		@schedule_uid = @scheduleUID

IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobserver @job_id = @jobId, @server_name = @serverName

IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
COMMIT TRANSACTION

GOTO EndSave

QuitWithRollback:
    IF (@@TRANCOUNT > 0) ROLLBACK TRANSACTION

EndSave:

GO

PRINT 'Script execution finished'
GO















