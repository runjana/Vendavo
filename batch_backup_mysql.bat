~~~ BEGIN FILE ~~~

@ECHO OFF
SET VERSIONMAJOR=10
SET VERSIONMINOR=6

FOR /f "tokens=1-4 delims=/ " %%a IN ('date/t') DO (
SET dw=%%a
SET mm=%%b
SET dd=%%c
SET yy=%%d
)

REM *** VERIFY AND UPDATE THESE SETTINGS BEFORE INITIAL RUN ***
REM *** mysqldir must point to the \bin directory! ***
SET bkupdir=C:\MySQL-Backups
SET mysqldir=C:\wamp\bin\mysql\mysql5.0.51b\bin
SET dbhost=localhost
SET dbuser=
SET dbpass=
REM *** END USER CONFIGURABLE SETTINGS ***

IF /i "%1" == "--INSTALL" GOTO INSTALLER
IF /i "%1" == "--CREATEDIRS" GOTO CREATEDIRS
IF /i "%1" == "--ADDSCHEDULEDTASK" GOTO TASKSCHED
IF ""%1"" == """" GOTO ALLDB
IF /i "%1" == "--ALL" GOTO ALLDB
IF /i "%1:~0,2%" == "--" GOTO PARAMERROR

SET ALLDBS=0
SET dbnames=%1
SET dbnamesf=%1
SHIFT
:setArgs
IF ""%1""=="""" GOTO BKUP
SET dbnames=%dbnames% %1
SET dbnamesf=%dbnamesf%_%1
SHIFT
GOTO setArgs

:ALLDB
SET ALLDBS=1
SET dbnames=ALL DATABASES
SET dbnamesf=ALL_DATABASES

:BKUP
@ECHO MySQLdump script for Windows v%VERSIONMAJOR%.%VERSIONMINOR% > %bkupdir%\dbBkup_%dbnamesf%_%yy%%mm%%dd%.log
@ECHO. >> %bkupdir%\dbBkup_%dbnamesf%_%yy%%mm%%dd%.log
@ECHO MySQLdump script for Windows v%VERSIONMAJOR%.%VERSIONMINOR%
@ECHO.

IF NOT EXIST %bkupdir%\INSTALLED.OK (
@ECHO DIRECTORY STRUCTURE NOT IN PLACE. >> %bkupdir%\dbBkup_%dbnamesf%_%yy%%mm%%dd%.log
@ECHO PLEASE RUN %0 --INSTALL OR %0 --CREATEDIRS >> %bkupdir%\dbBkup_%dbnamesf%_%yy%%mm%%dd%.log
@ECHO FAILED TO BACKUP DATABASES. >> %bkupdir%\dbBkup_%dbnamesf%_%yy%%mm%%dd%.log
@ECHO DIRECTORY STRUCTURE NOT IN PLACE.
@ECHO PLEASE RUN %0 --INSTALL OR %0 --CREATEDIRS
@ECHO FAILED TO BACKUP DATABASES.
GOTO BOTTOM
)

@ECHO Beginning backup of %dbnames%... >> %bkupdir%\dbBkup_%dbnamesf%_%yy%%mm%%dd%.log
@ECHO Beginning backup of %dbnames%...

IF %ALLDBS% == 1 (
SET dumpparams=--host=%dbhost% -u %dbuser% -p%dbpass% -A -f -x -q --create-options --flush-privileges -r %bkupdir%\dbBkup_%dbnamesf%_%yy%%mm%%dd%.sql
) ELSE (
SET dumpparams=--host=%dbhost% -u %dbuser% -p%dbpass% -f -x -q --create-options --flush-privileges -r %bkupdir%\dbBkup_%dbnamesf%_%yy%%mm%%dd%.sql --databases %dbnames%
)

%mysqldir%\mysqldump %dumpparams% >> %bkupdir%\dbBkup_%dbnamesf%_%yy%%mm%%dd%.log

@ECHO Done! New File: dbBkup_%dbnamesf%_%yy%%mm%%dd%.sql >> %bkupdir%\dbBkup_%dbnamesf%_%yy%%mm%%dd%.log
@ECHO Done! New File: dbBkup_%dbnamesf%_%yy%%mm%%dd%.sql

COPY /Y %bkupdir%\dbBkup_%dbnamesf%_%yy%%mm%%dd%.sql /A %bkupdir%\Daily\dbBkup_%dbnamesf%_%dw%.sql /A > NUL
@ECHO Created Daily Backup: Daily\dbBkup_%dbnamesf%_%dw%.sql >> %bkupdir%\dbBkup_%dbnamesf%_%yy%%mm%%dd%.log
@ECHO Created Daily Backup: Daily\dbBkup_%dbnamesf%_%dw%.sql

REM Check to see if it's time for the Weekend backup 
IF /i "%dw%" NEQ "Sat" GOTO SKIPWKBK
IF EXIST %bkupdir%\Weekly\safety_%dbnamesf%_%yy%%mm%%dd%.txt GOTO WKCUR
IF NOT EXIST %bkupdir%\Weekly\dbBkup_%dbnamesf%_Current.sql GOTO WKCUR
IF NOT EXIST %bkupdir%\Weekly\dbBkup_%dbnamesf%_Previous.sql GOTO WKPRE
IF NOT EXIST %bkupdir%\Weekly\dbBkup_%dbnamesf%_Previous_2.sql GOTO WKPR2
MOVE /Y %bkupdir%\Weekly\dbBkup_%dbnamesf%_Previous_2.sql %bkupdir%\Weekly\dbBkup_%dbnamesf%_Previous_3.sql > NUL
:WKPR2
MOVE /Y %bkupdir%\Weekly\dbBkup_%dbnamesf%_Previous.sql %bkupdir%\Weekly\dbBkup_%dbnamesf%_Previous_2.sql > NUL
:WKPRE
MOVE /Y %bkupdir%\Weekly\dbBkup_%dbnamesf%_Current.sql %bkupdir%\Weekly\dbBkup_%dbnamesf%_Previous.sql > NUL
:WKCUR
COPY /Y %bkupdir%\dbBkup_%dbnamesf%_%yy%%mm%%dd%.sql /A %bkupdir%\Weekly\dbBkup_%dbnamesf%_Current.sql /A > NUL
@ECHO. > %bkupdir%\Weekly\safety_%dbnamesf%_%yy%%mm%%dd%.txt
@ECHO Created Weekly Backup: Weekly\dbBkup_%dbnamesf%_Current.sql >> %bkupdir%\dbBkup_%dbnamesf%_%yy%%mm%%dd%.log
@ECHO Created Weekly Backup: Weekly\dbBkup_%dbnamesf%_Current.sql

:SKIPWKBK
REM if (day >= 28) write EoM backup
IF %dd% GEQ 28 (
COPY /Y %bkupdir%\dbBkup_%dbnamesf%_%yy%%mm%%dd%.sql /A %bkupdir%\Monthly\dbBkup_%dbnamesf%_%mm%.sql /A > NUL
@ECHO Created End of Month Backup: Monthly\dbBkup_%dbnamesf%_%mm%.sql >> %bkupdir%\dbBkup_%dbnamesf%_%yy%%mm%%dd%.log
@ECHO Created End of Month Backup: Monthly\dbBkup_%dbnamesf%_%mm%.sql
)

DEL /q /f %bkupdir%\dbBkup_%dbnamesf%_%yy%%mm%%dd%.sql

@ECHO Backup stored in rotating archives. >> %bkupdir%\dbBkup_%dbnamesf%_%yy%%mm%%dd%.log
@ECHO. >> %bkupdir%\dbBkup_%dbnamesf%_%yy%%mm%%dd%.log
@ECHO End MySQLdump Script >> %bkupdir%\dbBkup_%dbnamesf%_%yy%%mm%%dd%.log
@ECHO Backup stored in rotating archives.
@ECHO.
@ECHO End MySQLdump Script
GOTO BOTTOM

:INSTALLER
@ECHO VERIFY: Path to mysqldump: %mysqldir%
@ECHO VERIFY: Path to backups: %bkupdir%
@ECHO VERIFY: MySQL User: %dbuser%
@ECHO VERIFY: MySQL Pass: %dbpass%
@ECHO VERIFY: MySQL Host: %dbhost%
IF NOT EXIST %bkupdir%\INSTALLED.OK (
@ECHO ALERT: Backup directory does not exist. Create base directory and subdirectories?
SET /p domkdir=[Y/N]:
IF /i "%domkdir%" == "N" (
@ECHO ALERT: CANNOT CONTINUE WITHOUT DIRECTORIES IN PLACE.
GOTO BOTTOM
)
)
:CREATEDIRS
IF NOT EXIST %bkupdir%\INSTALLED.OK (
MD "%bkupdir%" > NUL
MD "%bkupdir%\Daily" > NUL
MD "%bkupdir%\Weekly" > NUL
MD "%bkupdir%\Monthly" > NUL
@ECHO INSTALLED CORRECTLY > %bkupdir%\INSTALLED.OK
)
GOTO BOTTOM

:TASKSCHED
@ECHO Preparing add Scheduled Task...
:STUPIDUSER1
SET /p taskuser=Domain\User to run task:
IF /i ""%taskuser%"" == """" GOTO STUPIDUSER1
:STUPIDUSER2
SET /p taskpwd1=Password:
SET /p taskpwd2=Confirm Password:
IF %taskpwd1% NEQ %taskpwd2% GOTO STUPIDUSER2
:STUPIDUSER3
SET /p taskname=Task name:
IF /i ""%taskname%"" == """" GOTO STUPIDUSER3
SET /p taskparam=Parameters to pass to batch file:
SCHTASKS /Create /SC DAILY /ST 04:00:00 /TN "%taskname%" /TR "%~f0 %taskparam%" /RU "%taskuser%" /RP %taskpwd1%
GOTO BOTTOM

:PARAMERROR
@ECHO ERROR: Unknown Parameter Passed.
@ECHO Current supported parameters:
@ECHO --ALL - Backup all databases, same as passing nothing to batch file
@ECHO --ADDSCHEDULEDTASK - Adds a scheduled task for this process
@ECHO --CREATEDIRS - Creates Directory Structure
@ECHO --INSTALL - Creates directory structure and outputs configuration settings that need verification

:BOTTOM
