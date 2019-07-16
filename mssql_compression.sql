	SET NOCOUNT ON
	DECLARE @database varchar(500)='VHIP'
	DECLARE @query varchar(maX)

	DECLARE @TABLEs TABLE(dbase varchar(max),TABLEname varchar(max),schemas varchar(500))
		DECLARE @row TABLE (
		objectname nvarchar(200),
		schemaname nvarchar(200),
		index_id int,
		partition_number int,
		size_with_current_compression_setting int,
		size_with_requested_compression_setting int,
		sample_size_with_current_compression_setting int,
		sample_size_with_requested_compression_setting int,
		sid int identity(1,1))


		DECLARE @PAGE TABLE (
		objectname nvarchar(200),
		schemaname nvarchar(200),
		index_id int,
		partition_number int,
		size_with_current_compression_setting int,
		size_with_requested_compression_setting int,
		sample_size_with_current_compression_setting int,
		sample_size_with_requested_compression_setting int,
		sid int identity(1,1))

	set @query='select '''+QUOTENAME(@database)+''',name,schema_name(schema_id) from '+QUOTENAME(@database)+'.sys.TABLEs;'
	insert into @TABLEs exec (@query)


	DECLARE @DBASE VARCHAR(MAX),@TABLENAME VARCHAR(MAX),@SCHEMAS VARCHAR(MAX),@TYPE VARCHAR(4)

	DECLARE C CURSOR FOR
	SELECT dbase,tablename,schemas from @tables
	open c
	fetch next from c into @dbase,@tablename,@schemas
	while @@FETCH_STATUS=0
	begin
	set @query='USE '+@DBASE+';EXEC sp_estimate_data_compression_savings '''+@SCHEMAS+''','''+@TABLENAME+''',NULL,NULL,''ROW'''
	INSERT INTO @row EXEC(@QUERY)
	set @query='USE '+@DBASE+';EXEC sp_estimate_data_compression_savings '''+@SCHEMAS+''','''+@TABLENAME+''',NULL,NULL,''PAGE'''
	INSERT INTO @PAGE EXEC(@QUERY)
	fetch next from c into @dbase,@tablename,@schemas
	end
	close c
	deallocate c


	DECLARE C CURSOR FOR  
	select distinct  r.objectname,t.dbase,t.schemas,case 
									when r.sample_size_with_requested_compression_setting>p.sample_size_with_requested_compression_setting then 'ROW'
									when r.sample_size_with_requested_compression_setting>p.sample_size_with_requested_compression_setting then 'PAGE'
									else 'PAGE' end from @row r,@PAGE p,@TABLEs t
	where r.objectname=p.objectname and t.TABLEname=r.objectname
	OPEN C
	FETCH NEXT FROM C INTO @TABLENAME,@DBASE,@SCHEMAS,@TYPE
	WHILE @@FETCH_STATUS=0
	BEGIN
	SET @QUERY='USE '+@DBASE+';ALTER TABLE ['+@SCHEMAS+'].['+@TABLENAME+'] REBUILD PARTITION = ALL WITH (DATA_COMPRESSION= '+@TYPE+')'
	exec (@QUERY)
	FETCH NEXT FROM C INTO @TABLENAME,@DBASE,@SCHEMAS,@TYPE
	END
	CLOSE C
	DEALLOCATE C
