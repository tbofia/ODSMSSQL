 IF OBJECT_ID ('dbo.vwPPO_ActivityReport_MasterCoverage', 'V') IS NOT NULL
DROP VIEW dbo.vwPPO_ActivityReport_MasterCoverage;
GO
CREATE VIEW dbo.vwPPO_ActivityReport_MasterCoverage
AS
SELECT StartOfMonth
      ,Customer
      ,Year
      ,Month
      ,Company
      ,Office
      ,SOJ
      ,Coverage
      ,Form_Type
      ,Total_Bills
      ,Total_Provider_Charges
      ,Total_Bill_Review_Reductions
      ,CASE WHEN StartOfMonth < (SELECT MAX(StartOfMonth) FROM dbo.PPO_ActivityReport_MasterCoverage_Output WHERE ReportTypeId = 2) THEN 2 ELSE ReportTypeId END AS ReportTypeId
      ,RunDate
  FROM dbo.PPO_ActivityReport_MasterCoverage_Output
  
  
GO

