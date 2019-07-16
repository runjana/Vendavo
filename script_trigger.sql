SELECT db_name() as database_name,'TRIGGER' AS 'TRG',SO.name as 'name',SM.definition
FROM sys.sql_modules SM 
INNER JOIN sys.objects SO ON SM.Object_id = SO.Object_id
 WHERE SO.type = 'TR'