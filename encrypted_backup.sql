expiry_date before 2018-04-19 08:16:28.000


CREATE CERTIFICATE BackupEncryption  
   WITH SUBJECT = 'Backup Encryption Certificate';  
GO  


https://www.dropbox.com/sh/xs2rfzajjuyyoz5/AABRSl8bSsZQk1NQYmrsYD2ra?dl=0



BACKUP DATABASE TESTDB03  
TO DISK = N'\\NAV-C00DB04P-B\Users\ranjana.ghimire\Dropbox (Navetti)\Navetti\Navetti External-Communication with client\Run Communication\Volvo Backup\MyTestDB.bak'  
WITH  
  COMPRESSION,  
  ENCRYPTION   
   (  
   ALGORITHM = AES_256,  
   SERVER CERTIFICATE = BackupEncryption  
   ),  
  STATS = 10  
GO  



