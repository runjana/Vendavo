
	-------------------// if space still in critical region //--------------
	
	DECLARE @IN1 TABLE (DBNAME VARCHAR(100),NAME VARCHAR(100),SIZE INT)
	DECLARE @IN2 TABLE (DBNAME VARCHAR(100),NAME VARCHAR(100),SIZE INT)
	DECLARE @QUERY VARCHAR(MAX),@DBNAME VARCHAR(100)

	INSERT INTO @IN1
	SELECT DB_NAME(DATABASE_ID),NAME,CAST(((SIZE*8)/1024)-1 AS VARCHAR(MAX))
	FROM MASTER.SYS.MASTER_FILES WHERE DATABASE_ID IN 
	(SELECT DATABASE_ID FROM SYS.DATABASES WHERE LEN(OWNER_SID)>1 AND STATE_DESC='ONLINE'
	 AND DATABASE_ID NOT IN (SELECT DBID FROM MASTER.SYS.SYSPROCESSES WHERE STATUS IN ('RUNNABLE','SUSPENDED','ROLLBACK'))) 
	AND TYPE_DESC ='ROWS'

	DECLARE C CURSOR FOR
	SELECT NAME FROM SYS.DATABASES WHERE LEN(OWNER_SID)>1 AND STATE_DESC='ONLINE'
	OPEN C
	FETCH NEXT FROM C INTO @DBNAME
	WHILE @@FETCH_STATUS=0
	BEGIN
	SET @QUERY='USE '+QUOTENAME(@DBNAME)+';SELECT '''+@DBNAME+''',NAME,((FILEPROPERTY(NAME,''SPACEUSED''))/128)+1  FROM DBO.SYSFILES '
	begin try
	INSERT INTO @IN2 EXEC (@QUERY)
	end try
	begin catch
	print ''
	end catch
	FETCH NEXT FROM C INTO @DBNAME
	END
	CLOSE C
	DEALLOCATE C

	SELECT A.DBNAME,A.NAME,a.size 'TOAL SIZE',B.size 'USED SIZE',M.PHYSICAL_NAME, 'USE ['+A.DBNAME+'];CHECKPOINT;DBCC SHRINKFILE (N'''+A.NAME+''' , '+CAST((B.SIZE) AS VARCHAR(MAX))+')',a.size-b.size freespace FROM @IN1 AS A
	INNER JOIN @IN2 AS B ON A.DBNAME=B.DBNAME AND A.NAME=B.NAME 	AND A.SIZE>B.SIZE
	INNER JOIN SYS.master_files M ON DB_NAME(DATABASE_ID) = A.DBNAME AND M.NAME=A.NAME
	ORDER BY 7 ASC
	
	--EASY ONE 
	
	SELECT 
		  'USE [' + d.name + N'];CHECKPOINT;' + CHAR(13) + CHAR(10) 
		+ 'DBCC SHRINKFILE (N''' + mf.name + N''' , 0, TRUNCATEONLY)' 
		+ CHAR(13) + CHAR(10) + CHAR(13) + CHAR(10) ,*
	FROM 
			 sys.master_files mf 
		JOIN sys.databases d 
			ON mf.database_id = d.database_id 
	WHERE d.database_id > 4  and d.state not in( 3,6);

---plus

	exec sp_Msforeachdb 'use [?];
	SELECT 
		''USE [''+DB_NAME()+''];CHECKPOINT;DBCC SHRINKFILE (N''''''+A.NAME+'''''' , ''+CAST((CONVERT(int,A.SIZE/128.0 - ((SIZE/128.0) - CAST(FILEPROPERTY(A.NAME, ''SPACEUSED'') AS INT)/128.0))+1) AS VARCHAR(MAX))+'')''
		  FROM sys.database_files A LEFT JOIN sys.filegroups fg ON A.data_space_id = fg.data_space_id 
	  where CONVERT(int,A.SIZE/128.0)>(CONVERT(int,A.SIZE/128.0 - ((SIZE/128.0) - CAST(FILEPROPERTY(A.NAME, ''SPACEUSED'') AS INT)/128.0))+1)'

-- and

		declare @test table (dbname varchar(max),filename varchar(max),currentsize  varchar(max),freespace varchar(max),physical_name varchar(max))

		insert into @test

		exec sp_msforeachdb 'use [?]; SELECT DB_NAME() AS DbName, 
		name AS FileName, 
		size/128.0 AS CurrentSizeMB, 
		size/128.0 - CAST(FILEPROPERTY(name, ''SpaceUsed'') AS INT)/128.0 AS FreeSpaceMB ,physical_name
		FROM sys.database_files; '


		select DbName,FileName,physical_name,currentsize,(convert(float,currentsize)-convert(float,freespace)) as newsize,convert(int,convert(float,freespace)/1024) as freespace_in_gb from @test order by 6 desc


	----------------------//used space //--------------------------
	
	
SELECT 
	'USE ['+DB_NAME()+'];CHECKPOINT;DBCC SHRINKFILE (N'''+A.NAME+''' , '+CAST((CONVERT(int,A.SIZE/128.0 - ((SIZE/128.0) - CAST(FILEPROPERTY(A.NAME, 'SPACEUSED') AS INT)/128.0))+1) AS VARCHAR(MAX))+')'
	,DB_NAME() dbname
	, [TYPE] = A.TYPE_DESC
    ,[FILE_Name] = A.name
    ,[FILEGROUP_NAME] = fg.name
    ,[File_Location] = A.PHYSICAL_NAME
    ,[FILESIZE_MB] = CONVERT(int,A.SIZE/128.0)
    ,[USEDSPACE_MB] = CONVERT(int,A.SIZE/128.0 - ((SIZE/128.0) - CAST(FILEPROPERTY(A.NAME, 'SPACEUSED') AS INT)/128.0))+1
    ,[FREESPACE_MB] = CONVERT(DECIMAL(10,2),A.SIZE/128.0 - CAST(FILEPROPERTY(A.NAME, 'SPACEUSED') AS INT)/128.0)
  FROM sys.database_files A LEFT JOIN sys.filegroups fg ON A.data_space_id = fg.data_space_id 
  where CONVERT(int,A.SIZE/128.0)>(CONVERT(int,A.SIZE/128.0 - ((SIZE/128.0) - CAST(FILEPROPERTY(A.NAME, 'SPACEUSED') AS INT)/128.0))+1)
order by [FREESPACE_MB]; 




--BACKUP LOG [FONEBANK] TO  DISK = N'nul' 


--	BACKUP LOG NAIS_Mekonomen TO DISK=N'nul'