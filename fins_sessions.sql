
	select session_id,db_name(database_id),status,command,percent_complete,blocking_session_id,start_time,wait_time/(1000*60) as wait_time_min,a.cpu_time,datediff(minute,start_time,getdate()) as elapsed_time_min,wait_type from sys.dm_exec_requests a
	 where status not in ('background','sleeping') and (
      session_id in (0,295) 
	  or  percent_complete <>0 
	  or blocking_session_id <>0 
	 or db_name(database_id) like '%contitrade%' )
	 order by a.cpu_time desc

-- sp_who2 194

/*

select * from msdb..sysjobs where job_id = 0xAABE55459859F74BBF0F67221DEC914A

sp_whoisactive

SELECT  top 1 sqltext.TEXT,
qp.query_plan,
req.session_id,
req.status,
req.command,
req.cpu_time,
req.total_elapsed_time,
db_name(req.database_id) as databasename,
req.*
FROM sys.dm_exec_requests req
CROSS APPLY sys.dm_exec_sql_text(sql_handle) AS sqltext
cross apply sys.dm_exec_cached_plans AS CP 
 CROSS APPLY sys.dm_exec_query_plan( req.plan_handle)AS QP
where objtype = 'Adhoc' and cp.cacheobjtype = 'Compiled Plan' and req.session_id in (125)  
 

SELECT instance_name,[object_name],
[counter_name],
[cntr_value] FROM sys.dm_os_performance_counters
WHERE [object_name] LIKE '%Database Replica%'
AND [counter_name] = 'Log remaining for undo'


EXEC xp_readerrorlog 0, 1, N'kill', NULL, NULL, NULL, N'DESC'


*/




-- select name,log_reuse_wait_desc from sys.databases where log_reuse_wait_desc in ('LOG_BACKUP')



--  select db_name(database_id),* from master.sys.dm_hadr_database_replica_states where synchronization_health_desc not in ('HEALTHY')


-- select 'ALTER DATABASE ['+name+'] SET  ENABLE_BROKER WITH  ROLLBACK IMMEDIATE' from sys.databases where is_broker_enabled=0 and name not in ('master','model','msdb','temp')


