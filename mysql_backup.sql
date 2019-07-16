

----		mysqldump -u root -p dbname > D:\location\dbname.sql


/*

C:\Program Files\MySQL\MySQL Server 5.5\bin>mysqldump -u root -p test > D:\MSSQL\Backup\test.sql
Enter password: ****

C:\Program Files\MySQL\MySQL Server 5.5\bin>mysqldump -u root -p ccms_nmb > D:\MSSQL\Backup\ccms_nmb.sql
Enter password: ****

*/


schtasks /create /sc daily /st 04:30 /ru SYSTEM /tn MySQL_backup /tr "C:\Program Files\MySQL\MySQL Server 5.1\bin\mysqldump.exe" -B <DB_NAME> -u <USER_NAME> -p<PASSWORD> -r C:\MySQL_backup\<DB_NAME>_%date:~0,2%.sql

eg:

-- run as admin to create task
schtasks /create /sc daily /st 04:44  /ru SYSTEM /tn MySQL_backup /tr "'C:\Program Files\MySQL\MySQL Server 5.5\bin>mysqldump.exe' -u root -p root -b ccms_nmb D:\MSSQL\Backup\ccms_nmb_%date:/=%_%time:~0,2%-%time:~3,2%-%time:~6,2%.sql"

schtasks /create /sc daily /st 04:20  /ru SYSTEM /tn MySQL_backup /tr "'C:\Program Files\MySQL\MySQL Server 5.5\bin>mysqldump.exe' -u root -p root -b ccms_nmb D:\MSSQL\Backup\ccms_nmb_%date:/=%_%time:~0,2%-%time:~3,2%-%time:~6,2%.sql"