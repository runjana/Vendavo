use tempdb
CHECKPOINT
GO
DBCC FREEPROCCACHE
GO
DBCC SHRINKFILE (TEMPDEV, 1024)
GO
DBCC SHRINKFILE (temp2, 1024)
GO
DBCC SHRINKFILE (temp3, 1024)
GO
DBCC SHRINKFILE (temp8, 1024)
GO
DBCC SHRINKFILE (temp4, 1024)
GO
DBCC SHRINKFILE (temp5, 1024)
GO
DBCC SHRINKFILE (temp6, 1024)
GO
DBCC SHRINKFILE (temp7, 1024)
GO







