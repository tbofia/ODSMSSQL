IF OBJECT_ID('stg.UB_APC_DICT', 'U') IS NOT NULL
DROP TABLE stg.UB_APC_DICT
BEGIN
	CREATE TABLE stg.UB_APC_DICT (
		StartDate DATETIME NULL
		,EndDate DATETIME NULL
		,APC VARCHAR(5) NULL
		,Description VARCHAR(255) NULL
		,DmlOperation CHAR(1) NOT NULL
		)
END
GO   
