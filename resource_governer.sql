USE master
go
CREATE RESOURCE POOL NBNPaccar WITH (MAX_CPU_PERCENT = 50, MIN_CPU_PERCENT = 0);
CREATE RESOURCE POOL allother WITH (MAX_CPU_PERCENT = 50);
CREATE WORKLOAD GROUP NBNPaccar USING NBNPaccar
CREATE WORKLOAD GROUP allother USING allother
go
create FUNCTION dbo.classifier () RETURNS sysname WITH SCHEMABINDING AS
BEGIN
   RETURN (CASE  WHEN ORIGINAL_LOGIN( )='NAVETTI\svc_pon' THEN 'NBNPaccar' 
	                 when  ORIGINAL_LOGIN( )='NAVETTI\svc_tetrapak' THEN 'NBNPaccar' 
					 when  ORIGINAL_LOGIN( )='NAVETTI\BackupAdmin' THEN 'NBNPaccar' 
					  when  ORIGINAL_LOGIN( )='NAVETTI\svc_pierce' THEN 'NBNPaccar' 
					   when  ORIGINAL_LOGIN( )='NAVETTI\svc_Sandvik' THEN 'NBNPaccar' 
					    when  ORIGINAL_LOGIN( )='NAVETTI\svc_trumpf' THEN 'NBNPaccar' 
						 when  ORIGINAL_LOGIN( )='NAVETTI\svc_contitrade' THEN 'NBNPaccar' 
						  when  ORIGINAL_LOGIN( )='NAVETTI\svc_abb' THEN 'NBNPaccar' 
					  when  ORIGINAL_LOGIN( )='NAVETTI\svc_bilstein' THEN 'NBNPaccar' 

   ELSE 'allother' END)
END
go
ALTER RESOURCE GOVERNOR WITH (CLASSIFIER_FUNCTION = dbo.classifier)
ALTER RESOURCE GOVERNOR RECONFIGURE

/*

SELECT * FROM sys.resource_governor_configuration
 

drop WORKLOAD GROUP NBNPaccar
drop WORKLOAD GROUP allother

ALTER RESOURCE GOVERNOR WITH (CLASSIFIER_FUNCTION = NULL)
GO
ALTER RESOURCE GOVERNOR DISABLE
GO
DROP FUNCTION dbo.classifier
GO

drop RESOURCE POOL NBNPaccar
drop RESOURCE POOL allother

USE master
GO
SELECT ConSess.session_id, ConSess.login_name,  WorLoGroName.name
  FROM sys.dm_exec_sessions AS ConSess
  JOIN sys.dm_resource_governor_workload_groups AS WorLoGroName
      ON ConSess.group_id = WorLoGroName.group_id
  WHERE session_id > 60 and name not in ('default','internal');

*/

