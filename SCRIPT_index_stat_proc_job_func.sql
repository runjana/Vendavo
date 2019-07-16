set nocount on
-------------------------------------------------------------------------------------------------------------------------
------------------------------------------------//INDEX//----------------------------------------------------------------
-------------------------------------------------------------------------------------------------------------------------

declare @SchemaName varchar(100)declare @TableName varchar(256)
declare @IndexName varchar(256)
declare @ColumnName varchar(100)
declare @is_unique varchar(100)
declare @IndexTypeDesc varchar(100)
declare @FileGroupName varchar(100)
declare @is_disabled varchar(100)
declare @IndexOptions varchar(max)
declare @IndexColumnId int
declare @IsDescendingKey int 
declare @IsIncludedColumn int
declare @TSQLScripCreationIndex varchar(max)
declare @TSQLScripDisableIndex varchar(max)


DECLARE @TEST TABLE (DBNAME VARCHAR(200),OBJECT_TYPE VARCHAR(200),INDEX_NAME VARCHAR(200),SCRIPT TEXT)
declare CursorIndex cursor for
 select schema_name(t.schema_id) [schema_name], t.name, ix.name,
 case when ix.is_unique = 1 then 'UNIQUE ' else '' END 
 , ix.type_desc,
 case when ix.is_padded=1 then 'PAD_INDEX = ON, ' else 'PAD_INDEX = OFF, ' end
 + case when ix.allow_page_locks=1 then 'ALLOW_PAGE_LOCKS = ON, ' else 'ALLOW_PAGE_LOCKS = OFF, ' end
 + case when ix.allow_row_locks=1 then  'ALLOW_ROW_LOCKS = ON, ' else 'ALLOW_ROW_LOCKS = OFF, ' end
 + case when INDEXPROPERTY(t.object_id, ix.name, 'IsStatistics') = 1 then 'STATISTICS_NORECOMPUTE = ON, ' else 'STATISTICS_NORECOMPUTE = OFF, ' end
 + case when ix.ignore_dup_key=1 then 'IGNORE_DUP_KEY = ON, ' else 'IGNORE_DUP_KEY = OFF, ' end
 + 'SORT_IN_TEMPDB = OFF, FILLFACTOR =' + CAST(ix.fill_factor AS VARCHAR(3)) AS IndexOptions
 , ix.is_disabled , FILEGROUP_NAME(ix.data_space_id) FileGroupName
 from sys.tables t 
 inner join sys.indexes ix on t.object_id=ix.object_id
 where ix.type>0 and ix.is_primary_key=0 and ix.is_unique_constraint=0 --and schema_name(tb.schema_id)= @SchemaName and tb.name=@TableName
 and t.is_ms_shipped=0 and t.name<>'sysdiagrams'
 order by schema_name(t.schema_id), t.name, ix.name

open CursorIndex
fetch next from CursorIndex into  @SchemaName, @TableName, @IndexName, @is_unique, @IndexTypeDesc, @IndexOptions,@is_disabled, @FileGroupName

while (@@fetch_status=0)
begin
 declare @IndexColumns varchar(max)
 declare @IncludedColumns varchar(max)
 
 set @IndexColumns=''
 set @IncludedColumns=''
 
 declare CursorIndexColumn cursor for 
  select col.name, ixc.is_descending_key, ixc.is_included_column
  from sys.tables tb 
  inner join sys.indexes ix on tb.object_id=ix.object_id
  inner join sys.index_columns ixc on ix.object_id=ixc.object_id and ix.index_id= ixc.index_id
  inner join sys.columns col on ixc.object_id =col.object_id  and ixc.column_id=col.column_id
  where ix.type>0 and (ix.is_primary_key=0 or ix.is_unique_constraint=0)
  and schema_name(tb.schema_id)=@SchemaName and tb.name=@TableName and ix.name=@IndexName
  order by ixc.index_column_id
 
 open CursorIndexColumn 
 fetch next from CursorIndexColumn into  @ColumnName, @IsDescendingKey, @IsIncludedColumn
 
 while (@@fetch_status=0)
 begin
  if @IsIncludedColumn=0 
   set @IndexColumns=@IndexColumns + @ColumnName  + case when @IsDescendingKey=1  then ' DESC, ' else  ' ASC, ' end
  else 
   set @IncludedColumns=@IncludedColumns  + @ColumnName  +', ' 

  fetch next from CursorIndexColumn into @ColumnName, @IsDescendingKey, @IsIncludedColumn
 end

 close CursorIndexColumn
 deallocate CursorIndexColumn

 set @IndexColumns = substring(@IndexColumns, 1, len(@IndexColumns)-1)
 set @IncludedColumns = case when len(@IncludedColumns) >0 then substring(@IncludedColumns, 1, len(@IncludedColumns)-1) else '' end
 --  print @IndexColumns
 --  print @IncludedColumns

 set @TSQLScripCreationIndex =''
 set @TSQLScripDisableIndex =''
 set @TSQLScripCreationIndex='CREATE '+ @is_unique  +@IndexTypeDesc + ' INDEX ' +QUOTENAME(@IndexName)+' ON ' + QUOTENAME(@SchemaName) +'.'+ QUOTENAME(@TableName)+ '('+@IndexColumns+') '+ 
  case when len(@IncludedColumns)>0 then CHAR(13) +'INCLUDE (' + @IncludedColumns+ ')' else '' end + CHAR(13)+'WITH (' + @IndexOptions+ ') ON ' + QUOTENAME(@FileGroupName) + ';'  

  INSERT INTO @TEST VALUES (DB_NAME(),'INDEX',@IndexName,@TSQLScripCreationIndex)

 fetch next from CursorIndex into  @SchemaName, @TableName, @IndexName, @is_unique, @IndexTypeDesc, @IndexOptions,@is_disabled, @FileGroupName

end
close CursorIndex
deallocate CursorIndex

DELETE FROM @TEST WHERE SCRIPT IS NULL
UPDATE @TEST SET SCRIPT=CONVERT(TEXT,REPLACE(CONVERT(VARCHAR(MAX),SCRIPT),', FILLFACTOR =0',''))


-------------------------------------------------------------------------------------------------------------------------
------------------------------------------------//STATISTICS//-----------------------------------------------------------
-------------------------------------------------------------------------------------------------------------------------


SELECT DISTINCT
OBJECT_NAME(s.[object_id]) AS TableName,
c.name AS ColumnName,
s.name AS StatName
into #TEST
FROM sys.stats s JOIN sys.stats_columns sc ON sc.[object_id] = s.[object_id] AND sc.stats_id = s.stats_id
JOIN sys.columns c ON c.[object_id] = sc.[object_id] AND c.column_id = sc.column_id
JOIN sys.partitions par ON par.[object_id] = s.[object_id]
JOIN sys.objects obj ON par.[object_id] = obj.[object_id]
WHERE OBJECTPROPERTY(s.OBJECT_ID,'IsUserTable') = 1
--AND (s.auto_created = 1 OR s.user_created = 1);
AND s.auto_created = 0 and s.user_created = 1;

INSERT INTO @TEST 
SELECT db_name() as database_name,'STATISTICS',extern.StatName,'CREATE STATISTICS '+extern.StatName+' ON dbo.'+extern.TableName+'( '+
LEFT(replace(replace(column_names,'<column_names>',''),'</column_names>',''),LEN(replace(replace(column_names,'<column_names>',''),'</column_names>',''))-1)+')' as script
 FROM #TEST  AS extern
CROSS APPLY
(
SELECT intern.ColumnName+',' AS column_names from #test AS intern where 
extern.StatName=intern.StatName for xml path('')
) pre_trimmed (column_names)
group by extern.StatName,extern.TableName,column_names



drop table #TEST


INSERT INTO @TEST
SELECT    db_name(),'PROCEDURE',Name,
           ltrim(OBJECT_DEFINITION(OBJECT_ID)) + char(13) +char(10) + 'GO' + char(13) + char(10)
            from sys.procedures
            where is_ms_shipped = 0
 
 -------------------------------------------------------------------------------------------------------------------------
------------------------------------------------//FUNCTION//--------------------------------------------------------------
-------------------------------------------------------------------------------------------------------------------------

 INSERT INTO @TEST
SELECT db_name() as database_name,'FUNCTION' AS 'FUNC',SO.name as 'name',SM.definition
FROM sys.sql_modules SM 
INNER JOIN sys.objects SO ON SM.Object_id = SO.Object_id
 WHERE SO.type = 'FN'

-------------------------------------------------------------------------------------------------------------------------
------------------------------------------------//TRIGGER//--------------------------------------------------------------
-------------------------------------------------------------------------------------------------------------------------

  INSERT INTO @TEST
SELECT db_name() as database_name,'TRIGGER' AS 'TRG',SO.name as 'name',SM.definition
FROM sys.sql_modules SM 
INNER JOIN sys.objects SO ON SM.Object_id = SO.Object_id
 WHERE SO.type = 'TR'
 
 -------------------------------------------------------------------------------------------------------------------------
------------------------------------------------//JOB//--------------------------------------------------------------
-------------------------------------------------------------------------------------------------------------------------
 
 INSERT INTO @TEST

select 
 distinct db_name() as database_name,'JOB' AS 'JOB',j.name as 'name',
'use msdb ;
BEGIN TRANSACTION
DECLARE @ReturnCode INT
SELECT @ReturnCode = 0
IF NOT EXISTS (SELECT name FROM msdb.dbo.syscategories WHERE name=N'''+sc.name+''' AND category_class=1)
BEGIN
EXEC @ReturnCode = msdb.dbo.sp_add_category @class=N''JOB'', @type=N''LOCAL'', @name=N'''+sc.name+'''
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
END

DECLARE @jobId BINARY(16)
EXEC @ReturnCode =  msdb.dbo.sp_add_job @job_name=N'''+convert(varchar,j.name)+''', 
		@enabled='+convert(varchar,j.enabled)+', 
		@notify_level_eventlog='+convert(varchar,j.notify_level_eventlog)+', 
		@notify_level_email='+convert(varchar,j.notify_level_email)+', 
		@notify_level_netsend='+convert(varchar,notify_level_netsend)+', 
		@notify_level_page='+convert(varchar,j.notify_level_page)+', 
		@delete_level='+convert(varchar,j.delete_level)+', 
		@description=N'''+convert(varchar,j.description)+''', 
		@category_name=N'''+convert(varchar,sc.name)+''', 
		@owner_login_name=N''sa'', @job_id = @jobId OUTPUT
'+stuff ((select ' '+'IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'''+js2.step_name+''', 
		@step_id='+convert(varchar,js2.step_id)+', 
		@cmdexec_success_code=	'+convert(varchar,js2.cmdexec_success_code)+', 
		@on_success_action='+convert(varchar,js2.on_success_action)+', 
		@on_success_step_id='+convert(varchar,js2.on_success_step_id)+', 
		@on_fail_action='+convert(varchar,js2.on_fail_action)+', 
		@on_fail_step_id='+convert(varchar,js2.on_fail_step_id)+', 
		@retry_attempts='+convert(varchar,js2.retry_attempts)+', 
		@retry_interval='+convert(varchar,js2.retry_interval)+', 
		@os_run_priority='+convert(varchar,js2.os_run_priority)+',
		@subsystem=N'''+convert(varchar,js2.subsystem)+''', 
		@command=N'''+REPLACE(convert(varchar,js2.command),'''','''''')+''', 
		@database_name=N'''+convert(varchar,js2.database_name)+''', 
		@flags='+convert(varchar,js2.flags) as column_names 
		from msdb.dbo.sysjobsteps as js2
		where js.job_id=js2.job_id 
		FOR XML PATH(''), TYPE).value('.', 'NVARCHAR(MAX)'), 1, 1, '')
		+'IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_update_job @job_id = @jobId, @start_step_id = 1
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobschedule @job_id=@jobId, @name=N'''+ms.name+''', 
		@enabled='+convert(varchar,ms.enabled)+',
		@freq_type='+convert(varchar,ms.freq_type)+', 
		@freq_interval='+convert(varchar,ms.freq_interval)+', 
		@freq_subday_type='+convert(varchar,ms.freq_subday_type)+', 
		@freq_subday_interval='+convert(varchar,ms.freq_subday_interval)+', 
		@freq_relative_interval='+convert(varchar,ms.freq_relative_interval)+', 
		@freq_recurrence_factor='+convert(varchar,ms.freq_recurrence_factor)+', 
		@active_start_date='+convert(varchar,ms.active_start_date)+', 
		@active_end_date='+convert(varchar,ms.active_end_date)+', 
		@active_start_time='+convert(varchar,ms.active_start_time)+', 
		@active_end_time='+convert(varchar,ms.active_end_time)+', 
		@schedule_uid=N'''+convert(varchar(max),ms.schedule_uid)+'''
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobserver @job_id = @jobId, @server_name = N''(local)''
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
COMMIT TRANSACTION
GOTO EndSave
QuitWithRollback:
    IF (@@TRANCOUNT > 0) ROLLBACK TRANSACTION
EndSave:
'
 from msdb.dbo.sysjobs  j
 inner join  msdb.dbo.sysjobsteps js on j.job_id=js.job_id
 inner join msdb.dbo.syscategories sc on j.category_id = sc. category_id
 inner join  msdb.dbo.sysjobschedules s on s.job_id=j.job_id
 inner join msdb.dbo.sysschedules ms on ms.schedule_id=s.schedule_id



-------------------------------------------------------------------------------------------------------------------------
------------------------------------------------//RESULT//--------------------------------------------------------------
-------------------------------------------------------------------------------------------------------------------------


SELECT '10' as  BANK_ID,1 AS 'MBL_ID',OBJECT_TYPE ,INDEX_NAME AS 'OBJECT_NAME',SCRIPT AS 'SCRIPT' into test FROM @TEST





