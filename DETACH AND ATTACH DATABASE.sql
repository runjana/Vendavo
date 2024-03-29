-------------------*****DETACH AND ATTACH DATABASE IN SAFE MODE*****--------------------
--WE NEED TO USE MASTER DATABASE FOR THIS PROCESS OF DETACH AND ATTACH DATABASE.
USE MASTER;
--------------******DETACH PROCESS
--1STLY WE SHOULD TAKE THE DATABASE OFFLIE.DURING OFFLINE THERE WONT BE ANY OPERATION IN THE DATABASE.
--SYNTAX:
ALTER DATABASE DATABASE_NAME SET OFFLINE WITH ROLLBACK IMMEDIATE;

--EG:
ALTER DATABASE LOAD_EXCEL_FILE SET OFFLINE WITH ROLLBACK IMMEDIATE;


--SECOND STEP WILL BE SETTING THE DATABASE FOR THE SINGLE USER MODE
--SYNTAX:
ALTER DATABASE DATABASE_NAME SET SINGLE_USER WITH ROLLBACK IMMEDIATE;

--EG:
ALTER DATABASE LOAD_EXCEL_FILE SET SINGLE_USER WITH ROLLBACK IMMEDIATE;



--IF DEADLOCK OCCURS WHILE CHAINGING THE USER_MODE

/*
Msg 1205, Level 13, State 68, Line 5 Transaction (Process ID 58) was deadlocked on lock resources with another process and has been chosen as the deadlock victim. Rerun the transaction. Msg 5069, Level 16, State 1, Line 5 ALTER DATABASE statement failed.
*/

SET DEADLOCK_PRIORITY HIGH;
ALTER DATABASE FONEBANK SET MULTI_USER



--THIRD STEP WILL BE THE PROCESS OF DETACHING THE DATABASE FOR WHICH WE NEED TO EXECUTE THE sp_detach_db PROCEDURE
--WITH PARAMETER @dbname AND THE LOCATION OF THE DATABASE NAME.
--SYNTAX:
EXEC master.dbo.sp_detach_db @dbname = 'DATABASE_NAME';

--EG:
EXEC master.dbo.sp_detach_db @dbname = 'LOAD_EXCEL_FILE';



--------------******ATTACH PROCESS
--FIRSTLY WE SHOULD ATTACH THE .mdf(DATA FILE) AND .ldf(LOG FILE) FILE OF DATABASE.
--SYNTAX:
CREATE DATABASE DATABASE_NAME ON 
(FILENAME ='DATABASE_NAME.mdf'),
(FILENAME = 'DATABASE_NAME_log.LDF')
FOR ATTACH;

--EG:
CREATE DATABASE LOAD_EXCEL_FILE ON 
(FILENAME = 'D:\DATA\LOAD_EXCEL_FILE.mdf'),
(FILENAME = 'D:\DATA\LOAD_EXCEL_FILE_log.LDF')
FOR ATTACH;

--THE DATABASE WILL BE ONLINE AUTOMATICALLY IF NOT
--SECOND STEP TAKE THE DATABASE ONLINE 
ALTER DATABASE DATABASE_NAME SET ONLINE;

--EG:
ALTER DATABASE LOAD_EXCEL_FILE SET ONLINE;

-------------------------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------------------

-------------------*****DETACH AND ATTACH DATABASE IN SAFE MODE*****--------------------


USE MASTER;

ALTER DATABASE TXNALERT SET OFFLINE WITH ROLLBACK IMMEDIATE;

ALTER DATABASE TXNALERT SET SINGLE_USER WITH ROLLBACK IMMEDIATE;


--SET DEADLOCK_PRIORITY HIGH;
--ALTER DATABASE FONEBANK SET MULTI_USER


EXEC master.dbo.sp_detAch_db @dbname = 'TXNALERT';


CREATE DATABASE TXNALERT ON 
(FILENAME ='C:\Program Files\Microsoft SQL Server\MSSQL11.MSSQLSERVER\MSSQL\DATA\TXNALERT.mdf')
FOR ATTACH;

ALTER DATABASE TXNALERT SET ONLINE;

