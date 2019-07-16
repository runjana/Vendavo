--			CHECK SPACE
--------------------------------------------------------------------------------------------------------------------------
	$server="kvmsqldb"
	get-WmiObject win32_logicaldisk -ComputerName $server -Filter "Drivetype=3"  |  
	ft SystemName,DeviceID,VolumeName,@{Label="Total SIze";Expression={$_.Size / 1gb -as [int] }},@{Label="Free Size";Expression={$_.freespace / 1gb -as [int] }} -autosize 

--------------------------------------------------------------------------------------------------------------------------

	DECLARE @START TABLE (DATABASES VARCHAR(100), NAME VARCHAR(100),RECOVERY_MODEL VARCHAR(100),LOG_REUSE_WAIT_DESCRIPTION VARCHAR(100),LOG_SIZE VARCHAR(100),LOG_USED VARCHAR(100),PAGE_VERIFY_PTION	VARCHAR(100),IS_AUTO_SHRINK_ON VARCHAR(100))

	INSERT INTO @START
	SELECT DB.[NAME] AS [DATABASE NAME], DB.RECOVERY_MODEL_DESC AS [RECOVERY MODEL], DB.LOG_REUSE_WAIT_DESC AS [LOG REUSE WAIT DESCRIPTION], LS.CNTR_VALUE AS [LOG SIZE (KB)], 
	LU.CNTR_VALUE AS [LOG USED (KB)], CAST(CAST(LU.CNTR_VALUE AS FLOAT) / CAST(LS.CNTR_VALUE AS FLOAT)AS DECIMAL(18,2)) * 100 AS [LOG USED %], DB.PAGE_VERIFY_OPTION_DESC AS [PAGE VERIFY OPTION], 
	DB.IS_AUTO_SHRINK_ON FROM SYS.DATABASES AS DB WITH (NOLOCK) INNER JOIN SYS.DM_OS_PERFORMANCE_COUNTERS AS LU WITH (NOLOCK) ON DB.NAME = LU.INSTANCE_NAME INNER JOIN SYS.DM_OS_PERFORMANCE_COUNTERS AS LS WITH (NOLOCK) ON DB.NAME = LS.INSTANCE_NAME WHERE LU.COUNTER_NAME LIKE N'LOG FILE(S) USED SIZE (KB)%' AND LS.COUNTER_NAME LIKE N'LOG FILE(S) SIZE (KB)%' AND LS.CNTR_VALUE > 0 OPTION (RECOMPILE);

	DECLARE @LOG TABLE (DATABASES VARCHAR(100), LOGSIZE VARCHAR(100),LOGUSED VARCHAR(100),STATUSS VARCHAR(100))
	INSERT INTO @LOG EXEC ('DBCC SQLPERF(LOGSPACE)')

	SELECT ' EXEC [DBO].[SHRINK_DB_LOG] '''+L.DATABASES+''', 2, ''NULL'','''+L.DATABASES+'_SHIRNK_BACKUP'', 4;' 
	FROM @LOG L,SYS.MASTER_FILES S WHERE TYPE_DESC='LOG' 
	AND DB_NAME(S.DATABASE_ID)=L.DATABASES AND L.DATABASES NOT IN ('MASTER','MODEL','MSDB','TEMPDB')
	AND DB_NAME(S.DATABASE_ID) IN (SELECT DATABASES FROM @START WHERE RECOVERY_MODEL='NOTHING')

	SELECT * FROM @START WHERE RECOVERY_MODEL='NOTHING'

--------------------------------------------------------------------------------------------------------------------------

	DECLARE @LOG TABLE (DATABASES VARCHAR(100), LOGSIZE VARCHAR(100),LOGUSED VARCHAR(100),STATUSS VARCHAR(100))
	INSERT INTO @LOG EXEC ('DBCC SQLPERF(LOGSPACE)')
	SELECT 'USE ['+L.DATABASES+'];CHECKPOINT;DBCC SHRINKFILE(['+S.NAME+'],2);' FROM @LOG L,SYS.MASTER_FILES S WHERE TYPE_DESC='LOG' 
	AND DB_NAME(S.DATABASE_ID)=L.DATABASES AND L.DATABASES NOT IN ('MASTER','MODEL','MSDB','TEMPDB')

	-------------------- SHRINK LOG FILE 
	
select 'USE ['+DB_NAME(database_id)+'] ; BACKUP LOG ['+DB_NAME(database_id)+'] TO  DISK = N''nul:'';  ' from sys.master_files where physical_name like '%I:%' AND type_desc= 'LOG'

/*


	select a.script,a.name,row_number() over (partition by script,name order by script,name) as rw from 
	(
		select 'BACKUP LOG ['+name+'] TO DISK=''\\NAV-C00DB09P-B\Backup\'+NAME+'.TRN''' script,name from master.sys.databases --where log_reuse_wait_desc in ('LOG_BACKUP')
		union all
		select 'EXEC MASTER.DBO.XP_CMDSHELL ''Del "\\NAV-C00DB09P-B\Backup\'+NAME+'.TRN"''' script,name from master.sys.databases --where log_reuse_wait_desc in ('LOG_BACKUP')
		union all
	SELECT  'USE [' + d.name + N'];CHECKPOINT;' + CHAR(13) + CHAR(10)+ 'DBCC SHRINKFILE (N''' + mf.name + N''' , 0, TRUNCATEONLY)'+ CHAR(13) + CHAR(10) + CHAR(13) + CHAR(10) as script ,d.name	FROM sys.master_files mf JOIN sys.databases d ON mf.database_id = d.database_id wHERE d.database_id > 4 and type_desc= 'LOG'
	union all
			select 'BACKUP LOG ['+name+'] TO DISK=''\\NAV-C00DB09P-B\Backup\'+NAME+'.TRN''' script,name from master.sys.databases --where log_reuse_wait_desc in ('LOG_BACKUP')
		union all
		select 'EXEC MASTER.DBO.XP_CMDSHELL ''Del "\\NAV-C00DB09P-B\Backup\'+NAME+'.TRN"''' script,name from master.sys.databases --where log_reuse_wait_desc in ('LOG_BACKUP')
		union all
	SELECT  'USE [' + d.name + N'];CHECKPOINT;' + CHAR(13) + CHAR(10)+ 'DBCC SHRINKFILE (N''' + mf.name + N''' , 0, TRUNCATEONLY)'+ CHAR(13) + CHAR(10) + CHAR(13) + CHAR(10) as script ,d.name	FROM sys.master_files mf JOIN sys.databases d ON mf.database_id = d.database_id wHERE d.database_id > 4 and type_desc= 'LOG'
	
	)a 
	 where --a.name like '%pierce%'and
	 a.name not in ('master','model','msdb','temp')
	order by name,rw,SCRIPT asc


*/	
	
	SELECT 
		  'USE [' + d.name + N'];CHECKPOINT;' + CHAR(13) + CHAR(10) 
		+ 'DBCC SHRINKFILE (N''' + mf.name + N''' , 0, TRUNCATEONLY)' 
		+ CHAR(13) + CHAR(10) + CHAR(13) + CHAR(10) , *
	FROM 
			 sys.master_files mf 
		JOIN sys.databases d 
			ON mf.database_id = d.database_id 
	WHERE d.database_id > 4 and type_desc='LOG'
	and d.state_desc ='ONLINE'
	;
	
	-- % completed
	
	select session_id,db_name(database_id),status,command,percent_complete,blocking_session_id from sys.dm_exec_requests where session_id in (199)  
	
	select distinct spid,db_name(dbid),status,hostname,cmd,loginame,blocked from sys.sysprocesses where spid in (199) 
	
	---------------------// TEMP //---------------------------

	SELECT 'USE TEMPDB;CHECKPOINT;DBCC SHRINKFILE (N'''+NAME+''',1)',* FROM MASTER.SYS.MASTER_FILES WHERE NAME LIKE 'TEMP%'