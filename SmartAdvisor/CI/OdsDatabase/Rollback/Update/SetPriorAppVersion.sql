SET NOCOUNT ON;
BEGIN 
BEGIN TRANSACTION 
BEGIN TRY 


 DELETE adm.AppVersion
 WHERE AppVersion = '2.2.0.0'

COMMIT TRANSACTION 
END TRY
BEGIN CATCH 
PRINT ' Something went wrong deleteing the MAX AppVersion in the rpt schema '
ROLLBACK TRANSACTION 
END CATCH
END