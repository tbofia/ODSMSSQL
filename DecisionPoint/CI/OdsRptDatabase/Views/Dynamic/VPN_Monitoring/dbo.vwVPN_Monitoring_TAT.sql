IF OBJECT_ID ('dbo.vwVPN_Monitoring_TAT', 'V') IS NOT NULL
DROP VIEW dbo.vwVPN_Monitoring_TAT;
GO

CREATE VIEW dbo.vwVPN_Monitoring_TAT
AS
SELECT StartOfMonth
      ,Client
      ,BillIdNo
      ,ClaimIdNo
      ,SOJ
      ,NetworkId
      ,NetworkName
      ,SentDate
      ,ReceivedDate
      ,HoursLockedToVPN
      ,TATInHours
      ,CASE WHEN TAT < 0 THEN 0 ELSE TAT END AS TAT
      ,BillCreateDate
      ,ParNonPar
      ,SubNetwork
      ,AmtCharged
      ,BillType
      ,Bucket
      ,ValueBucket
      ,(SELECT MAX(ReceivedDate) FROM dbo.VPN_Monitoring_TAT_Output T WHERE O.Client = T.Client) AS RunTime
      ,RunDate
  FROM dbo.VPN_Monitoring_TAT_Output O
  GO
  