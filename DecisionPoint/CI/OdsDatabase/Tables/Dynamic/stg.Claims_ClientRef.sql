IF OBJECT_ID('stg.Claims_ClientRef', 'U') IS NOT NULL
DROP TABLE stg.Claims_ClientRef
BEGIN
	CREATE TABLE stg.Claims_ClientRef (
		ClaimIdNo INT NULL,
		ClientRefId VARCHAR(50) NULL,
		DmlOperation CHAR(1) NOT NULL
		)
END
GO
