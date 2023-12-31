
IF EXISTS (SELECT * FROM sys.objects WHERE OBJECT_ID = OBJECT_ID(N'dbo.ProviderDataExplorerIndustryLoadProvider') AND type in (N'P', N'PC'))
DROP PROCEDURE dbo.ProviderDataExplorerIndustryLoadProvider
GO

CREATE PROCEDURE dbo.ProviderDataExplorerIndustryLoadProvider(
@SourceDatabaseName VARCHAR(50),
@StartDate AS DATETIME,
@EndDate AS DATETIME,
@Debug BIT,
@ReportId INT
)
AS
BEGIN

DECLARE 
		@ProcessName VARCHAR(50),
		@AuditFor VARCHAR(100)
		-- Track the Audit for Customer
SET @AuditFor = 'OdsCustomerId : 0';

-- Get the Process Name
SET @ProcessName = ( SELECT OBJECT_NAME(@@PROCID) );

-- Tracking Process start in ETL Audit
EXEC dbo.ProviderDataExplorerIndustryEtlAuditStart @AuditFor,@ProcessName,@ReportId;

DECLARE @SQLScript VARCHAR(MAX);

SET @SQLScript=

	-- Step1: Insert providers data joining with staging ClaimantHeader table 

' 
IF EXISTS (SELECT Name FROM sys.indexes  WHERE Name=''IDX_PDEIC_CHOdsCustomerIdProviderId'' 
    AND object_id = OBJECT_ID(''stg.ProviderDataExplorerIndustryClaimantHeader''))
  BEGIN
    DROP INDEX IDX_PDEIC_CHOdsCustomerIdProviderId ON stg.ProviderDataExplorerIndustryClaimantHeader;
  END
CREATE INDEX IDX_PDEIC_CHOdsCustomerIdProviderId ON stg.ProviderDataExplorerIndustryClaimantHeader (OdsCustomerId,ProviderId);


TRUNCATE TABLE stg.ProviderDataExplorerIndustryProvider;

INSERT INTO stg.ProviderDataExplorerIndustryProvider(
			OdsCustomerId,
			ProviderId,
			ProviderTIN,
			ProviderFirstName,
			ProviderLastName,
			ProviderGroup,
			ProviderState,
			ProviderZip,
			ProviderNPINumber,	
			ProviderTypeID,
			ProviderName,
			ProviderClusterID				
)
SELECT 					
			p.OdsCustomerId,
			p.PvdIDNo,
			p.PvdTIN,
			p.PvdFirstName,
			p.PvdLastName,			
			p.PvdGroup,
			p.PvdState,
			SUBSTRING(p.PvdZip,1,5),			
			p.PvdNPINo,
			prs.ProviderType,			
             CASE  WHEN prs.ProviderType = ''G'' THEN
                        CASE
                               WHEN LEN(LTRIM(RTRIM(p.PvdGroup))) > 0 THEN LTRIM(RTRIM(UPPER(p.PvdGroup)))
                               ELSE LTRIM(RTRIM(UPPER(p.PvdFirstName))) + '' '' + LTRIM(RTRIM(UPPER(p.PvdLastName)))
                        END
              ELSE
                      CASE
                                 WHEN LEN(LTRIM(RTRIM(p.PvdFirstName))) > 0 THEN LTRIM(RTRIM(UPPER(p.PvdFirstName))) + '' '' + LTRIM(RTRIM(UPPER(p.PvdLastName)))
                                   ELSE  LTRIM(RTRIM(UPPER(p.PvdGroup)))
                        END
              END,

			prs.ProviderClusterKey
				

		FROM   '
		+ CHAR(13)+CHAR(10)+CHAR(9) +@SourceDatabaseName+'.dbo.PROVIDER p 
		INNER JOIN (SELECT DISTINCT OdsCustomerId,ProviderId FROM stg.ProviderDataExplorerIndustryClaimantHeader) ch ON p.OdsCustomerId = ch.OdsCustomerId 
												AND p.PvdIdNo = ch.ProviderId
		LEFT JOIN  '+@SourceDatabaseName+'.dbo.ProviderCluster prs ON p.PvdIDNo = prs.PvdIDNo 
											    AND p.ODSCustomerID = prs.OrgOdsCustomerId												
		  DROP INDEX IDX_PDEIC_CHOdsCustomerIdProviderId ON stg.ProviderDataExplorerIndustryClaimantHeader;'		
		
		
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


