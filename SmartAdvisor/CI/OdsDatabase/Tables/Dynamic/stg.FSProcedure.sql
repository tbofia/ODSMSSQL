IF OBJECT_ID('stg.FSProcedure', 'U') IS NOT NULL 
	DROP TABLE stg.FSProcedure  
BEGIN
	CREATE TABLE stg.FSProcedure
		(
		  Jurisdiction CHAR (2) NULL,
		  Extension CHAR (3) NULL,
		  ProcedureCode CHAR (6) NULL,
		  FSProcDescription VARCHAR (24) NULL,
		  Sv CHAR (1) NULL,
		  Star CHAR (1) NULL,
		  Panel CHAR (1) NULL,
		  Ip CHAR (1) NULL,
		  Mult CHAR (1) NULL,
		  AsstSurgeon CHAR (1) NULL,
		  SectionFlag CHAR (1) NULL,
		  Fup CHAR (3) NULL,
		  Bav SMALLINT NULL,
		  ProcGroup CHAR (4) NULL,
		  ViewType SMALLINT NULL,
		  UnitValue1 MONEY NULL,
		  UnitValue2 MONEY NULL,
		  UnitValue3 MONEY NULL,
		  UnitValue4 MONEY NULL,
		  UnitValue5 MONEY NULL,
		  UnitValue6 MONEY NULL,
		  UnitValue7 MONEY NULL,
		  UnitValue8 MONEY NULL,
		  UnitValue9 MONEY NULL,
		  UnitValue10 MONEY NULL,
		  UnitValue11 MONEY NULL,
		  UnitValue12 MONEY NULL,
		  ProUnitValue1 MONEY NULL,
		  ProUnitValue2 MONEY NULL,
		  ProUnitValue3 MONEY NULL,
		  ProUnitValue4 MONEY NULL,
		  ProUnitValue5 MONEY NULL,
		  ProUnitValue6 MONEY NULL,
		  ProUnitValue7 MONEY NULL,
		  ProUnitValue8 MONEY NULL,
		  ProUnitValue9 MONEY NULL,
		  ProUnitValue10 MONEY NULL,
		  ProUnitValue11 MONEY NULL,
		  ProUnitValue12 MONEY NULL,
		  TechUnitValue1 MONEY NULL,
		  TechUnitValue2 MONEY NULL,
		  TechUnitValue3 MONEY NULL,
		  TechUnitValue4 MONEY NULL,
		  TechUnitValue5 MONEY NULL,
		  TechUnitValue6 MONEY NULL,
		  TechUnitValue7 MONEY NULL,
		  TechUnitValue8 MONEY NULL,
		  TechUnitValue9 MONEY NULL,
		  TechUnitValue10 MONEY NULL,
		  TechUnitValue11 MONEY NULL,
		  TechUnitValue12 MONEY NULL,
		  SiteCode CHAR (3) NULL,
		  DmlOperation CHAR(1) NOT NULL 
		 )
END 
GO

