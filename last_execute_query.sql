

	SELECT deqs.last_execution_time AS [Time], dest.text AS [Query], dest.*
	FROM sys.dm_exec_query_stats AS deqs
	CROSS APPLY sys.dm_exec_sql_text(deqs.sql_handle) AS dest
	--WHERE dest.dbid = DB_ID('msdb')
	ORDER BY deqs.last_execution_time DESC