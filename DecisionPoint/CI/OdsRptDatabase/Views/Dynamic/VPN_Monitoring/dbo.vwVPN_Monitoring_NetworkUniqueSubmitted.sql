IF OBJECT_ID ('dbo.vwVPN_Monitoring_NetworkUniqueSubmitted', 'V') IS NOT NULL
DROP VIEW dbo.vwVPN_Monitoring_NetworkUniqueSubmitted;
GO

CREATE VIEW dbo.vwVPN_Monitoring_NetworkUniqueSubmitted
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
      ,(SELECT TOP 1 DateTimeStamp FROM stg.VPN_Monitoring_NetworkRepriced T WHERE O.OdsCustomerId = T.OdsCustomerId) AS RunTime
      ,RunDate
FROM dbo.VPN_Monitoring_NetworkUniqueSubmitted_Output O
WHERE  StartOfMonth < (SELECT DATEADD(MM,-1,EOMONTH(MAX(Job_StartDate))) FROM adm.ReportJobAudit WHERE ReportId = 2 AND JobStatus = 1)

GO
  