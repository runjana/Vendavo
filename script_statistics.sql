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


SELECT db_name() as database_name,extern.StatName,'CREATE STATISTICS '+extern.StatName+' ON dbo.'+extern.TableName+'( '+
LEFT(replace(replace(column_names,'<column_names>',''),'</column_names>',''),LEN(replace(replace(column_names,'<column_names>',''),'</column_names>',''))-1)+')' as script
 FROM #TEST  AS extern
CROSS APPLY
(
SELECT intern.ColumnName+',' AS column_names from #test AS intern where 
extern.StatName=intern.StatName for xml path('')
) pre_trimmed (column_names)
group by extern.StatName,extern.TableName,column_names



drop table #TEST