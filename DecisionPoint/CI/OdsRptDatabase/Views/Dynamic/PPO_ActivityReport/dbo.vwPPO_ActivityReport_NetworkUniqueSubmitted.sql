IF OBJECT_ID ('dbo.vwPPO_ActivityReport_NetworkUniqueSubmitted', 'V') IS NOT NULL
DROP VIEW dbo.vwPPO_ActivityReport_NetworkUniqueSubmitted;
GO

CREATE VIEW dbo.vwPPO_ActivityReport_NetworkUniqueSubmitted
AS
SELECT StartOfMonth
      ,OdsCustomerId
      ,Customer
      ,ReportYear
      ,ReportMonth
      ,SOJ
      ,BillType
      ,CV_Type
      ,Company
      ,Office
      ,InNetworkCharges
      ,InNetworkAmountAllowed
      ,Savings
      ,Credits
      ,NetSavings
      ,BillsCount
      ,BillsRePriced
      ,ProviderCharges
      ,BRAllowable
	  ,CASE WHEN StartOfMonth < (SELECT MAX(StartOfMonth) FROM dbo.VPN_Monitoring_NetworkUniqueSubmitted_Output WHERE ReportTypeId = 2) THEN 2 ELSE ReportTypeId END AS ReportTypeId
      ,(SELECT TOP 1 DateTimeStamp FROM stg.VPN_Monitoring_NetworkRepriced T WHERE O.OdsCustomerId = T.OdsCustomerId) AS RunTime
      ,RunDate
FROM dbo.VPN_Monitoring_NetworkUniqueSubmitted_Output O

GO
  