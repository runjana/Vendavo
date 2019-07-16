--drop procedure VLF

declare @DATABASENAME nvarchar(max)='NBNBilstein',
@path nvarchar(max)='B:\Backup\',
@ShrinkLog nvarchar(max)=1


drop table #db_vlf
drop table #vlf_count
drop table #logfilename
drop table #dbname

create table #db_vlf
(
RecoveryUnitId nvarchar(100),
FileId nvarchar(100),
FileSize nvarchar(100),
StartOffset nvarchar(100),
FSeqNo nvarchar(100),
Status nvarchar(100),
Parity nvarchar(100),
CreateLSN nvarchar(100)

)



create table #vlf_count
(
databasename nvarchar(max),
vlf_count_old int,
vlf_count_new int,
id int identity(1,1)
)

create table #logfilename
(
id int identity(1,1),
log_name nvarchar(max),
dbname nvarchar(max)
)


select name into #dbname
FROM master.dbo.sysdatabases
alter table #dbname
add id int identity (1,1)


declare @dbname nvarchar(max)
declare @no_of_db int
declare @query nvarchar(max)
declare @dbcount int

set @no_of_db=(select COUNT(*) from #dbname)

while (@no_of_db>0)
begin
set @dbname=(select name from #dbname where id=@no_of_db)

if (@dbname not in ('tempdb','ReportServerTempDB','master','msdb') and @dbname=@DATABASENAME)
begin

set @query='use '+@dbname+'; insert into #db_vlf EXEC (''DBCC LOGINFO'')'
print @query
exec (@query)
set @dbcount=(select COUNT(*) from #db_vlf)

--truncate table #db_vlf

insert into #vlf_count (databasename,vlf_count_old) values (@dbname,@dbcount)

--declare @truncatequery nvarchar(max)

--set @truncatequery='use '+@dbname+'; truncate table #db_vlf'

--exec (@truncatequery)


set @dbname=(select name from #dbname where id=@no_of_db)

set @query='use '+@dbname+'; insert into #db_vlf EXEC (''DBCC LOGINFO'')'

exec (@query)

set @dbcount=(select COUNT(*) from #db_vlf)

declare @insertfilequery nvarchar(max)
 
set @insertfilequery='use '+@dbname+' ;SELECT name FROM sys.master_files WHERE database_id = db_id()
AND type = 1'
 
insert into #logfilename (log_name)
exec (@insertfilequery)

update #logfilename
set dbname=@dbname where id in (select id from #vlf_count where databasename=@dbname)

declare @backupcommand nvarchar(max)

declare @filename nvarchar(max)

declare @actualfilename nvarchar(max)

set @actualfilename=(select log_name from #logfilename where dbname=@dbname)

set @filename=@actualfilename+'_backup_'+CONVERT(VARCHAR(10),GETDATE(),10)+'.bak'

set @backupcommand='use '+@dbname+'; BACKUP LOG '+@dbname+' TO  DISK = N'''+@path+''
+@filename+''' WITH NOFORMAT, INIT,  
NAME = N'''+@dbname+'- Transaction Log  Backup'', SKIP, NOREWIND, NOUNLOAD, COMPRESSION, STATS = 1;'

exec (@backupcommand)

declare @shrinkquery nvarchar(max)
set @shrinkquery='use '+@dbname+'; DBCC SHRINKFILE (N'''+@actualfilename+''' ,'+@ShrinkLog+');'
--print @shrinkquery
exec (@shrinkquery)


set @query='use '+@dbname+'; insert into #db_vlf EXEC (''DBCC LOGINFO'')'
exec (@query)

truncate table #db_vlf



set @query='use '+@dbname+'; insert into #db_vlf EXEC (''DBCC LOGINFO'')'

exec (@query)

set @dbcount=(select COUNT(*) from #db_vlf)

update  #vlf_count
set vlf_count_new=@dbcount where databasename=@dbname




end

set @no_of_db=@no_of_db-1

end


select * from #vlf_count



--drop procedure VLF

--





