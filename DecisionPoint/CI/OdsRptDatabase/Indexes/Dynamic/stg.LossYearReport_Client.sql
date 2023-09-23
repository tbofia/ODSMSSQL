IF NOT EXISTS (
		SELECT *
		FROM sys.indexes
		WHERE NAME = 'IX_RollUpColumns'
			AND Object_id = OBJECT_ID('stg.LossYearReport_Client')
		)
CREATE NONCLUSTERED INDEX IX_RollUpColumns 
ON stg.LossYearReport_Client(OdsCustomerID,ReportID, SOJ, DateQuarter)
GO

