SELECT TOP 25
o.name AS ObjectName
, i.name AS IndexName
, i.index_id AS IndexID
, dm_ius.user_seeks AS UserSeek
, dm_ius.user_scans AS UserScans
, dm_ius.user_lookups AS UserLookups
, dm_ius.user_updates AS UserUpdates
,o.create_date as date_created
, p.TableRows
, 'DROP INDEX ' + QUOTENAME(i.name)
+ ' ON ' + QUOTENAME(s.name) + '.'
+ QUOTENAME(OBJECT_NAME(dm_ius.OBJECT_ID)) AS 'drop statement'
FROM sys.dm_db_index_usage_stats dm_ius
INNER JOIN sys.indexes i ON i.index_id = dm_ius.index_id 
AND dm_ius.OBJECT_ID = i.OBJECT_ID
INNER JOIN sys.objects o ON dm_ius.OBJECT_ID = o.OBJECT_ID
INNER JOIN sys.schemas s ON o.schema_id = s.schema_id
INNER JOIN (SELECT SUM(p.rows) TableRows, p.index_id, p.OBJECT_ID
FROM sys.partitions p GROUP BY p.index_id, p.OBJECT_ID) p
ON p.index_id = dm_ius.index_id AND dm_ius.OBJECT_ID = p.OBJECT_ID
WHERE OBJECTPROPERTY(dm_ius.OBJECT_ID,'IsUserTable') = 1
AND dm_ius.database_id = DB_ID()
AND i.type_desc = 'nonclustered'
AND i.is_primary_key = 0
AND i.is_unique_constraint = 0
and o.create_date<getdate()-10
and dm_ius.user_seeks + dm_ius.user_scans + dm_ius.user_lookups=0
ORDER BY date_created ASC


---------------------------- duplicate index 

select * from
(select *,row_number() over (partition by  schema1,schema2,table1,table2,column1,column2 order by schema1,schema2,table1,table2,column1,column2) as rw
 from 
(select t1.schemaname as schema1,t2.schemaname as schema2,t1.tablename as table1,t2.tablename as table2,t1.indexname as index1,t2.indexname as index2,t1.columnlist as column1,t2.columnlist as column2 
  from
   (select distinct object_name(i.object_id) tablename,i.name indexname,schema_name(schema_id) as schemaname,
             (select distinct stuff((select ', ' + c.name
                                       from sys.index_columns ic1 inner join 
                                            sys.columns c on ic1.object_id=c.object_id and 
                                                             ic1.column_id=c.column_id
                                      where ic1.index_id = ic.index_id and 
                                            ic1.object_id=i.object_id and 
                                            ic1.index_id=i.index_id
                                      order by index_column_id FOR XML PATH('')),1,2,'')
                from sys.index_columns ic 
               where object_id=i.object_id and index_id=i.index_id) as columnlist
       from sys.indexes i inner join 
    	    sys.index_columns ic on i.object_id=ic.object_id and 
                                    i.index_id=ic.index_id inner join
            sys.objects o on i.object_id=o.object_id 
      where o.is_ms_shipped=0) t1 inner join
   (select distinct object_name(i.object_id) tablename,i.name indexname,schema_name(schema_id) as schemaname,
             (select distinct stuff((select ', ' + c.name
                                       from sys.index_columns ic1 inner join 
                                            sys.columns c on ic1.object_id=c.object_id and 
                                                             ic1.column_id=c.column_id
                                      where ic1.index_id = ic.index_id and 
                                            ic1.object_id=i.object_id and 
                                            ic1.index_id=i.index_id
                                      order by index_column_id FOR XML PATH('')),1,2,'')
                from sys.index_columns ic 
               where object_id=i.object_id and index_id=i.index_id) as columnlist
       from sys.indexes i inner join 
    	    sys.index_columns ic on i.object_id=ic.object_id and 
                                    i.index_id=ic.index_id inner join
            sys.objects o on i.object_id=o.object_id 
 where o.is_ms_shipped=0) t2 on t1.tablename=t2.tablename and t1.schemaname=t2.schemaname and t1.columnlist=t2.columnlist  and
       substring(t2.columnlist,1,len(t1.columnlist))=t1.columnlist and 
       (t1.columnlist<>t2.columnlist or 
         (t1.columnlist=t2.columnlist and t1.indexname<>t2.indexname)) ) a) b  where rw=1
		
