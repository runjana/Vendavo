USE [mRemoteNG2]
GO

/****** Object:  Trigger [dbo].[bck_u_trigger]    Script Date: 9/5/2018 2:21:38 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO



CREATE trigger [dbo].[bck_u_trigger]
on [dbo].[tblCons]
after insert,delete 
as begin
Commit transaction
if update ([ParentID]) or update([Name]) or update([Username]) or update([Password]) or update([DomainName]) or update([Hostname]) or update([Protocol]) or update([Port]) 
begin
Declare @query varchar(max) = 'BACKUP DATABASE [mRemoteNG2] TO  DISK = N''\\NAV-C00DB02P-B\Log_Backup_daily\mremote\'+ format(getdate(),'yyyyMMdd-hhmm')+'.bak'' WITH NOFORMAT, NOINIT, SKIP, NOREWIND, NOUNLOAD, COMPRESSION'
exec (@query)
end
 BEGIN TRANSACTION
end
GO

ALTER TABLE [dbo].[tblCons] ENABLE TRIGGER [bck_u_trigger]
GO


USE [mRemoteNG2]
GO

/****** Object:  Trigger [dbo].[bck_id_trigger]    Script Date: 9/5/2018 2:21:33 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


CREATE trigger [dbo].[bck_id_trigger]
on [dbo].[tblCons]
after insert,delete 
as begin
COMMIT TRANSACTION
Declare @query varchar(max) = 'BACKUP DATABASE [mRemoteNG2] TO  DISK = N''\\NAV-C00DB02P-B\Log_Backup_daily\mremote\'+ format(getdate(),'yyyyMMdd-hhmm')+'.bak'' WITH NOFORMAT, NOINIT, SKIP, NOREWIND, NOUNLOAD, COMPRESSION'
exec (@query)
 BEGIN TRANSACTION
end
GO

ALTER TABLE [dbo].[tblCons] ENABLE TRIGGER [bck_id_trigger]
GO


