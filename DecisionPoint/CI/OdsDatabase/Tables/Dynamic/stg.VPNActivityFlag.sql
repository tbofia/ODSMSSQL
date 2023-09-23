IF OBJECT_ID('stg.VPNActivityFlag', 'U') IS NOT NULL
DROP TABLE stg.VPNActivityFlag
BEGIN
	CREATE TABLE stg.VPNActivityFlag(
		          Activity_Flag VARCHAR(1)  NULL ,
				  AF_Description VARCHAR(50) NULL ,
				  AF_ShortDesc VARCHAR(50) NULL ,
				  Data_Source VARCHAR(5) NULL ,
				  Default_Billable BIT NULL ,
				  Credit BIT NULL,
		          DmlOperation CHAR(1) NOT NULL 
	)
END
GO




