IF OBJECT_ID('stg.SENTRY_ACTION_CATEGORY', 'U') IS NOT NULL 
	DROP TABLE stg.SENTRY_ACTION_CATEGORY  
BEGIN
	CREATE TABLE stg.SENTRY_ACTION_CATEGORY
		(
		  ActionCategoryIDNo INT NULL,
		  Description VARCHAR (60) NULL,
		  DmlOperation CHAR(1) NOT NULL 
		 )
END 
GO

