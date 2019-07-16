
select 
 
convert(text,'use msdb ;
BEGIN TRANSACTION
DECLARE @ReturnCode INT
SELECT @ReturnCode = 0
IF NOT EXISTS (SELECT name FROM msdb.dbo.syscategories WHERE name=N'''+sc.name+''' AND category_class=1)
BEGIN
EXEC @ReturnCode = msdb.dbo.sp_add_category @class=N''JOB'', @type=N''LOCAL'', @name=N'''+sc.name+'''
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
END

DECLARE @jobId BINARY(16)
EXEC @ReturnCode =  msdb.dbo.sp_add_job @job_name=N'''+convert(varchar,j.name)+''', 
		@enabled='+convert(varchar,j.enabled)+', 
		@notify_level_eventlog='+convert(varchar,j.notify_level_eventlog)+', 
		@notify_level_email='+convert(varchar,j.notify_level_email)+', 
		@notify_level_netsend='+convert(varchar,notify_level_netsend)+', 
		@notify_level_page='+convert(varchar,j.notify_level_page)+', 
		@delete_level='+convert(varchar,j.delete_level)+', 
		@description=N'''+convert(varchar,j.description)+''', 
		@category_name=N'''+convert(varchar,sc.name)+''', 
		@owner_login_name=N''sa'', @job_id = @jobId OUTPUT
'+stuff ((select ' '+'IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'''+js2.step_name+''', 
		@step_id='+convert(varchar,js2.step_id)+', 
		@cmdexec_success_code=	'+convert(varchar,js2.cmdexec_success_code)+', 
		@on_success_action='+convert(varchar,js2.on_success_action)+', 
		@on_success_step_id='+convert(varchar,js2.on_success_step_id)+', 
		@on_fail_action='+convert(varchar,js2.on_fail_action)+', 
		@on_fail_step_id='+convert(varchar,js2.on_fail_step_id)+', 
		@retry_attempts='+convert(varchar,js2.retry_attempts)+', 
		@retry_interval='+convert(varchar,js2.retry_interval)+', 
		@os_run_priority='+convert(varchar,js2.os_run_priority)+',
		@subsystem=N'''+convert(varchar,js2.subsystem)+''', 
		@command=N'''+REPLACE(convert(varchar,js2.command),'''','''''')+''', 
		@database_name=N'''+convert(varchar,js2.database_name)+''', 
		@flags='+convert(varchar,js2.flags) as column_names 
		from msdb.dbo.sysjobsteps as js2
		where js.job_id=js2.job_id 
		FOR XML PATH(''), TYPE).value('.', 'NVARCHAR(MAX)'), 1, 1, '')
		+'IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_update_job @job_id = @jobId, @start_step_id = 1
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobschedule @job_id=@jobId, @name=N'''+ms.name+''', 
		@enabled='+convert(varchar,ms.enabled)+',
		@freq_type='+convert(varchar,ms.freq_type)+', 
		@freq_interval='+convert(varchar,ms.freq_interval)+', 
		@freq_subday_type='+convert(varchar,ms.freq_subday_type)+', 
		@freq_subday_interval='+convert(varchar,ms.freq_subday_interval)+', 
		@freq_relative_interval='+convert(varchar,ms.freq_relative_interval)+', 
		@freq_recurrence_factor='+convert(varchar,ms.freq_recurrence_factor)+', 
		@active_start_date='+convert(varchar,ms.active_start_date)+', 
		@active_end_date='+convert(varchar,ms.active_end_date)+', 
		@active_start_time='+convert(varchar,ms.active_start_time)+', 
		@active_end_time='+convert(varchar,ms.active_end_time)+', 
		@schedule_uid=N'''+convert(varchar(max),ms.schedule_uid)+'''
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobserver @job_id = @jobId, @server_name = N''(local)''
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
COMMIT TRANSACTION
GOTO EndSave
QuitWithRollback:
    IF (@@TRANCOUNT > 0) ROLLBACK TRANSACTION
EndSave:
')
 from msdb.dbo.sysjobs  j
 inner join  msdb.dbo.sysjobsteps js on j.job_id=js.job_id
 inner join msdb.dbo.syscategories sc on j.category_id = sc. category_id
 inner join  msdb.dbo.sysjobschedules s on s.job_id=j.job_id
 inner join msdb.dbo.sysschedules ms on ms.schedule_id=s.schedule_id
 where j.name='test_job'

