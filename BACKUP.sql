if exists(SELECT 1 FROM sys.dm_hadr_availability_group_states where primary_replica=@@SERVERNAME)
begin




/*

DECLARE  @DATABASE_NAME VARCHAR(256)
DECLARE @LOCATION VARCHAR(256)='\\NAV-C00DB04P-B\Share\LOG\'
DECLARE @QUERY VARCHAR(MAX)
DECLARE @BACKUPTYPE VARCHAR(10)
DECLARE @NUMBEROFFILES VARCHAR(10)
DECLARE @DATE VARCHAR(16)=REPLACE(CONVERT(VARCHAR(10), GETDATE(), 110),'-','_')+'_DIFF'
------------- Create folder to backup as per date
DECLARE C CURSOR FOR
SELECT name FROM master.sys.databases where database_id>4 and name not like '%test%'
BEGIN
OPEN C
FETCH NEXT FROM C INTO @DATABASE_NAME
WHILE @@FETCH_STATUS = 0
BEGIN

SET @QUERY =  'BACKUP  LOG '+QUOTENAME(@DATABASE_NAME)+
											 '  TO DISK = N'''+@LOCATION+@DATABASE_NAME+'_'+CONVERT(CHAR(8), getdate(), 112) +  REPLACE(CONVERT(CHAR(8), getdate(), 108), ':', '')+'_1.TRN'',
												 DISK = N'''+@LOCATION+@DATABASE_NAME+'_'+CONVERT(CHAR(8), getdate(), 112) +  REPLACE(CONVERT(CHAR(8), getdate(), 108), ':', '')+'_2.TRN'' ,
												 DISK = N'''+@LOCATION+@DATABASE_NAME+'_'+CONVERT(CHAR(8), getdate(), 112) +  REPLACE(CONVERT(CHAR(8), getdate(), 108), ':', '')+'_3.TRN'' ,
												 DISK = N'''+@LOCATION+@DATABASE_NAME+'_'+CONVERT(CHAR(8), getdate(), 112) +  REPLACE(CONVERT(CHAR(8), getdate(), 108), ':', '')+'_4.TRN'' ,
												 DISK = N'''+@LOCATION+@DATABASE_NAME+'_'+CONVERT(CHAR(8), getdate(), 112) +  REPLACE(CONVERT(CHAR(8), getdate(), 108), ':', '')+'_5.TRN'' ,
												 DISK = N'''+@LOCATION+@DATABASE_NAME+'_'+CONVERT(CHAR(8), getdate(), 112) +  REPLACE(CONVERT(CHAR(8), getdate(), 108), ':', '')+'_6.TRN'' ,
												 DISK = N'''+@LOCATION+@DATABASE_NAME+'_'+CONVERT(CHAR(8), getdate(), 112) +  REPLACE(CONVERT(CHAR(8), getdate(), 108), ':', '')+'_7.TRN'' ,
												 DISK = N'''+@LOCATION+@DATABASE_NAME+'_'+CONVERT(CHAR(8), getdate(), 112) +  REPLACE(CONVERT(CHAR(8), getdate(), 108), ':', '')+'_8.TRN''
											 '; 

PRINT @QUERY
EXEC (@QUERY)

FETCH NEXT FROM C INTO @DATABASE_NAME
END
CLOSE C
DEALLOCATE C
END

*/
----------------------------diff
/* 
if exists(SELECT 1 FROM sys.dm_hadr_availability_group_states where primary_replica=@@SERVERNAME)
begin

DECLARE  @DATABASE_NAME VARCHAR(256)
DECLARE @LOCATION VARCHAR(256)='\\NAV-C00DB04P-B\Backup'
DECLARE @QUERY VARCHAR(MAX)
DECLARE @BACKUPTYPE VARCHAR(10)
DECLARE @NUMBEROFFILES VARCHAR(10)
DECLARE @DATE VARCHAR(16)=REPLACE(CONVERT(VARCHAR(10), GETDATE(), 110),'-','_')+'_DIFF'

------------- Create folder to backup as per date

SET @QUERY = 'EXEC master.dbo.xp_cmdshell ''' + 'mkDir "' + @LOCATION  +'\'+ @DATE + '"'''

PRINT @QUERY

EXEC (@QUERY)

DECLARE C CURSOR FOR
SELECT name FROM master.sys.databases where database_id>4 and name not like '%test%'
BEGIN
OPEN C
FETCH NEXT FROM C INTO @DATABASE_NAME
WHILE @@FETCH_STATUS = 0
BEGIN
SET @QUERY = 'EXEC master.dbo.xp_cmdshell ''' + 'mkDir "' + @LOCATION  +'\'+ @DATE +'\'+ @DATABASE_NAME+'_'+convert(varchar(4),replace(Convert(Time(0),GETDATE(),0),':','')) + '"'''

PRINT @QUERY

EXEC (@QUERY)

SET @QUERY =  'BACKUP  DATABASE '+QUOTENAME(@DATABASE_NAME)+
											 '  TO DISK = N'''+@LOCATION+'\'+@DATE+'\'+ @DATABASE_NAME +'_'+convert(varchar(4),replace(Convert(Time(0),GETDATE(),0),':','')) +'\'+@DATABASE_NAME+'1.BAK'',
												 DISK = N'''+@LOCATION+'\'+@DATE+'\'+ @DATABASE_NAME +'_'+convert(varchar(4),replace(Convert(Time(0),GETDATE(),0),':','')) +'\'+@DATABASE_NAME+'2.BAK'' ,
												 DISK = N'''+@LOCATION+'\'+@DATE+'\'+ @DATABASE_NAME +'_'+convert(varchar(4),replace(Convert(Time(0),GETDATE(),0),':','')) +'\'+@DATABASE_NAME+'3.BAK'' ,
												 DISK = N'''+@LOCATION+'\'+@DATE+'\'+ @DATABASE_NAME +'_'+convert(varchar(4),replace(Convert(Time(0),GETDATE(),0),':','')) +'\'+@DATABASE_NAME+'4.BAK'' ,
												 DISK = N'''+@LOCATION+'\'+@DATE+'\'+ @DATABASE_NAME +'_'+convert(varchar(4),replace(Convert(Time(0),GETDATE(),0),':','')) +'\'+@DATABASE_NAME+'5.BAK'' ,
												 DISK = N'''+@LOCATION+'\'+@DATE+'\'+ @DATABASE_NAME +'_'+convert(varchar(4),replace(Convert(Time(0),GETDATE(),0),':','')) +'\'+@DATABASE_NAME+'6.BAK'' ,
												 DISK = N'''+@LOCATION+'\'+@DATE+'\'+ @DATABASE_NAME +'_'+convert(varchar(4),replace(Convert(Time(0),GETDATE(),0),':','')) +'\'+@DATABASE_NAME+'7.BAK'' ,
												 DISK = N'''+@LOCATION+'\'+@DATE+'\'+ @DATABASE_NAME +'_'+convert(varchar(4),replace(Convert(Time(0),GETDATE(),0),':','')) +'\'+@DATABASE_NAME+'8.BAK''
												 WITH DIFFERENTIAL ,format
												, norewind, nounload, compression,checksum '; 

PRINT @QUERY

EXEC (@QUERY)

FETCH NEXT FROM C INTO @DATABASE_NAME
END
CLOSE C
DEALLOCATE C
END


end

*/
----------------------------full 
/*

DECLARE  @DATABASE_NAME VARCHAR(256)
DECLARE @LOCATION VARCHAR(256)='\\NAV-C00DB04P-B\Backup'
DECLARE @QUERY VARCHAR(MAX)
DECLARE @BACKUPTYPE VARCHAR(10)
DECLARE @NUMBEROFFILES VARCHAR(10)
DECLARE @DATE VARCHAR(16)=REPLACE(CONVERT(VARCHAR(10), GETDATE(), 110),'-','_')+'_FULL'

------------- Create folder to backup as per date

SET @QUERY = 'EXEC master.dbo.xp_cmdshell ''' + 'mkDir "' + @LOCATION  +'\'+ @DATE + '"'''

PRINT @QUERY

EXEC (@QUERY)

DECLARE C CURSOR FOR
SELECT name FROM master.sys.databases where database_id>4 and name not like '%test%'
BEGIN
OPEN C
FETCH NEXT FROM C INTO @DATABASE_NAME
WHILE @@FETCH_STATUS = 0
BEGIN
SET @QUERY = 'EXEC master.dbo.xp_cmdshell ''' + 'mkDir "' + @LOCATION  +'\'+ @DATE +'\'+ @DATABASE_NAME + '"'''

PRINT @QUERY

EXEC (@QUERY)

SET @QUERY =  'BACKUP  DATABASE '+QUOTENAME(@DATABASE_NAME)+
											 '  TO DISK = N'''+@LOCATION+'\'+@DATE+'\'+ @DATABASE_NAME +'\'+@DATABASE_NAME+'1.BAK'',
												 DISK = N'''+@LOCATION+'\'+@DATE+'\'+ @DATABASE_NAME +'\'+@DATABASE_NAME+'2.BAK'' ,
												 DISK = N'''+@LOCATION+'\'+@DATE+'\'+ @DATABASE_NAME +'\'+@DATABASE_NAME+'3.BAK'' ,
												 DISK = N'''+@LOCATION+'\'+@DATE+'\'+ @DATABASE_NAME +'\'+@DATABASE_NAME+'4.BAK'' ,
												 DISK = N'''+@LOCATION+'\'+@DATE+'\'+ @DATABASE_NAME +'\'+@DATABASE_NAME+'5.BAK'' ,
												 DISK = N'''+@LOCATION+'\'+@DATE+'\'+ @DATABASE_NAME +'\'+@DATABASE_NAME+'6.BAK'' ,
												 DISK = N'''+@LOCATION+'\'+@DATE+'\'+ @DATABASE_NAME +'\'+@DATABASE_NAME+'7.BAK'' ,
												 DISK = N'''+@LOCATION+'\'+@DATE+'\'+ @DATABASE_NAME +'\'+@DATABASE_NAME+'8.BAK''
												 WITH description = N''BACKUP_'+@DATABASE_NAME+''',format
												, norewind, nounload, compression,checksum '; 

PRINT @QUERY

EXEC (@QUERY)

FETCH NEXT FROM C INTO @DATABASE_NAME
END
CLOSE C
DEALLOCATE C
END

*/