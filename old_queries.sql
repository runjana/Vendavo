SELECT top 100
sql_text.text, 
DB_NAME(qp.dbid) as databasename,
last_worker_time/(1000*60) ,
qp.query_plan
FROM sys.dm_exec_query_stats st 
CROSS APPLY sys.dm_exec_sql_text(st.sql_handle) AS sql_text
INNER JOIN sys.dm_exec_cached_plans cp
ON cp.plan_handle = st.plan_handle
CROSS APPLY sys.dm_exec_query_plan(cp.plan_handle) as qp
WHERE st.last_execution_time >= DATEADD(week, -1, getdate()) and DB_NAME(qp.dbid) like '%Contitrade%' and last_worker_time/(1000*60) >100

ORDER BY last_execution_time DESC;