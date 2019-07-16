SELECT db.name AS [DB User], s.name AS [Schema]
FROM sys.database_principals db
JOIN sys.schemas s ON s.principal_id = db.principal_id