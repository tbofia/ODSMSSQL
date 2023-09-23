IF OBJECT_ID('stg.prf_COMPANY', 'U') IS NOT NULL
DROP TABLE stg.prf_COMPANY
BEGIN
	CREATE TABLE stg.prf_COMPANY (
		CompanyId INT NULL
		,CompanyName VARCHAR(50) NULL
		,LastChangedOn DATETIME NULL
		,DmlOperation CHAR(1) NOT NULL
		)
END
GO
