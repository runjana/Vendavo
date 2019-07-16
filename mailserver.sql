--================================================================
-- DATABASE MAIL CONFIGURATION
--================================================================
--==========================================================
-- Create a Database Mail account
--==========================================================
EXECUTE msdb.dbo.sysmail_add_account_sp
    @account_name = 'navettimail',
    @description = '',
    @email_address = 'noreply@navetti.com',
    @replyto_address = '',
    @display_name = '',
    @mailserver_name = 'mailgw4.upg.se',
	@port = 25;


SELECT * FROM msdb.dbo.sysmail_profile;
SELECT * FROM msdb.dbo.sysmail_account;
SELECT * FROM msdb.dbo.sysmail_server;



--==========================================================
-- Create a Database Mail Profile
--==========================================================
DECLARE @profile_id INT, @profile_description sysname;
SELECT @profile_id = COALESCE(MAX(profile_id),1) FROM msdb.dbo.sysmail_profile
SELECT @profile_description = 'Database Mail Profile for ' + @@servername 


EXECUTE msdb.dbo.sysmail_add_profile_sp
    @profile_name = 'navettimail',
    @description = @profile_description;

-- Add the account to the profile
EXECUTE msdb.dbo.sysmail_add_profileaccount_sp
    @profile_name = 'navettimail',
    @account_name = 'navettimail',
    @sequence_number = @profile_id;

-- Grant access to the profile to the DBMailUsers role
EXECUTE msdb.dbo.sysmail_add_principalprofile_sp
    @profile_name = 'navettimail',
    @principal_id = 0,
    @is_default = 1 ;


--==========================================================
-- Enable Database Mail
--==========================================================
USE master;
GO

sp_CONFIGURE 'show advanced', 1
GO
RECONFIGURE
GO
sp_CONFIGURE 'Database Mail XPs', 1
GO
RECONFIGURE
GO 


--EXEC master.dbo.xp_instance_regwrite N'HKEY_LOCAL_MACHINE', N'SOFTWARE\Microsoft\MSSQLServer\SQLServerAgent', N'DatabaseMailProfile', N'REG_SZ', N''
--EXEC master.dbo.xp_instance_regwrite N'HKEY_LOCAL_MACHINE', N'SOFTWARE\Microsoft\MSSQLServer\SQLServerAgent', N'UseDatabaseMail', N'REG_DWORD', 1
--GO

EXEC msdb.dbo.sp_set_sqlagent_properties @email_save_in_sent_folder = 0
GO


--==========================================================
-- Review Outcomes
--==========================================================


--==========================================================
-- Test Database Mail
--==========================================================
DECLARE @sub VARCHAR(100)
DECLARE @body_text NVARCHAR(MAX)
SELECT @sub = 'Test from New SQL install on ' + @@servername
SELECT @body_text = N'This is a test of Database Mail.' + CHAR(13) + CHAR(13) + 'SQL Server Version Info: ' + CAST(@@version AS VARCHAR(500))

EXEC msdb.dbo.[sp_send_dbmail] 
    @profile_name = 'navettimail'
  , @recipients = 'ranjana.ghimire@navetti.com'
  , @subject = @sub
  , @body = @body_text

--================================================================
-- SQL Agent Properties Configuration
--================================================================
EXEC msdb.dbo.sp_set_sqlagent_properties 
	@databasemail_profile = 'navettimail'
	, @use_databasemail=1
GO