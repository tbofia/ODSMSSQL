IF OBJECT_ID('stg.BillAdjustment', 'U') IS NOT NULL
DROP TABLE stg.BillAdjustment
BEGIN
	CREATE TABLE stg.BillAdjustment (
		BillLineAdjustmentId BIGINT NULL
		,BillIdNo INT NULL
		,LineNumber INT NULL
		,Adjustment MONEY NULL
		,EndNote INT NULL
		,EndNoteTypeId INT NULL
		,DmlOperation CHAR(1) NOT NULL
		)
END
GO
