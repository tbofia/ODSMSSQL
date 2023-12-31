
IF EXISTS (SELECT * FROM sys.objects WHERE OBJECT_ID = OBJECT_ID(N'dbo.ProviderDataExplorerIndustryLoadOutput') AND type in (N'P', N'PC'))
DROP PROCEDURE dbo.ProviderDataExplorerIndustryLoadOutput
GO

CREATE PROCEDURE dbo.ProviderDataExplorerIndustryLoadOutput(
@SourceDatabaseName VARCHAR(50),
@Debug BIT,
@ReportId INT
)
AS
BEGIN

DECLARE @ProcessName VARCHAR(50),		
		@AuditFor VARCHAR(100);

-- Track the Audit for Customer
SET @AuditFor = 'OdsCustomerId : 0';

-- Get the Process Name
SET @ProcessName = ( SELECT OBJECT_NAME(@@PROCID) );

-- Tracking Process start in ETL Audit
EXEC dbo.ProviderDataExplorerIndustryEtlAuditStart @AuditFor,@ProcessName,@ReportId;

DECLARE @SQLScript VARCHAR(MAX);				

SET @SQLScript = CAST('' as VARCHAR(MAX)) + '

-- Get Aggrigated data for all customers.
Truncate table dbo.ProviderDataExplorerIndustryOutput

INSERT INTO dbo.ProviderDataExplorerIndustryOutput
(
		ProviderClusterName
		,FormType
		,SubFormType
		,CoverageLine
		,StateofJurisdiction
		,InjuryType
		,CodeType
		,Code
		,Category
		,SubCategory
		,AvgActualTenure
		,AvgExpectedTenure
		,TotalCharged
		,TotalAllowed
		,TotalAdjustment
		,TotalClaims
		,TotalClaimants
		,TotalBills
		,TotalLines
		)

SELECT  
		ProviderClusterName
		,FormType
		,SubFormType as DFSubFormType
		,ch.DerivedCVDesc as DFCoverageLine
		,ClaimantStateofJurisdiction as DFClaimantStateofJurisdiction
		,InjuryDescription as DFInjuryDescription
		,CodeType
		,Code
		,Category
		,SubCategory
		,AVG(ch.DOSTenureinDays) AS AvgActualTenure
		,AVG(ExpectedTenureinDays) AS AvgExpectedTenure
		,SUM(Charged) AS TotalCharged
		,SUM(Allowed) AS TotalAllowed 
		,SUM(Adjustment) AS TotalAdjustment
		,COUNT(DISTINCT ch.ClaimId) AS TotalClaims
		,COUNT(DISTINCT ch.ClaimantId) AS TotalClaimants
		,COUNT(DISTINCT bl.BillId) AS TotalBills
		,COUNT(LineNumber) AS TotalLines
FROM    
    stg.ProviderDataExplorerIndustryClaimantHeader ch 
    INNER JOIN stg.ProviderDataExplorerIndustryProvider p ON p.ProviderId = ch.ProviderId
										AND ch.OdsCustomerId = p.OdsCustomerId
	INNER JOIN stg.ProviderDataExplorerIndustryBillHeader bh ON bh.ClaimantHeaderId = ch.ClaimantHeaderId
										AND bh.OdsCustomerId = ch.OdsCustomerId
	INNER JOIN stg.ProviderDataExplorerIndustryBillLine bl ON bl.BillId = bh.BillId
										AND bl.OdsCustomerId = bh.OdsCustomerId
   
									
WHERE 
	 ExceptionFlag = 0 		
GROUP BY 
		ProviderClusterName, FormType,SubFormType, ch.DerivedCVDesc, ClaimantStateofJurisdiction, 
		InjuryDescription,CodeType, Code, Category, SubCategory


'
-- Script generates when debug mode is on 
IF (@Debug = 1)
BEGIN
	PRINT @AuditFor;	
	PRINT @ProcessName;
	PRINT(@SQLScript);

END

EXEC(@SQLScript);

-- Tracking Process end in ETL Audit
EXEC dbo.ProviderDataExplorerIndustryEtlAuditEnd @AuditFor,@ProcessName,@ReportId;

END

GO



