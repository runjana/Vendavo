BACKUP CERTIFICATE BackupEncryption TO FILE = '\\NAV-C00DB04P-B\Log_Backup\BackupEncryptionA.cer' 
  WITH PRIVATE KEY(ENCRYPTION BY PASSWORD='t2OU4M01&iO0748q*m$4qpZi184WV487', FILE='\\NAV-C00DB04P-B\Log_Backup\BackupEncryptionA.pvk');

BACKUP CERTIFICATE BackupEncryption TO FILE = '\\NAV-C00DB04P-B\Log_Backup\BackupEncryption.cer' 
  WITH PRIVATE KEY(ENCRYPTION BY PASSWORD='t2OU4M01&iO0748q*m$4qpZi184WV487', FILE='\\NAV-C00DB04P-B\Log_Backup\BackupEncryption.pvk');

  
  /*
  CREATE CERTIFICATE Backup_Encryption   
   ENCRYPTION BY PASSWORD = 't2OU4M01&iO0748q*m$4qpZi184WV487'  
   WITH SUBJECT = 'Backup certificate',   
   EXPIRY_DATE = '20201031';  
GO  


ALTER CERTIFICATE Backup_Encryption
    WITH PRIVATE KEY (DECRYPTION BY PASSWORD = 't2OU4M01&iO0748q*m$4qpZi184WV487');


BACKUP CERTIFICATE Backup_Encryption TO FILE = '\\NAV-C00DB04P-A\Backups\BackupEncryptionA.cer' 
  WITH PRIVATE KEY(ENCRYPTION BY PASSWORD='t2OU4M01&iO0748q*m$4qpZi184WV487', FILE='\\NAV-C00DB04P-A\Backups\BackupEncryptionA.pvk');

  
  
  CREATE CERTIFICATE Backup_Encryption   
   ENCRYPTION BY PASSWORD = 't2OU4M01&iO0748q*m$4qpZi184WV487'  
   WITH SUBJECT = 'Backup certificate',   
   EXPIRY_DATE = '20201031';  
GO  



ALTER CERTIFICATE Backup_Encryption
    WITH PRIVATE KEY (DECRYPTION BY PASSWORD = 't2OU4M01&iO0748q*m$4qpZi184WV487');


BACKUP CERTIFICATE Backup_Encryption TO FILE = '\\NAV-C00DB04P-A\Backups\BackupEncryptionB.cer' 
  WITH PRIVATE KEY(ENCRYPTION BY PASSWORD='t2OU4M01&iO0748q*m$4qpZi184WV487', FILE='\\NAV-C00DB04P-A\Backups\BackupEncryptionB.pvk');

*/
  

-- Step One:  Verify each secondary replica instance has a Database Master Key (DMK) in the master database – if not, create one.


USE MASTER GO SELECT * FROM sys.symmetric_keys


CREATE MASTER KEY ENCRYPTION BY PASSWORD = 'Mhl(9Iy^4jn8hYx#e9%ThXWo*9k6o@';

------------------------------------------------------------------------------------------------	

-- Step Two:  On the primary replica instance, create a backup of the certificate used to TDE encrypt the database

USE master 
GO 
SELECT db_name(database_id) [TDE Encrypted DB Name], c.name as CertName, encryptor_thumbprint 
    FROM sys.dm_database_encryption_keys dek 
    INNER JOIN sys.certificates c on dek.encryptor_thumbprint = c.thumbprint


SELECT 'USE MASTER; BACKUP CERTIFICATE ['+c.name+'] TO FILE = ''\\NAV-C00DB04P-B\Log_Backup\'+db_name(database_id)+replace(replace(replace(CONVERT(VARCHAR(19), GETDATE(), 120),'-','_'),' ','_'),':','_')+'_'+c.name+''' WITH 
PRIVATE KEY (FILE = ''\\NAV-C00DB04P-B\Log_Backup\'+db_name(database_id)+replace(replace(replace(CONVERT(VARCHAR(19), GETDATE(), 120),'-','_'),' ','_'),':','_')+'_Private_file'', ENCRYPTION BY PASSWORD = ''t2OU4M01&iO0748q*m$4qpZi184WV487'');'
    FROM sys.dm_database_encryption_keys dek 
    INNER JOIN sys.certificates c on dek.encryptor_thumbprint = c.thumbprint

'

	USE MASTER; BACKUP CERTIFICATE [NppCertificate] TO FILE = '\\NAV-C00DB04P-B\Log_Backup\NBNVolvo_Prod2018_06_27_09_45_46_NppCertificate' WITH 
PRIVATE KEY (FILE = '\\NAV-C00DB04P-B\Log_Backup\NBNVolvo_Prod2018_06_27_09_45_46_Private_file', ENCRYPTION BY PASSWORD = 't2OU4M01&iO0748q*m$4qpZi184WV487');
USE MASTER; BACKUP CERTIFICATE [NppCertificate] TO FILE = '\\NAV-C00DB04P-B\Log_Backup\NBNVolvo_Prod2018_06_27_09_45_46_NppCertificate' WITH 
PRIVATE KEY (FILE = '\\NAV-C00DB04P-B\Log_Backup\NBNVolvo_Prod2018_06_27_09_45_46_Private_file', ENCRYPTION BY PASSWORD = 't2OU4M01&iO0748q*m$4qpZi184WV487');
	
------------------------------------------------------------------------------------------------	
	
--	Step Three:  On each secondary replica instance, create the TDE Certificate from the certificate backed up on the primary

 CREATE CERTIFICATE [NppCertificate] FROM FILE = '\\NAV-C00DB04P-B\Log_Backup\NBNVolvo_Prod2018_06_27_09_45_46_NppCertificate' WITH PRIVATE KEY ( FILE = '\\NAV-C00DB04P-B\Log_Backup\NBNVolvo_Prod2018_06_27_09_45_46_Private_file', DECRYPTION BY PASSWORD = 't2OU4M01&iO0748q*m$4qpZi184WV487');
CREATE CERTIFICATE [NppCertificate] FROM FILE = '\\NAV-C00DB04P-B\Log_Backup\NBNVolvo_Prod2018_06_27_09_45_46_NppCertificate' WITH PRIVATE KEY ( FILE = '\\NAV-C00DB04P-B\Log_Backup\NBNVolvo_Prod2018_06_27_09_45_46_Private_file', DECRYPTION BY PASSWORD = 't2OU4M01&iO0748q*m$4qpZi184WV487');


USE master 
GO 
SELECT db_name(database_id) [TDE Encrypted DB Name], c.name as CertName, encryptor_thumbprint 
    FROM sys.dm_database_encryption_keys dek 
    INNER JOIN sys.certificates c on dek.encryptor_thumbprint = c.thumbprint

	
------------------------------------------------------------------------------------------------	

--  Step Four:  On the primary replica instance (SQL1), create a full database backup of the TDE encrypted database	
	

 ALTER AVAILABILITY GROUP [nav-c00db04p] REMOVE DATABASE NBNVolvo_Prod
GO

USE master 
 BACKUP DATABASE NBNVolvo_Prod TO DISK = '\\NAV-C00DB04P-B\Log_Backup\NBNVolvo_Prod.bak' ;

------------------------------------------------------------------------------------------------
 
--  Step Five:  On the primary replica instance (SQL1), create a transaction log backup of the TDE encrypted database 

USE master 
 BACKUP LOG NBNVolvo_Prod TO DISK = '\\NAV-C00DB04P-B\Log_Backup\NBNVolvo_Prod.trn' ;

 
------------------------------------------------------------------------------------------------

-- Step Six:  On the primary replica instance (SQL1), add the TDE encrypted database to the Availability Group

USE master 
 ALTER AVAILABILITY GROUP [nav-c00db04p] ADD DATABASE NBNVolvo_Prod 

------------------------------------------------------------------------------------------------

-- Step Seven:  On each secondary replica instance, restore the full backup (from Step Four) with no recovery
 
ALTER DATABASE [NBNVolvo_Prod] SET HADR OFF;  
GO  

USE master 
 RESTORE DATABASE [NBNVolvo_Prod] from DISK = '\\NAV-C00DB04P-B\Log_Backup\NBNVolvo_Prod.bak' WITH replace,norecovery;

------------------------------------------------------------------------------------------------
 
-- Step Eight:  On each secondary replica instance, restore the transaction log backup (from Step Five) with no recovery
 
USE master 
 RESTORE LOG [NBNVolvo_Prod] from DISK = '\\NAV-C00DB04P-B\Log_Backup\NBNVolvo_Prod.trn' WITH noRECOVERY;

------------------------------------------------------------------------------------------------

-- Step Nine:  On each secondary replica instance, join the database to the availability group 

USE master 
 ALTER DATABASE [NBNVolvo_Prod] SET HADR AVAILABILITY GROUP = [nav-c00db04p];
 
 ------------------------------------------------------------------------------------------------
 
 
 
 