IF OBJECT_ID ('dbo.vwPPO_ActivityReport_NetworkRepricedSubmitted', 'V') IS NOT NULL
DROP VIEW dbo.vwPPO_ActivityReport_NetworkRepricedSubmitted;
GO

CREATE VIEW dbo.vwPPO_ActivityReport_NetworkRepricedSubmitted
AS
SELECT StartOfMonth
      ,OdsCustomerId
      ,Customer
      ,SOJ
      ,NetworkName
      ,BillType
      ,ReportYear
      ,ReportMonth
      ,CV_Type
      ,Company
      ,Office
      ,BillsCount
      ,BillsRepriced
      ,ProviderCharges
      ,BRAllowable
      ,InNetworkCharges
      ,InNetworkAmountAllowed
      ,Savings
      ,Credits
      ,NetSavings
	  ,CASE WHEN StartOfMonth < (SELECT MAX(StartOfMonth) FROM dbo.VPN_Monitoring_NetworkRepricedSubmitted_Output WHERE ReportTypeId = 2) THEN 2 ELSE ReportTypeId END AS ReportTypeId
      ,(SELECT TOP 1 DateTimeStamp FROM stg.VPN_Monitoring_NetworkRepriced T WHERE O.OdsCustomerId = T.OdsCustomerId) AS RunTime
      ,RunDate
 FROM dbo.VPN_Monitoring_NetworkRepricedSubmitted_Output O

 GO
 