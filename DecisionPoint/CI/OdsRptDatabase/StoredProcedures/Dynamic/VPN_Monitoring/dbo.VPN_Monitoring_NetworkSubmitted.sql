IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'dbo.VPN_Monitoring_NetworkSubmitted') AND type in (N'P', N'PC'))
DROP PROCEDURE dbo.VPN_Monitoring_NetworkSubmitted
GO

CREATE PROCEDURE dbo.VPN_Monitoring_NetworkSubmitted(    
@SourceDatabaseName VARCHAR(50)='AcsOds',
@StartDate AS DATETIME,
@EndDate AS DATETIME,
@if_Date AS DATETIME = NULL,
@RunType INT = 0,
@OdsCustomerId INT = 0)
AS
BEGIN
--1.1 Initial Filter to get the date range we are interested in and filter Bill exclusion bills
--DECLARE @SourceDatabaseName VARCHAR(50)='AcsOds',@StartDate DATETIME = '2014-03-01 00:00:00.000' , @EndDate DATETIME = '2015-03-31 00:00:00.000',@RunType INT = 0,@if_Date AS DATETIME = GETDATE(),@OdsCustomerId INT = 2

--2.1 Raw Data Network Sends
DECLARE @SQLScript VARCHAR(MAX) = '
DECLARE @RunPostingGroupAuditId INT = (SELECT '+@SourceDatabaseName+'.adm.Mnt_GetPostingGroupAuditIdAsOfSnapshotDate('+CAST(@OdsCustomerID as VARCHAR(5))+','''+CONVERT(VARCHAR(10),ISNULL(@if_Date,GETDATE()),112)+''')) ;

SELECT  PNEL.LogDate ,
        PNEL.EventId ,
        PNEL.BillIdNo ,
        PNEL.ProcessInfo ,
        PNEL.NetworkId,
		DATEADD(MONTH, DATEDIFF(MONTH, 0, PNEL.LogDate), 0) StartOfMonth,
        PNEL.OdsCustomerId,
        YEAR(PNEL.LogDate) ReportYear,
        MONTH(PNEL.LogDate) ReportMonth
        
INTO #ProviderNetworkEventLog_Filtered
FROM   '+@SourceDatabaseName+'.dbo.'+CASE WHEN @RunType = 0 THEN 'ProviderNetworkEventLog' ELSE 'if_ProviderNetworkEventLog(@RunPostingGroupAuditId)' END+' PNEL
INNER JOIN ' +@SourceDatabaseName + '.adm.Customer C
	ON PNEL.OdsCustomerId = C.CustomerId
LEFT OUTER JOIN '+@SourceDatabaseName+'.dbo.'+CASE WHEN @RunType = 0 THEN 'CustomerBillExclusion' ELSE 'if_CustomerBillExclusion(@RunPostingGroupAuditId)' END+' BX
	ON C.CustomerDatabase = BX.Customer
	AND BX.BIllIdNo = PNEL.BillIdNo
	AND BX.ReportID = 2
WHERE '+CASE WHEN @OdsCustomerId <> 0 THEN ' PNEL.OdsCustomerId = '+CAST(@OdsCustomerId AS VARCHAR(3))+' AND ' ELSE '' END + ' PNEL.EventId IN ( 16, 11, 10 )
	AND CONVERT(VARCHAR(10),PNEL.LogDate,112) BETWEEN '''+CONVERT(VARCHAR(10),@StartDate,112)+''' AND '''+CONVERT(VARCHAR(10),@EndDate,112)+'''
	AND BX.BIllIdNo IS NULL;

TRUNCATE TABLE stg.VPN_Monitoring_ProviderNetworkEventLog_Filtered;
-- Raw Data
INSERT INTO stg.VPN_Monitoring_ProviderNetworkEventLog_Filtered
SELECT  PNELF.LogDate ,
        PNELF.EventId ,
        PNELF.BillIdNo ,
        PNELF.ProcessInfo ,
        PNELF.NetworkId,
		PNELF.StartOfMonth,
        PNELF.OdsCustomerId,
        PNELF.ReportYear,
        PNELF.ReportMonth,
		ISNULL(CLMT.CmtStateOfJurisdiction, ''NA'') SOJ,
        CASE WHEN  BH.[Flags] & 4096 > 0 THEN ''UB-04''   ELSE ''CMS-1500''  END  BillType,
        COALESCE(BH.CV_type,CLMT.CoverageType,CLM.CV_Code,''NA'') CV_Type,
        ISNULL(CPNY.CompanyName, ''NA'')  Company,
        ISNULL(OFC.OfcName, ''NA'') Office,
        ISNULL(BH.AmtCharged, 0) ProviderCharges,
        ISNULL(BH.PrePPOAllowed, 0) BRAllowable,
		VPN.NetworkName,
		BPN.NetworkName SubNetwork
		
FROM #ProviderNetworkEventLog_Filtered PNELF
LEFT OUTER JOIN '+@SourceDatabaseName+'.dbo.'+CASE WHEN @RunType = 0 THEN 'BILL_HDR' ELSE 'if_BILL_HDR(@RunPostingGroupAuditId)' END+' BH 
	ON BH.OdsCustomerId = PNELF.OdsCustomerId  AND BH.BillIDNo = PNELF.BillIdNo
LEFT OUTER JOIN '+@SourceDatabaseName+'.dbo.'+CASE WHEN @RunType = 0 THEN 'CMT_HDR' ELSE 'if_CMT_HDR(@RunPostingGroupAuditId)' END+' CH 
	ON CH.OdsCustomerId = BH.OdsCustomerId  AND CH.CMT_HDR_IDNo = BH.CMT_HDR_IDNo
LEFT OUTER JOIN '+@SourceDatabaseName+'.dbo.'+CASE WHEN @RunType = 0 THEN 'CLAIMANT' ELSE 'if_CLAIMANT(@RunPostingGroupAuditId)' END+' CLMT 
	ON CLMT.OdsCustomerId = CH.OdsCustomerId  AND CLMT.CmtIDNo = CH.CmtIDNo
LEFT OUTER JOIN '+@SourceDatabaseName+'.dbo.'+CASE WHEN @RunType = 0 THEN 'CLAIMS' ELSE 'if_CLAIMS(@RunPostingGroupAuditId)' END+' CLM 
	ON CLM.OdsCustomerId = CLMT.OdsCustomerId  AND CLM.ClaimIDNo = CLMT.ClaimIDNo
LEFT OUTER JOIN '+@SourceDatabaseName+'.dbo.'+CASE WHEN @RunType = 0 THEN 'prf_Office' ELSE 'if_prf_Office(@RunPostingGroupAuditId)' END+' OFC 
	ON OFC.OdsCustomerId = CLM.OdsCustomerId  AND OFC.CompanyId = CLM.CompanyID
     AND OFC.OfficeId = CLM.OfficeIndex
LEFT OUTER JOIN '+@SourceDatabaseName+'.dbo.'+CASE WHEN @RunType = 0 THEN 'prf_COMPANY' ELSE 'if_prf_COMPANY(@RunPostingGroupAuditId)' END+' CPNY 
	ON CPNY.OdsCustomerId = OFC.OdsCustomerId  AND CPNY.CompanyId = OFC.CompanyId
LEFT OUTER JOIN '+@SourceDatabaseName+'.dbo.'+CASE WHEN @RunType = 0 THEN 'Vpn' ELSE 'if_Vpn(@RunPostingGroupAuditId)' END+' VPN 
	ON VPN.OdsCustomerId = PNELF.OdsCustomerId  AND VPN.VpnId = PNELF.NetworkId
LEFT OUTER JOIN '+@SourceDatabaseName+'.dbo.'+CASE WHEN @RunType = 0 THEN 'BillsProviderNetwork' ELSE 'if_BillsProviderNetwork(@RunPostingGroupAuditId)' END+' BPN 
	ON BPN.OdsCustomerId = PNELF.OdsCustomerId  AND BPN.BillIdNo = PNELF.BillIdNo
	AND BPN.NetworkId = PNELF.NetworkId
	AND PNELF.EventId IN(10,16)
	AND PNELF.ProcessInfo = 2;

TRUNCATE TABLE stg.VPN_Monitoring_NetworkSubmitted;
--2.2 Find ALL bills repriced even if repriced a multiplicity of times
INSERT INTO stg.VPN_Monitoring_NetworkSubmitted
SELECT  PNELF.StartOfMonth ,
        PNELF.OdsCustomerId ,
        PNELF.ReportYear ,
        PNELF.ReportMonth ,
        PNELF.SOJ ,
        PNELF.NetworkName ,
        PNELF.BillType ,
        PNELF.CV_Type ,
        PNELF.Company ,
        PNELF.Office ,
        COUNT(DISTINCT CASE WHEN PNELF.EventId = 11 THEN PNELF.BillIdNo END) AS BillsCount ,
		COUNT(DISTINCT (CASE WHEN WEAH.WeekEndsAndHolidayId IS NOT NULL AND PNELF.EventId = 11 THEN billIDNo END)) + 0.0 AS BillsCount_WeekEnd,
		COUNT(DISTINCT (CASE WHEN WEAH.WeekEndsAndHolidayId IS NULL AND PNELF.EventId = 11 THEN  billIDNo END)) + 0.0 AS BillsCount_WeekDay,
		COUNT(DISTINCT CASE WHEN PNELF.EventId IN(10,16) AND PNELF.ProcessInfo = 2 THEN PNELF.BillIdNo END) AS BillsRePriced,
		COUNT(DISTINCT CASE WHEN WEAH.WeekEndsAndHolidayId IS NOT NULL AND PNELF.EventId IN(10,16) AND PNELF.ProcessInfo = 2 THEN PNELF.BillIdNo END) AS BillsRePriced_WeekEnd,
		COUNT(DISTINCT CASE WHEN WEAH.WeekEndsAndHolidayId IS NULL AND PNELF.EventId IN(10,16) AND PNELF.ProcessInfo = 2 THEN PNELF.BillIdNo END) AS BillsRePriced_WeekDay,
        SUM(CASE WHEN PNELF.EventId = 11 THEN PNELF.ProviderCharges ELSE 0 END) AS ProviderCharges ,
		SUM(CASE WHEN WEAH.WeekEndsAndHolidayId IS NOT NULL AND PNELF.EventId = 11 THEN PNELF.ProviderCharges ELSE 0 END) AS ProviderCharges_WeekEnd ,
		SUM(CASE WHEN WEAH.WeekEndsAndHolidayId IS NULL AND PNELF.EventId = 11 THEN PNELF.ProviderCharges ELSE 0 END) AS ProviderCharges_WeekDay ,
        SUM(CASE WHEN PNELF.EventId = 11 THEN PNELF.BRAllowable ELSE 0 END) AS BRAllowable ,
		SUM(CASE WHEN WEAH.WeekEndsAndHolidayId IS NOT NULL AND PNELF.EventId = 11 THEN PNELF.BRAllowable ELSE 0 END) AS BRAllowable_WeekEnd ,
		SUM(CASE WHEN WEAH.WeekEndsAndHolidayId IS NULL AND PNELF.EventId = 11 THEN PNELF.BRAllowable ELSE 0 END) AS BRAllowable_WeekDay

FROM  stg.VPN_Monitoring_ProviderNetworkEventLog_Filtered PNELF
LEFT OUTER JOIN '+@SourceDatabaseName+'.dbo.'+CASE WHEN @RunType = 0 THEN 'WeekEndsAndHolidays' ELSE'if_WeekEndsAndHolidays(@RunPostingGroupAuditId)' END+' WEAH
		ON PNELF.OdsCustomerId = WEAH.OdsCustomerId
		AND CAST(PNELF.LogDate AS DATE) = CAST(WEAH.DayOfWeekDate AS DATE)
WHERE PNELF.EventId = 11 
OR (PNELF.EventId IN (10,16) AND PNELF.ProcessInfo = 2)

GROUP BY PNELF.StartOfMonth ,
        PNELF.OdsCustomerId ,
        PNELF.ReportYear ,
        PNELF.ReportMonth ,
        PNELF.SOJ ,
        PNELF.NetworkName ,
        PNELF.BillType ,
        PNELF.CV_Type ,
        PNELF.Company ,
        PNELF.Office;'
	
EXEC(@SQLScript);

END
GO
