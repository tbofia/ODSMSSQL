IF OBJECT_ID ('dbo.vwVPN_Monitoring_NetworkRepricedSubmitted', 'V') IS NOT NULL
DROP VIEW dbo.vwVPN_Monitoring_NetworkRepricedSubmitted;
GO

CREATE VIEW dbo.vwVPN_Monitoring_NetworkRepricedSubmitted
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
      ,(SELECT TOP 1 DateTimeStamp FROM stg.VPN_Monitoring_NetworkRepriced T WHERE O.OdsCustomerId = T.OdsCustomerId) AS RunTime
      ,RunDate
 FROM dbo.VPN_Monitoring_NetworkRepricedSubmitted_Output O
 WHERE  StartOfMonth < (SELECT DATEADD(MM,-1,EOMONTH(MAX(Job_StartDate))) FROM adm.ReportJobAudit WHERE ReportId = 2 AND JobStatus = 1)
 

 GO
 