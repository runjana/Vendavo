USE [msdb]
GO

/****** Object:  Job [find different jobs]    Script Date: 2019-01-17 11:19:19 ******/
BEGIN TRANSACTION
DECLARE @ReturnCode INT
SELECT @ReturnCode = 0
/****** Object:  JobCategory [[Uncategorized (Local)]]    Script Date: 2019-01-17 11:19:19 ******/
IF NOT EXISTS (SELECT name FROM msdb.dbo.syscategories WHERE name=N'[Uncategorized (Local)]' AND category_class=1)
BEGIN
EXEC @ReturnCode = msdb.dbo.sp_add_category @class=N'JOB', @type=N'LOCAL', @name=N'[Uncategorized (Local)]'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback

END

DECLARE @jobId BINARY(16)
EXEC @ReturnCode =  msdb.dbo.sp_add_job @job_name=N'find different jobs', 
		@enabled=1, 
		@notify_level_eventlog=0, 
		@notify_level_email=0, 
		@notify_level_netsend=0, 
		@notify_level_page=0, 
		@delete_level=0, 
		@description=N'No description available.', 
		@category_name=N'[Uncategorized (Local)]', 
		@owner_login_name=N'NAVETTI\ranjana.ghimire', @job_id = @jobId OUTPUT
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [job list]    Script Date: 2019-01-17 11:19:19 ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'job list', 
		@step_id=1, 
		@cmdexec_success_code=0, 
		@on_success_action=1, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'
use msdb

declare @msg nvarchar(max)
declare @server nvarchar(max)
declare @sub nvarchar(max)
declare @job_query nvarchar(max)
declare @errornumber nvarchar(max)
declare @errormessage nvarchar(max)

begin

declare @svrName varchar(255)
declare @sql varchar(5000)

set @sub=''SQL Server Job Report on Volvo''
set @msg=''Please find the Job difference report for SQL Server ''+@@SERVERNAME+''<br><br><br>''

declare @body1 varchar(max)

set @body1 = cast( (
select td =  
			 convert(varchar,servername)+''</td><td style="width: 300px;"><span style="color: #00FF00;">'' +
             convert(varchar,Job_Name)  +''</td><td style="width: 300px;"><span style="color: #00FF00;">'' +
			 convert(varchar,Description)  +''</td><td style="width: 300px;"><san style="color: #00FF00;">'' +
			 convert(varchar,Start_At_Step)  +''</td><td style="width: 300px;"><span style="color: #00FF00;">'' +
			 convert(varchar,Step_No)  +''</td><td style="width: 300px;"><span style="color: #00FF00;">'' +
			 convert(varchar,StepName)  +''</td><td style="width: 300px;"><span style="color: #00FF00;">'' +
			 convert(varchar,Database_Name)  +''</td><td style="width: 300px;"><span style="color: #00FF00;">'' +
			 convert(varchar,ExecutableCommand)  +''</td><td style="width: 300px;"><span style="color: #00FF00;">'' +
			 convert(varchar,On_Success_Action)  +''</td><td style="width: 300px;"><span style="color: #00FF00;">'' +
			 convert(varchar,RetryAttempts)  +''</td><td style="width: 300px;"><span style="color: #00FF00;">'' +
			 convert(varchar,RetryInterval_Minutes)  +''</td><td style="width: 300px;"><span style="color: #00FF00;">'' +
			 convert(varchar,On_Failure_Action)+ ''</td>''  
from 
((SELECT 
	A_servername                AS 	servername                ,
	A_Job_Name                  AS 	Job_Name                  ,
	A_Description               AS 	Description               ,
	A_Start_At_Step             AS 	Start_At_Step             ,
	A_Step_No                   AS 	Step_No                   ,
	A_StepName                  AS 	StepName                  ,
	A_Database_Name             AS 	Database_Name             ,
	A_ExecutableCommand         AS 	ExecutableCommand         ,
	A_On_Success_Action         AS 	On_Success_Action         ,
	A_RetryAttempts             AS 	RetryAttempts             ,
	A_RetryInterval_Minutes     AS 	RetryInterval_Minutes     ,
	A_On_Failure_Action         AS 	On_Failure_Action         

	FROM
(SELECT 
a.servername                     as A_servername                ,     
a.Job_Name                       as A_Job_Name                  ,     
a.Description                    as A_Description               ,     
a.Start_At_Step                  as A_Start_At_Step             ,     
a.Step_No                        as A_Step_No                   ,     
a.StepName                       as A_StepName                  ,     
a.Database_Name                  as A_Database_Name             ,     
a.ExecutableCommand              as A_ExecutableCommand         ,     
a.On_Success_Action              as A_On_Success_Action         ,     
a.RetryAttempts                  as A_RetryAttempts             ,     
a.RetryInterval_Minutes          as A_RetryInterval_Minutes     ,     
a.On_Failure_Action              as A_On_Failure_Action         ,     
b.servername                     as B_servername                ,     
b.Job_Name                       as B_Job_Name                  ,     
b.Description                    as B_Description               ,     
b.Start_At_Step                  as B_Start_At_Step             ,     
b.Step_No                        as B_Step_No                   ,     
b.StepName                       as B_StepName                  ,     
b.Database_Name                  as B_Database_Name             ,     
b.ExecutableCommand              as B_ExecutableCommand         ,     
b.On_Success_Action              as B_On_Success_Action         ,     
b.RetryAttempts                  as B_RetryAttempts             ,     
b.RetryInterval_Minutes          as B_RetryInterval_Minutes     ,     
b.On_Failure_Action              as B_On_Failure_Action            

			from
			(Select distinct 
			  ''NAV-c00db02p-A'' as servername
			  ,sJob.Name As Job_Name
			  ,sJob.Description
			  ,sJob.Start_Step_ID As Start_At_Step
			  ,sJStp.Step_ID As Step_No
			  ,sJStp.step_name AS StepName
			  ,sJStp.database_name AS Database_Name
			  ,sJStp.command AS ExecutableCommand
			  ,Case sJStp.on_success_action      When 1       Then ''Quit the job reporting success''
												 When 2       Then ''Quit the job reporting failure''
												 When 3       Then ''Go to the next step''
												 When 4       Then ''Go to Step: ''+ QuoteName(Cast(sJStp.On_Success_Step_ID As Varchar(3)))
													 + '' ''
													 + sOSSTP.Step_Name
			   End As On_Success_Action
			  ,sJStp.retry_attempts AS RetryAttempts
			  ,sJStp.retry_interval AS RetryInterval_Minutes
			  ,Case sJStp.on_fail_action       When 1       Then ''Quit the job reporting success''
											   When 2       Then ''Quit the job reporting failure''
											   When 3       Then ''Go to the next step''
											   When 4       Then ''Go to Step: ''+ QuoteName(Cast(sJStp.On_Fail_Step_ID As Varchar(3)))+ '' ''+ sOFSTP.step_name   End As On_Failure_Action
			From [nav-c00db02p-a].MSDB.dbo.SysJobSteps As sJStp
			  Inner Join [nav-c00db02p-a].MSDB.dbo.SysJobs As sJob         On sJStp.Job_ID = sJob.Job_ID
			  Left Join [nav-c00db02p-a].MSDB.dbo.SysJobSteps As sOSSTP    On sJStp.Job_ID = sOSSTP.Job_ID      And sJStp.On_Success_Step_ID = sOSSTP.Step_ID
			  Left Join [nav-c00db02p-a].MSDB.dbo.SysJobSteps As sOFSTP    On sJStp.Job_ID = sOFSTP.Job_ID      And sJStp.On_Fail_Step_ID = sOFSTP.Step_ID
			  where sJob.Enabled=1 ) a
			FULL OUTER JOIN
			  (Select distinct 
			  ''[nav-c00db02p-b]'' as servername
			  ,sJob.Name As Job_Name
			  ,sJob.Description
			  ,sJob.Start_Step_ID As Start_At_Step
			  ,sJStp.Step_ID As Step_No
			  ,sJStp.step_name AS StepName
			  ,sJStp.database_name AS Database_Name
			  ,sJStp.command AS ExecutableCommand
			  ,Case sJStp.on_success_action      When 1       Then ''Quit the job reporting success''
												 When 2       Then ''Quit the job reporting failure''
												 When 3       Then ''Go to the next step''
												 When 4       Then ''Go to Step: ''+ QuoteName(Cast(sJStp.On_Success_Step_ID As Varchar(3)))
													 + '' ''
													 + sOSSTP.Step_Name
			   End As On_Success_Action
			  ,sJStp.retry_attempts AS RetryAttempts
			  ,sJStp.retry_interval AS RetryInterval_Minutes
			  ,Case sJStp.on_fail_action       When 1       Then ''Quit the job reporting success''
											   When 2       Then ''Quit the job reporting failure''
											   When 3       Then ''Go to the next step''
											   When 4       Then ''Go to Step: ''+ QuoteName(Cast(sJStp.On_Fail_Step_ID As Varchar(3)))+ '' ''+ sOFSTP.step_name   End As On_Failure_Action
			From [nav-c00db02p-b].MSDB.dbo.SysJobSteps As sJStp
			  Inner Join [nav-c00db02p-b].MSDB.dbo.SysJobs As sJob         On sJStp.Job_ID = sJob.Job_ID
			  Left Join [nav-c00db02p-b].MSDB.dbo.SysJobSteps As sOSSTP    On sJStp.Job_ID = sOSSTP.Job_ID      And sJStp.On_Success_Step_ID = sOSSTP.Step_ID
			  Left Join [nav-c00db02p-b].MSDB.dbo.SysJobSteps As sOFSTP    On sJStp.Job_ID = sOFSTP.Job_ID      And sJStp.On_Fail_Step_ID = sOFSTP.Step_ID
			  where sJob.Enabled=1) 
			  b on a.Job_Name=b.Job_Name and a.StepName=b.StepName and a.ExecutableCommand=b.ExecutableCommand) A
			  WHERE A.A_servername IS NULL OR B_servername IS NULL)
union
(SELECT 
	B_servername                ,
	B_Job_Name                  ,
	B_Description               ,
	B_Start_At_Step             ,
	B_Step_No                   ,
	B_StepName                  ,
	B_Database_Name             ,
	B_ExecutableCommand         ,
	B_On_Success_Action         ,
	B_RetryAttempts             ,
	B_RetryInterval_Minutes     ,
	B_On_Failure_Action          
	FROM
(SELECT 
a.servername                     as A_servername                ,     
a.Job_Name                       as A_Job_Name                  ,     
a.Description                    as A_Description               ,     
a.Start_At_Step                  as A_Start_At_Step             ,     
a.Step_No                        as A_Step_No                   ,     
a.StepName                       as A_StepName                  ,     
a.Database_Name                  as A_Database_Name             ,     
a.ExecutableCommand              as A_ExecutableCommand         ,     
a.On_Success_Action              as A_On_Success_Action         ,     
a.RetryAttempts                  as A_RetryAttempts             ,     
a.RetryInterval_Minutes          as A_RetryInterval_Minutes     ,     
a.On_Failure_Action              as A_On_Failure_Action         ,     
b.servername                     as B_servername                ,     
b.Job_Name                       as B_Job_Name                  ,     
b.Description                    as B_Description               ,     
b.Start_At_Step                  as B_Start_At_Step             ,     
b.Step_No                        as B_Step_No                   ,     
b.StepName                       as B_StepName                  ,     
b.Database_Name                  as B_Database_Name             ,     
b.ExecutableCommand              as B_ExecutableCommand         ,     
b.On_Success_Action              as B_On_Success_Action         ,     
b.RetryAttempts                  as B_RetryAttempts             ,     
b.RetryInterval_Minutes          as B_RetryInterval_Minutes     ,     
b.On_Failure_Action              as B_On_Failure_Action            

			from
			(Select distinct 
			  ''NAV-c00db02p-A'' as servername
			  ,sJob.Name As Job_Name
			  ,sJob.Description
			  ,sJob.Start_Step_ID As Start_At_Step
			  ,sJStp.Step_ID As Step_No
			  ,sJStp.step_name AS StepName
			  ,sJStp.database_name AS Database_Name
			  ,sJStp.command AS ExecutableCommand
			  ,Case sJStp.on_success_action      When 1       Then ''Quit the job reporting success''
												 When 2       Then ''Quit the job reporting failure''
												 When 3       Then ''Go to the next step''
												 When 4       Then ''Go to Step: ''+ QuoteName(Cast(sJStp.On_Success_Step_ID As Varchar(3)))
													 + '' ''
													 + sOSSTP.Step_Name
			   End As On_Success_Action
			  ,sJStp.retry_attempts AS RetryAttempts
			  ,sJStp.retry_interval AS RetryInterval_Minutes
			  ,Case sJStp.on_fail_action       When 1       Then ''Quit the job reporting success''
											   When 2       Then ''Quit the job reporting failure''
											   When 3       Then ''Go to the next step''
											   When 4       Then ''Go to Step: ''+ QuoteName(Cast(sJStp.On_Fail_Step_ID As Varchar(3)))+ '' ''+ sOFSTP.step_name   End As On_Failure_Action
			From [nav-c00db02p-a].MSDB.dbo.SysJobSteps As sJStp
			  Inner Join [nav-c00db02p-a].MSDB.dbo.SysJobs As sJob         On sJStp.Job_ID = sJob.Job_ID
			  Left Join [nav-c00db02p-a].MSDB.dbo.SysJobSteps As sOSSTP    On sJStp.Job_ID = sOSSTP.Job_ID      And sJStp.On_Success_Step_ID = sOSSTP.Step_ID
			  Left Join [nav-c00db02p-a].MSDB.dbo.SysJobSteps As sOFSTP    On sJStp.Job_ID = sOFSTP.Job_ID      And sJStp.On_Fail_Step_ID = sOFSTP.Step_ID
			  where sJob.Enabled=1 ) a
			FULL OUTER JOIN
			  (Select distinct 
			  ''NAV-c00db02p-B'' as servername
			  ,sJob.Name As Job_Name
			  ,sJob.Description
			  ,sJob.Start_Step_ID As Start_At_Step
			  ,sJStp.Step_ID As Step_No
			  ,sJStp.step_name AS StepName
			  ,sJStp.database_name AS Database_Name
			  ,sJStp.command AS ExecutableCommand
			  ,Case sJStp.on_success_action      When 1       Then ''Quit the job reporting success''
												 When 2       Then ''Quit the job reporting failure''
												 When 3       Then ''Go to the next step''
												 When 4       Then ''Go to Step: ''+ QuoteName(Cast(sJStp.On_Success_Step_ID As Varchar(3)))
													 + '' ''
													 + sOSSTP.Step_Name
			   End As On_Success_Action
			  ,sJStp.retry_attempts AS RetryAttempts
			  ,sJStp.retry_interval AS RetryInterval_Minutes
			  ,Case sJStp.on_fail_action       When 1       Then ''Quit the job reporting success''
											   When 2       Then ''Quit the job reporting failure''
											   When 3       Then ''Go to the next step''
											   When 4       Then ''Go to Step: ''+ QuoteName(Cast(sJStp.On_Fail_Step_ID As Varchar(3)))+ '' ''+ sOFSTP.step_name   End As On_Failure_Action
			From [nav-c00db02p-b].MSDB.dbo.SysJobSteps As sJStp
			  Inner Join [nav-c00db02p-b].MSDB.dbo.SysJobs As sJob         On sJStp.Job_ID = sJob.Job_ID
			  Left Join [nav-c00db02p-b].MSDB.dbo.SysJobSteps As sOSSTP    On sJStp.Job_ID = sOSSTP.Job_ID      And sJStp.On_Success_Step_ID = sOSSTP.Step_ID
			  Left Join [nav-c00db02p-b].MSDB.dbo.SysJobSteps As sOFSTP    On sJStp.Job_ID = sOFSTP.Job_ID      And sJStp.On_Fail_Step_ID = sOFSTP.Step_ID
			  where sJob.Enabled=1) 
			  b on a.Job_Name=b.Job_Name and a.StepName=b.StepName and a.ExecutableCommand=b.ExecutableCommand) A
			  WHERE A.A_servername IS NULL OR B_servername IS NULL)) X WHERE X.servername IS NOT NULL ORDER BY Job_Name
   
for xml path( ''tr'' ), type ) as varchar(max) )  

set @body1 = ''<b>SQL Agent Job Report</b><br><br>
		<table style="height: 99px; width: 1000px; background-color: #000000; border-color: white; margin-left: auto; margin-right: auto;" border="1" cellspacing="2" cellpadding="5">''
          + ''<tr><strong><b><th>Servername</th><th>Job Name</th>
		  <th>Description</th>
		  <th>Start at step</th>
		  <th>Step Number</th>
		  <th>Step Name</th>
		  <th>Database</th>
		  <th>Command</th>
		  <th>On Success Action</th>
		  <th>Retry Interval</th>
		  <th>RetryAttempts</th>		  
		  <th>On Failure Action</th>		  
		  </b></strong></tr>''
          + replace( replace( @body1, ''&lt;'', ''<'' ), ''&gt;'', ''>'' )
          + ''</table><br><br> Regards,<br>DBA Team''

-------------------------//For unreachable servers//------------------------------------


declare @header varchar(max),@close nvarchar(200),@body nvarchar(maX)

SET @close=''</TABLE>''

set @body=@body1

if((
SELECT count(1) FROM 
((SELECT 
	A_servername                AS 	servername                ,
	A_Job_Name                  AS 	Job_Name                  ,
	A_Description               AS 	Description               ,
	A_Start_At_Step             AS 	Start_At_Step             ,
	A_Step_No                   AS 	Step_No                   ,
	A_StepName                  AS 	StepName                  ,
	A_Database_Name             AS 	Database_Name             ,
	A_ExecutableCommand         AS 	ExecutableCommand         ,
	A_On_Success_Action         AS 	On_Success_Action         ,
	A_RetryAttempts             AS 	RetryAttempts             ,
	A_RetryInterval_Minutes     AS 	RetryInterval_Minutes     ,
	A_On_Failure_Action         AS 	On_Failure_Action         

	FROM
(SELECT 
a.servername                     as A_servername                ,     
a.Job_Name                       as A_Job_Name                  ,     
a.Description                    as A_Description               ,     
a.Start_At_Step                  as A_Start_At_Step             ,     
a.Step_No                        as A_Step_No                   ,     
a.StepName                       as A_StepName                  ,     
a.Database_Name                  as A_Database_Name             ,     
a.ExecutableCommand              as A_ExecutableCommand         ,     
a.On_Success_Action              as A_On_Success_Action         ,     
a.RetryAttempts                  as A_RetryAttempts             ,     
a.RetryInterval_Minutes          as A_RetryInterval_Minutes     ,     
a.On_Failure_Action              as A_On_Failure_Action         ,     
b.servername                     as B_servername                ,     
b.Job_Name                       as B_Job_Name                  ,     
b.Description                    as B_Description               ,     
b.Start_At_Step                  as B_Start_At_Step             ,     
b.Step_No                        as B_Step_No                   ,     
b.StepName                       as B_StepName                  ,     
b.Database_Name                  as B_Database_Name             ,     
b.ExecutableCommand              as B_ExecutableCommand         ,     
b.On_Success_Action              as B_On_Success_Action         ,     
b.RetryAttempts                  as B_RetryAttempts             ,     
b.RetryInterval_Minutes          as B_RetryInterval_Minutes     ,     
b.On_Failure_Action              as B_On_Failure_Action            

			from
			(Select distinct 
			  ''NAV-c00db02p-A'' as servername
			  ,sJob.Name As Job_Name
			  ,sJob.Description
			  ,sJob.Start_Step_ID As Start_At_Step
			  ,sJStp.Step_ID As Step_No
			  ,sJStp.step_name AS StepName
			  ,sJStp.database_name AS Database_Name
			  ,sJStp.command AS ExecutableCommand
			  ,Case sJStp.on_success_action      When 1       Then ''Quit the job reporting success''
												 When 2       Then ''Quit the job reporting failure''
												 When 3       Then ''Go to the next step''
												 When 4       Then ''Go to Step: ''+ QuoteName(Cast(sJStp.On_Success_Step_ID As Varchar(3)))
													 + '' ''
													 + sOSSTP.Step_Name
			   End As On_Success_Action
			  ,sJStp.retry_attempts AS RetryAttempts
			  ,sJStp.retry_interval AS RetryInterval_Minutes
			  ,Case sJStp.on_fail_action       When 1       Then ''Quit the job reporting success''
											   When 2       Then ''Quit the job reporting failure''
											   When 3       Then ''Go to the next step''
											   When 4       Then ''Go to Step: ''+ QuoteName(Cast(sJStp.On_Fail_Step_ID As Varchar(3)))+ '' ''+ sOFSTP.step_name   End As On_Failure_Action
			From [nav-c00db02p-a].MSDB.dbo.SysJobSteps As sJStp
			  Inner Join [nav-c00db02p-a].MSDB.dbo.SysJobs As sJob         On sJStp.Job_ID = sJob.Job_ID
			  Left Join [nav-c00db02p-a].MSDB.dbo.SysJobSteps As sOSSTP    On sJStp.Job_ID = sOSSTP.Job_ID      And sJStp.On_Success_Step_ID = sOSSTP.Step_ID
			  Left Join [nav-c00db02p-a].MSDB.dbo.SysJobSteps As sOFSTP    On sJStp.Job_ID = sOFSTP.Job_ID      And sJStp.On_Fail_Step_ID = sOFSTP.Step_ID
			  where sJob.Enabled=1 ) a
			FULL OUTER JOIN
			  (Select distinct 
			  ''[nav-c00db02p-b]'' as servername
			  ,sJob.Name As Job_Name
			  ,sJob.Description
			  ,sJob.Start_Step_ID As Start_At_Step
			  ,sJStp.Step_ID As Step_No
			  ,sJStp.step_name AS StepName
			  ,sJStp.database_name AS Database_Name
			  ,sJStp.command AS ExecutableCommand
			  ,Case sJStp.on_success_action      When 1       Then ''Quit the job reporting success''
												 When 2       Then ''Quit the job reporting failure''
												 When 3       Then ''Go to the next step''
												 When 4       Then ''Go to Step: ''+ QuoteName(Cast(sJStp.On_Success_Step_ID As Varchar(3)))
													 + '' ''
													 + sOSSTP.Step_Name
			   End As On_Success_Action
			  ,sJStp.retry_attempts AS RetryAttempts
			  ,sJStp.retry_interval AS RetryInterval_Minutes
			  ,Case sJStp.on_fail_action       When 1       Then ''Quit the job reporting success''
											   When 2       Then ''Quit the job reporting failure''
											   When 3       Then ''Go to the next step''
											   When 4       Then ''Go to Step: ''+ QuoteName(Cast(sJStp.On_Fail_Step_ID As Varchar(3)))+ '' ''+ sOFSTP.step_name   End As On_Failure_Action
			From [nav-c00db02p-b].MSDB.dbo.SysJobSteps As sJStp
			  Inner Join [nav-c00db02p-b].MSDB.dbo.SysJobs As sJob         On sJStp.Job_ID = sJob.Job_ID
			  Left Join [nav-c00db02p-b].MSDB.dbo.SysJobSteps As sOSSTP    On sJStp.Job_ID = sOSSTP.Job_ID      And sJStp.On_Success_Step_ID = sOSSTP.Step_ID
			  Left Join [nav-c00db02p-b].MSDB.dbo.SysJobSteps As sOFSTP    On sJStp.Job_ID = sOFSTP.Job_ID      And sJStp.On_Fail_Step_ID = sOFSTP.Step_ID
			  where sJob.Enabled=1) 
			  b on a.Job_Name=b.Job_Name and a.StepName=b.StepName and a.ExecutableCommand=b.ExecutableCommand) A
			  WHERE A.A_servername IS NULL OR B_servername IS NULL)
union
(SELECT 
	B_servername                ,
	B_Job_Name                  ,
	B_Description               ,
	B_Start_At_Step             ,
	B_Step_No                   ,
	B_StepName                  ,
	B_Database_Name             ,
	B_ExecutableCommand         ,
	B_On_Success_Action         ,
	B_RetryAttempts             ,
	B_RetryInterval_Minutes     ,
	B_On_Failure_Action          
	FROM
(SELECT 
a.servername                     as A_servername                ,     
a.Job_Name                       as A_Job_Name                  ,     
a.Description                    as A_Description               ,     
a.Start_At_Step                  as A_Start_At_Step             ,     
a.Step_No                        as A_Step_No                   ,     
a.StepName                       as A_StepName                  ,     
a.Database_Name                  as A_Database_Name             ,     
a.ExecutableCommand              as A_ExecutableCommand         ,     
a.On_Success_Action              as A_On_Success_Action         ,     
a.RetryAttempts                  as A_RetryAttempts             ,     
a.RetryInterval_Minutes          as A_RetryInterval_Minutes     ,     
a.On_Failure_Action              as A_On_Failure_Action         ,     
b.servername                     as B_servername                ,     
b.Job_Name                       as B_Job_Name                  ,     
b.Description                    as B_Description               ,     
b.Start_At_Step                  as B_Start_At_Step             ,     
b.Step_No                        as B_Step_No                   ,     
b.StepName                       as B_StepName                  ,     
b.Database_Name                  as B_Database_Name             ,     
b.ExecutableCommand              as B_ExecutableCommand         ,     
b.On_Success_Action              as B_On_Success_Action         ,     
b.RetryAttempts                  as B_RetryAttempts             ,     
b.RetryInterval_Minutes          as B_RetryInterval_Minutes     ,     
b.On_Failure_Action              as B_On_Failure_Action            

			from
			(Select distinct 
			  ''NAV-c00db02p-A'' as servername
			  ,sJob.Name As Job_Name
			  ,sJob.Description
			  ,sJob.Start_Step_ID As Start_At_Step
			  ,sJStp.Step_ID As Step_No
			  ,sJStp.step_name AS StepName
			  ,sJStp.database_name AS Database_Name
			  ,sJStp.command AS ExecutableCommand
			  ,Case sJStp.on_success_action      When 1       Then ''Quit the job reporting success''
												 When 2       Then ''Quit the job reporting failure''
												 When 3       Then ''Go to the next step''
												 When 4       Then ''Go to Step: ''+ QuoteName(Cast(sJStp.On_Success_Step_ID As Varchar(3)))
													 + '' ''
													 + sOSSTP.Step_Name
			   End As On_Success_Action
			  ,sJStp.retry_attempts AS RetryAttempts
			  ,sJStp.retry_interval AS RetryInterval_Minutes
			  ,Case sJStp.on_fail_action       When 1       Then ''Quit the job reporting success''
											   When 2       Then ''Quit the job reporting failure''
											   When 3       Then ''Go to the next step''
											   When 4       Then ''Go to Step: ''+ QuoteName(Cast(sJStp.On_Fail_Step_ID As Varchar(3)))+ '' ''+ sOFSTP.step_name   End As On_Failure_Action
			From [nav-c00db02p-a].MSDB.dbo.SysJobSteps As sJStp
			  Inner Join [nav-c00db02p-a].MSDB.dbo.SysJobs As sJob         On sJStp.Job_ID = sJob.Job_ID
			  Left Join [nav-c00db02p-a].MSDB.dbo.SysJobSteps As sOSSTP    On sJStp.Job_ID = sOSSTP.Job_ID      And sJStp.On_Success_Step_ID = sOSSTP.Step_ID
			  Left Join [nav-c00db02p-a].MSDB.dbo.SysJobSteps As sOFSTP    On sJStp.Job_ID = sOFSTP.Job_ID      And sJStp.On_Fail_Step_ID = sOFSTP.Step_ID
			  where sJob.Enabled=1 ) a
			FULL OUTER JOIN
			  (Select distinct 
			  ''NAV-c00db02p-B'' as servername
			  ,sJob.Name As Job_Name
			  ,sJob.Description
			  ,sJob.Start_Step_ID As Start_At_Step
			  ,sJStp.Step_ID As Step_No
			  ,sJStp.step_name AS StepName
			  ,sJStp.database_name AS Database_Name
			  ,sJStp.command AS ExecutableCommand
			  ,Case sJStp.on_success_action      When 1       Then ''Quit the job reporting success''
												 When 2       Then ''Quit the job reporting failure''
												 When 3       Then ''Go to the next step''
												 When 4       Then ''Go to Step: ''+ QuoteName(Cast(sJStp.On_Success_Step_ID As Varchar(3)))
													 + '' ''
													 + sOSSTP.Step_Name
			   End As On_Success_Action
			  ,sJStp.retry_attempts AS RetryAttempts
			  ,sJStp.retry_interval AS RetryInterval_Minutes
			  ,Case sJStp.on_fail_action       When 1       Then ''Quit the job reporting success''
											   When 2       Then ''Quit the job reporting failure''
											   When 3       Then ''Go to the next step''
											   When 4       Then ''Go to Step: ''+ QuoteName(Cast(sJStp.On_Fail_Step_ID As Varchar(3)))+ '' ''+ sOFSTP.step_name   End As On_Failure_Action
			From [nav-c00db02p-b].MSDB.dbo.SysJobSteps As sJStp
			  Inner Join [nav-c00db02p-b].MSDB.dbo.SysJobs As sJob         On sJStp.Job_ID = sJob.Job_ID
			  Left Join [nav-c00db02p-b].MSDB.dbo.SysJobSteps As sOSSTP    On sJStp.Job_ID = sOSSTP.Job_ID      And sJStp.On_Success_Step_ID = sOSSTP.Step_ID
			  Left Join [nav-c00db02p-b].MSDB.dbo.SysJobSteps As sOFSTP    On sJStp.Job_ID = sOFSTP.Job_ID      And sJStp.On_Fail_Step_ID = sOFSTP.Step_ID
			  where sJob.Enabled=1) 
			  b on a.Job_Name=b.Job_Name and a.StepName=b.StepName and a.ExecutableCommand=b.ExecutableCommand) A
			  WHERE A.A_servername IS NULL OR B_servername IS NULL)) X WHERE X.servername IS NOT NULL)>0)
			  begin


EXEC sp_send_dbmail 
  @profile_name=''navettimail'',
  @recipients=''ranjana.ghimire@navetti.com;sanja.mitrovska@navetti.com'',
  @body_format=''HTML'',
  @subject=@sub,
  @body=@body
end


end', 
		@database_name=N'master', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_update_job @job_id = @jobId, @start_step_id = 1
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobschedule @job_id=@jobId, @name=N'find jobs', 
		@enabled=1, 
		@freq_type=4, 
		@freq_interval=1, 
		@freq_subday_type=1, 
		@freq_subday_interval=0, 
		@freq_relative_interval=0, 
		@freq_recurrence_factor=0, 
		@active_start_date=20190117, 
		@active_end_date=99991231, 
		@active_start_time=600, 
		@active_end_time=235959, 
		@schedule_uid=N'5e92c6d9-225a-4684-ac5c-5f1d032ad9f5'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobserver @job_id = @jobId, @server_name = N'(local)'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
COMMIT TRANSACTION
GOTO EndSave
QuitWithRollback:
    IF (@@TRANCOUNT > 0) ROLLBACK TRANSACTION
EndSave:

GO


