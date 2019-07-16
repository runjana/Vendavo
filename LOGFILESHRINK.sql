
if exists(SELECT 1 FROM sys.dm_hadr_availability_group_states where primary_replica=@@SERVERNAME)
begin

DECLARE @SCRIPT VARCHAR(MAX)

DECLARE C CURSOR FOR 
	SELECT 
		  'USE [' + d.name + N'];CHECKPOINT;' + CHAR(13) + CHAR(10) 
		+ 'DBCC SHRINKFILE (N''' + mf.name + N''' , 0, TRUNCATEONLY)' 
		+ CHAR(13) + CHAR(10) + CHAR(13) + CHAR(10) 
	FROM 
			 sys.master_files mf 
		JOIN sys.databases d 
			ON mf.database_id = d.database_id 
	WHERE d.database_id > 4  and d.state not in( 3,6)  and type_desc='LOG'
	OPEN C
	FETCH NEXT FROM C INTO @SCRIPT
	WHILE @@FETCH_STATUS=0
	BEGIN
		PRINT @SCRIPT
		EXEC (@SCRIPT)
	FETCH NEXT FROM C INTO @SCRIPT
	END
	CLOSE C
	DEALLOCATE C

	END