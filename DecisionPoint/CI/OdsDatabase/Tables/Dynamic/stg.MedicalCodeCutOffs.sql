IF OBJECT_ID('stg.MedicalCodeCutOffs', 'U') IS NOT NULL
DROP TABLE stg.MedicalCodeCutOffs
BEGIN
	CREATE TABLE stg.MedicalCodeCutOffs (
		CodeTypeID INT NULL
       ,CodeType VARCHAR(50) NULL
       ,Code VARCHAR(50) NULL
       ,FormType VARCHAR(10) NULL
       ,MaxChargedPerUnit FLOAT NULL
       ,MaxUnitsPerEncounter FLOAT NULL
	   ,DmlOperation CHAR(1) NOT NULL
		)
END
GO
