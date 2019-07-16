
SELECT db_name() as database_name,'FUNCTION' AS 'FUNC',so.name as 'name',SM.definition
FROM sys.sql_modules SM 
INNER JOIN sys.Objects SO ON SM.Object_id = SO.Object_id
 WHERE SO.type = 'FN'