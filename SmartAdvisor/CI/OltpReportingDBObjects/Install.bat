@ECHO OFF

REM make sure they sent in the first three parameters
if "x%1"=="x" goto SHOW_INSTRUCTIONS
if "x%2"=="x" goto SHOW_INSTRUCTIONS
if "x%3"=="x" goto NO_BLANK_PASSWORD

REM determine if they are using NT authentication or not
if "%2"=="nt" goto USING_NT_AUTH
if "%2"=="NT" goto USING_NT_AUTH

goto USING_SQL_AUTH

:USING_NT_AUTH
set unameparam_=/E
set pwdparam_=
goto CHECK_DB

:USING_SQL_AUTH
set unameparam_=/U%2
set pwdparam_=/P%3

REM determine the database they are writing to
:CHECK_DB
if "%4"=="" goto USEMMEDICAL
set database_=%4
set outfile_="%TEMP%"\mmedisql_%4.log
goto SKIPMMEDICAL
:USEMMEDICAL
set database_=mmedical
set outfile_="%TEMP%"\mmedisql_DM.log
:SKIPMMEDICAL

REM set directory locations for working schema/data
set workingpath_=_working\
REM set himworkingpathfh_=_working\Fair Health\
REM set himworkingpathmain_=_working\Main\

ECHO Installation started on %1:%database_% > %outfile_%

REM let's verify the user's login info before proceeding
ECHO Checking login credentials...
ECHO Checking login credentials... >> %outfile_%
SET verified_= 0
FOR /F "tokens=1" %%A IN ('sqlcmd -S %1 %unameparam_% %pwdparam_% -Q "SET NOCOUNT ON; SELECT 1" ^| FIND "1"' ) DO SET verified_=%%A

if NOT %verified_% == 1 (
	ECHO.
	ECHO I couldn't successfully log you into the SQL Server.  Please verify your server/login/password information and try again.
	ECHO I couldn't successfully log you into the SQL Server.  Please verify your server/login/password information and try again. >> %outfile_%
	GOTO END
)

set dbcheckcount_=0

:DBEXISTCHECK

ECHO Checking for existence of %database_%...
ECHO Checking for existence of %database_%... >> %outfile_%
SET dbExists_= 0
FOR /F "tokens=1" %%A IN ('sqlcmd -S %1 %unameparam_% %pwdparam_% -Q "SET NOCOUNT ON; SELECT COUNT(*) FROM sys.databases WHERE name = '%database_%'" ^| FIND "1"' ) DO SET dbExists_=%%A

set /A  dbcheckcount_+=1

if %dbExists_% == 1 (
	goto DATABASE_EXISTS
)

ECHO.
ECHO %database_% does not exist.  Would you like me to create it?  [y/n]
ECHO %database_% does not exist.  Would you like me to create it?  [y/n] >> %outfile_%
SET /P response_=

if /I NOT "%response_%"=="y" (
	ECHO User declined to proceed. Exiting.
	ECHO User declined to proceed. Exiting. >> %outfile_%
	GOTO END
)

ECHO Creating %database_%...
ECHO Creating %database_%... >> %outfile_%
REM This uses default db options (based on model db); in the future, if these aren't on
REM a SAN or something similar, we should ensure that data and log are on different disks.
sqlcmd -S %1 %unameparam_% %pwdparam_% -d master -Q "CREATE DATABASE %database_%"

if %dbcheckcount_% LEQ 1 (
	goto DBEXISTCHECK
)

goto DATABASE_NOT_EXISTS

:DATABASE_EXISTS

FOR /F "tokens=1" %%A IN ('sqlcmd -S %1 -h -1 %unameparam_% %pwdparam_% -d %database_% -Q "SET NOCOUNT ON; SELECT CASE WHEN SiteInfo.ShareFSDb IS NULL OR LTRIM(RTRIM(SiteInfo.ShareFSDb)) = '' THEN DB_NAME() ELSE SiteInfo.ShareFSDb END AS HimDatatabaseName FROM dbo.SiteInfo;"') DO (

SET himdatabasename_=%%A
)


REM Stored Listener Name into variable
set servername_=%1

ECHO Creating CoreDatabaseObjects...
ECHO Creating CoreDatabaseObjects... >> %outfile_%

CD CoreDatabaseObjects

ECHO Creating HimDatabase Schema
ECHO Creating HimDatabase Schema >> %outfile_%
sqlcmd -S %1 %unameparam_% %pwdparam_% -d %himdatabasename_% -i schema.sql >> %outfile_%

ECHO Creating/Updating HimDatabase dynamic tables
ECHO Creating/Updating HimDatabase dynamic tables >> %outfile_%
sqlcmd -S %1 %unameparam_% %pwdparam_% -d %himdatabasename_% -i Tables\tbldyn.sql >> %outfile_%

CD ..

ECHO Creating MedicalUserRole
ECHO Creating MedicalUserRole >> %outfile_%
sqlcmd -S %1 %unameparam_% %pwdparam_% -d %database_% -i Tables\UserRole.sql >> %outfile_%

ECHO Creating Schema
ECHO Creating Schema >> %outfile_%
sqlcmd -S %1 %unameparam_% %pwdparam_% -d %database_% -i schema.sql >> %outfile_%

ECHO Executing Dynamic FK Data Cleanup Script...
ECHO Executing Dynamic FK Data Cleanup Script... >> %outfile_%
sqlcmd -S %1 %unameparam_% %pwdparam_% -d %database_% -i Update\fkdatacleanup.sql >> %outfile_%

ECHO Dropping all foreign keys
ECHO Dropping all foreign keys >> %outfile_%
sqlcmd -S %1 %unameparam_% %pwdparam_% -d %database_% -i ForeignKeys\fkdropall.sql >> %outfile_%

ECHO Dropping static dev tables
ECHO Dropping static dev tables >> %outfile_%
sqlcmd -S %1 %unameparam_% %pwdparam_% -d %database_% -i Tables\tbldrop.sql >> %outfile_%

ECHO Creating static dev tables
ECHO Creating static dev tables >> %outfile_%
sqlcmd -S %1 %unameparam_% %pwdparam_% -d %database_% -i Tables\tblstat.sql >> %outfile_%

ECHO Inserting Dev Data
ECHO Inserting Dev Data >> %outfile_%
call data\data.bat data\ %1 %2 %3 %database_% %5

ECHO Creating static dev indexes...
ECHO Creating static dev indexes... >> %outfile_%
sqlcmd -S %1 %unameparam_% %pwdparam_% -d %database_% -i Indexes\idxstat.sql >> %outfile_%

if exist "%workingpath_%" (

ECHO Performing dev only schema updates
ECHO Performing dev only schema updates >> %outfile_%
sqlcmd -S %1 %unameparam_% %pwdparam_% -d %database_% -i "%workingpath_%Update\DevOnlySchemaUpdates.sql" >> %outfile_%

)

ECHO Creating User Defined Types...
ECHO Creating User Defined Types... >> %outfile_%
sqlcmd -S %1 %unameparam_% %pwdparam_% -d %database_% -i Types\types.sql >> %outfile_%

ECHO Creating/Updating dynamic tables
ECHO Creating/Updating dynamic tables >> %outfile_%
sqlcmd -S %1 %unameparam_% %pwdparam_% -d %database_% -i Tables\tbldyn.sql >> %outfile_%

ECHO Creating/Updating dynamic indexes...
ECHO Creating/Updating dynamic indexes... >> %outfile_%
sqlcmd -S %1 %unameparam_% %pwdparam_% -d %database_% -i Indexes\idxdyn.sql >> %outfile_%

ECHO Creating Functions...
ECHO Creating Functions... >> %outfile_%
sqlcmd -S %1 %unameparam_% %pwdparam_% -d %database_% -i Functions\fndyn.sql >> %outfile_%

ECHO Creating static stored procedures...
ECHO Creating static stored procedures... >> %outfile_%
sqlcmd -S %1 %unameparam_% %pwdparam_% -d %database_% -i StoredProcedures\spstat.sql >> %outfile_%

ECHO Creating dynamic stored procedures...
ECHO Creating dynamic stored procedures... >> %outfile_%
sqlcmd -S %1 %unameparam_% %pwdparam_% -d %database_% -i StoredProcedures\spdyn.sql >> %outfile_%

ECHO Creating static views...
ECHO Creating static views... >> %outfile_%
sqlcmd -S %1 %unameparam_% %pwdparam_% -d %database_% -i Views\vwstat.sql >> %outfile_%

ECHO Creating dynamic views...
ECHO Creating dynamic views... >> %outfile_%
sqlcmd -S %1 %unameparam_% %pwdparam_% -d %database_% -i Views\vwdyn.sql >> %outfile_%

ECHO Creating Triggers...
ECHO Creating Triggers... >> %outfile_%
sqlcmd -S %1 %unameparam_% %pwdparam_% -d %database_% -i Triggers\triggers.sql >> %outfile_%

ECHO Applying DML/DDL with dependencies across multiple db objects...
ECHO Applying DML/DDL with dependencies across multiple db objects... >> %outfile_%
sqlcmd -S %1 %unameparam_% %pwdparam_% -d %database_% -i Update\depends.sql >> %outfile_%

ECHO Enable change tracking...
ECHO Enable change tracking... >> %outfile_%
sqlcmd -S %1 %unameparam_% %pwdparam_% -d %database_% -i Update\PrepareOltpScripts\EnableChangeTracking.sql >> %outfile_%

ECHO Enable xp cmd shell...
ECHO Enable xp cmd shell... >> %outfile_%
sqlcmd -S %1 %unameparam_% %pwdparam_% -d %database_% -i Update\PrepareOltpScripts\EnableXPCmdShell.sql >> %outfile_%

ECHO Creating Jobs...
ECHO Creating Jobs...>> %outfile_%
For /R Jobs\ %%G IN (*.sql) do sqlcmd -S %1 %unameparam_% %pwdparam_% -d %database_% -i "%%G" >> %outfile_%

ECHO Cleanup obsolete objects...
ECHO Cleanup obsolete objects... >> %outfile_%
sqlcmd -S %1 %unameparam_% %pwdparam_% -d %database_% -i Update\db_objects_cleanup.sql >> %outfile_% 

ECHO Creating static dev foreign keys
ECHO Creating static dev foreign keys >> %outfile_%
sqlcmd -S %1 %unameparam_% %pwdparam_% -d %database_% -i ForeignKeys\fkstat.sql >> %outfile_%

ECHO Creating dynamic foreign keys
ECHO Creating dynamic foreign keys >> %outfile_%
sqlcmd -S %1 %unameparam_% %pwdparam_% -d %database_% -i ForeignKeys\fkdyn.sql >> %outfile_%

ECHO Creating Version
ECHO Creating Version >> %outfile_%
sqlcmd -S %1 %unameparam_% %pwdparam_% -d %database_% -i Tables\AppVersion.sql >> %outfile_%

ECHO Installation finished.  Please check %TEMP%\data_%4.log and %outfile_% for any error messages
ECHO Installation finished. >> %outfile_%
goto END

:SHOW_INSTRUCTIONS
echo Send in the name of the server, the user name, and the password
echo as arguments.  You can optionally send in the database name as the fourth argument.
echo ...
echo Example:  install MedServer sa admin mmedical
echo ...
goto END

:NO_BLANK_PASSWORD
echo You must specify a password.  Blank passwords are not accepted
goto END

:DATABASE_NOT_EXISTS
ECHO ERROR: %database_% db creation failed!
ECHO ERROR: %database_% db creation failed! >> %outfile_%

:END
