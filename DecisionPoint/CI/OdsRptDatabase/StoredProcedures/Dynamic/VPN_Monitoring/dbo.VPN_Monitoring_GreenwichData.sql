IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'dbo.VPN_Monitoring_GreenwichData') AND type in (N'P', N'PC'))
DROP PROCEDURE dbo.VPN_Monitoring_GreenwichData
GO

CREATE PROCEDURE dbo.VPN_Monitoring_GreenwichData (
@SourceDatabaseName VARCHAR(50) = 'AcsOds',
@TargetDatabaseName VARCHAR(50) = 'ReportDB')
AS
BEGIN
-- VPN_Monitoring_NetworkCredits_Output 

DECLARE @SQLQuery VARCHAR(MAX) = 
'DELETE FROM '+@TargetDatabaseName+'.dbo.VPN_Monitoring_NetworkCredits_Output 
WHERE Customer = ''Greenwich'';
INSERT INTO '+@TargetDatabaseName+'.dbo.VPN_Monitoring_NetworkCredits_Output 
SELECT 0 
      ,''Greenwich'' Customer
      ,Period 
      ,SOJ 
      ,CV_Type 
      ,BillType 
      ,Network 
      ,''Company1'' Company
      ,''Office1'' Office
      ,ActivityFlagDesc 
      ,CreditReasonDesc 
      ,AVG(Credits) Credits
      ,GETDATE()
FROM  '+@TargetDatabaseName+'.dbo.VPN_Monitoring_NetworkCredits_Output 
WHERE Customer IN ( ''FBFS'', ''Sentry'', ''BristolWest'',''OneBeacon'')
GROUP BY Period 
      ,SOJ 
      ,CV_Type 
      ,BillType 
      ,Network 
      ,ActivityFlagDesc 
      ,CreditReasonDesc; 
      
-- VPN_Monitoring_NetworkRepricedSubmitted_Output
DELETE FROM '+@TargetDatabaseName+'.dbo.VPN_Monitoring_NetworkRepricedSubmitted_Output
WHERE Customer = ''Greenwich'';
INSERT INTO '+@TargetDatabaseName+'.dbo.VPN_Monitoring_NetworkRepricedSubmitted_Output
SELECT StartOfMonth
      ,0
      ,''Greenwich'' Customer
      ,SOJ
      ,NetworkName
      ,BillType
      ,ReportYear
      ,ReportMonth
      ,CV_Type
      ,''Company1'' Company
      ,''Office1'' Office
      ,AVG(BillsCount)
      ,AVG(BillsRepriced)
      ,AVG(ProviderCharges)
      ,AVG(BRAllowable)
      ,AVG(InNetworkCharges)
      ,AVG(InNetworkAmountAllowed)
      ,AVG(Savings)
      ,AVG(Credits)
      ,AVG(NetSavings)
	  ,ReportTypeId
      ,GETDATE()
FROM '+@TargetDatabaseName+'.dbo.VPN_Monitoring_NetworkRepricedSubmitted_Output
WHERE Customer IN ( ''FBFS'', ''Sentry'', ''BristolWest'',''OneBeacon'')
GROUP BY StartOfMonth
      ,SOJ
      ,NetworkName
      ,BillType
      ,ReportYear
      ,ReportMonth
      ,CV_Type
	  ,ReportTypeId;

-- VPN_Monitoring_NetworkUniqueSubmitted_Output  
DELETE FROM '+@TargetDatabaseName+'.dbo.VPN_Monitoring_NetworkUniqueSubmitted_Output
WHERE Customer = ''Greenwich'';    
INSERT INTO '+@TargetDatabaseName+'.dbo.VPN_Monitoring_NetworkUniqueSubmitted_Output
SELECT StartOfMonth
      ,0
      ,''Greenwich'' Customer
      ,ReportYear
      ,ReportMonth
      ,SOJ
      ,BillType
      ,CV_Type
      ,''Company1'' Company
      ,''Office1'' Office
      ,AVG(InNetworkCharges)
      ,AVG(InNetworkAmountAllowed)
      ,AVG(Savings)
      ,AVG(Credits)
      ,AVG(NetSavings)
      ,AVG(BillsCount)
      ,AVG(BillsRePriced)
      ,AVG(ProviderCharges)
      ,AVG(BRAllowable)
	  ,ReportTypeId
      ,GETDATE()
FROM '+@TargetDatabaseName+'.dbo.VPN_Monitoring_NetworkUniqueSubmitted_Output
WHERE Customer IN ( ''FBFS'', ''Sentry'', ''BristolWest'',''OneBeacon'')
GROUP BY StartOfMonth
      ,SOJ
      ,BillType
      ,ReportYear
      ,ReportMonth
      ,CV_Type
	  ,ReportTypeId

-- VPN_Monitoring_TAT_Output
DELETE FROM '+@TargetDatabaseName+'.dbo.VPN_Monitoring_TAT_Output
WHERE Client = ''Greenwich''; 
INSERT INTO '+@TargetDatabaseName+'.dbo.VPN_Monitoring_TAT_Output
SELECT 0
	  ,StartOfMonth
      ,''Greenwich'' Customer
      ,BillIdNo
      ,ClaimIdNo
      ,SOJ
      ,NetworkId
      ,NetworkName
      ,SentDate
      ,ReceivedDate
      ,AVG(HoursLockedToVPN)
      ,AVG(TATInHours)
      ,AVG(TAT)
      ,BillCreateDate
      ,ParNonPar
      ,SubNetwork
      ,AVG(AmtCharged)
      ,BillType
      ,CASE WHEN AVG(TAT) < 24 THEN ''24''
            WHEN AVG(TAT) >= 24  AND AVG(TAT) < 48 THEN ''48''
            WHEN AVG(TAT) >= 48  AND AVG(TAT) < 72 THEN ''72''
            WHEN AVG(TAT) >= 72  AND AVG(TAT) < 96 THEN ''96''
            WHEN AVG(TAT) >= 96  AND AVG(TAT) < 120 THEN ''120''
            ELSE ''Over120''    END AS Bucket
      ,CASE WHEN AVG(AmtCharged) < 5000 THEN ''Less Than 5000''
            WHEN AVG(AmtCharged) >= 5000  AND AVG(AmtCharged) < 10000 THEN ''Less Than 10000''
            WHEN AVG(AmtCharged) >= 10000 AND AVG(AmtCharged) < 20000 THEN ''Less Than 20000''
            WHEN AVG(AmtCharged) >= 20000 AND AVG(AmtCharged) < 30000 THEN ''Less Than 30000''
            WHEN AVG(AmtCharged) >= 30000 AND AVG(AmtCharged) < 40000 THEN ''Less Than 40000''
            WHEN AVG(AmtCharged) >= 40000 AND AVG(AmtCharged) < 50000 THEN ''Less Than 50000''
            ELSE ''Over 50000'' END AS ValueBucket
      ,GETDATE()
FROM '+@TargetDatabaseName+'.dbo.VPN_Monitoring_TAT_Output
WHERE Client IN ( ''FBFS'', ''Sentry'', ''BristolWest'',''OneBeacon'')
GROUP BY  StartOfMonth
      ,BillIdNo
      ,ClaimIdNo
      ,SOJ
      ,NetworkId
      ,NetworkName
      ,SentDate
      ,ReceivedDate
      ,BillCreateDate
      ,ParNonPar
      ,SubNetwork
      ,BillType;'

EXEC (@SQLQuery)
END

GO

