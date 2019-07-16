

	DECLARE @INITIAL INT,@FINAL INT,@DBNAME VARCHAR(MAX),@FILE VARCHAR(MAX),@QUERY VARCHAR(MAX)
	SET @INITIAL='614000'
	SET @FINAL=  '430000'
	SET @DBNAME='WILLIS_DEVSTG_TEST'
	SET @FILE='ZZZ_FILEGROUP'

	WHILE @INITIAL>=@FINAL
	BEGIN
	SET @INITIAL=@INITIAL-100
	SET @QUERY='USE ['+@DBNAME+'];CHECKPOINT;DBCC SHRINKFILE (N'''+@FILE+''' , '+CONVERT(VARCHAR,@INITIAL)+')'
	PRINT @QUERY
	EXEC (@QUERY)
	END

	
	---------------------------------------------------------------------------------------------
	
	SELECT SPID,DB_NAME(DBID),STATUS,HOSTNAME,CMD,LOGINAME,BLOCKED FROM SYS.SYSPROCESSES WHERE DB_NAME(DBID)='WILLIS_DEVSTG_TEST'
addJSDComment(key, "ranjana.ghimire@navetti.com", " Automated Epic Link has been assigned by [~ranjana.ghimire@navetti.com]", false);



@
