
			Use tempDB
go
DBCC FREEPROCCACHE



Use tempDB
go
DBCC FREEPROCCACHE

select 'USE [tempdb];DBCC SHRINKFILE (N'''+name+''' , 5);',* from sys.master_files  where name like '%temp%'


USE [tempdb]
GO
DBCC SHRINKFILE (N'tempdev' , 5)
USE [tempdb]
GO
DBCC SHRINKFILE (N'templog' , 5)
USE [tempdb]
GO
DBCC SHRINKFILE (N'tempdev1' , 5)
USE [tempdb]
GO
DBCC SHRINKFILE (N'tempdev2' , 5)
USE [tempdb]
GO
DBCC SHRINKFILE (N'tempdev3' , 5)
USE [tempdb]
GO
DBCC SHRINKFILE (N'tempdev4' , 5)
USE [tempdb]
GO
DBCC SHRINKFILE (N'tempdev5' , 5)
USE [tempdb]
GO
DBCC SHRINKFILE (N'tempdev6' , 5)
USE [tempdb]
GO
DBCC SHRINKFILE (N'tempdev7' , 5)