
 DECLARE @SP TABLE (DBNAME VARCHAR(200),OBJECTNAME VARCHAR(200),SCRIPT TEXT)

INSERT INTO @SP
SELECT    db_name(),Name,
           OBJECT_DEFINITION(OBJECT_ID) + char(13) +char(10) + 'GO' + char(13) + char(10)
            from sys.procedures
            where is_ms_shipped = 0
 
 select * from @sp