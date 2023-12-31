
IF EXISTS (SELECT * FROM sys.objects WHERE OBJECT_ID = OBJECT_ID(N'dbo.ProviderDataExplorerIndustryLoadBillLine') AND type in (N'P', N'PC'))
DROP PROCEDURE dbo.ProviderDataExplorerIndustryLoadBillLine
GO

CREATE PROCEDURE dbo.ProviderDataExplorerIndustryLoadBillLine(
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
SET @AuditFor = 'OdsCustomerId : 0'

-- Get the Process Name
SET @ProcessName = ( SELECT OBJECT_NAME(@@PROCID) );

-- Tracking Process start in ETL Audit
EXEC dbo.ProviderDataExplorerIndustryEtlAuditStart @AuditFor,@ProcessName,@ReportId;

DECLARE @SQLScript VARCHAR(MAX)
		

SET @SQLScript = CAST('' AS VARCHAR(MAX))+
'

-- Fetching RevenueCodes, Cpt_prc codes and category,subcategory for revenue codes.

IF OBJECT_ID(''tempdb..#RevenueCodes'') IS NOT NULL
	DROP TABLE #RevenueCodes

SELECT * INTO #RevenueCodes FROM '+@SourceDatabaseName+'.dbo.ub_revenuecodes

UPDATE	rc
SET
	revenuecodesubcategoryid=rc2.revenuecodesubcategoryid
FROM
	#RevenueCodes rc
	JOIN (SELECT DISTINCT revenuecode,revenuecodesubcategoryid FROM #RevenueCodes WHERE  revenuecodesubcategoryid IS NOT NULL) rc2 ON
	rc.revenuecode=rc2.revenuecode AND rc.revenuecodesubcategoryid IS NULL

IF OBJECT_ID(''tempdb..#CodeHierarchy'') IS NOT NULL
	DROP TABLE #CodeHierarchy
	
SELECT
	''Procedure'' Dataset,
	odscustomerid OdsCustomerId,	
	prc_cd Code,
	SUBSTRING(prc_desc,0,2500) Description,
	''Procedure'' Category,
	''Procedure'' SubCategory,
	StartDate,
	EndDate
INTO #CodeHierarchy
FROM
	'+@SourceDatabaseName+'.dbo.cpt_prc_dict

UNION

SELECT
	''Revenue'' Dataset,
	rc.odscustomerid,	
	rc.revenuecode,
	SUBSTRING(rc.prc_desc,0,2500) prc_desc,
	UPPER(rcc.Description),
	UPPER(rcsc.Description),
	StartDate,
	EndDate
FROM
	#RevenueCodes rc
	LEFT JOIN '+@SourceDatabaseName+'.dbo.revenuecodesubcategory rcsc ON rc.revenuecodesubcategoryid=rcsc.revenuecodesubcategoryid AND rc.odscustomerid=rcsc.odscustomerid 
	LEFT JOIN '+@SourceDatabaseName+'.dbo.revenuecodecategory rcc ON rcsc.revenuecodecategoryid=rcc.revenuecodecategoryid AND rcsc.odscustomerid=rcc.odscustomerid 


IF EXISTS (SELECT Name FROM tempdb.sys.indexes  WHERE Name = ''IDXPACodeHierarchyCode'' 
    AND object_id = OBJECT_ID(''tempdb..#CodeHierarchy''))
  BEGIN
    DROP INDEX IDXPACodeHierarchyCode ON #CodeHierarchy;
  END
CREATE INDEX IDXPACodeHierarchyCode ON #CodeHierarchy (DataSet,Code);


-- Creating Index on BillHeader
IF EXISTS (SELECT Name FROM sys.indexes  WHERE Name=''IDX_PDE_IC_CHOdsCustomerIdBillIdNo'' 
    AND object_id = OBJECT_ID(''stg.ProviderDataExplorerIndustryBillHeader''))
  BEGIN
    DROP INDEX IDX_PDE_IC_CHOdsCustomerIdBillIdNo ON stg.ProviderDataExplorerIndustryBillHeader;
  END
CREATE INDEX IDX_PDE_IC_CHOdsCustomerIdBillIdNo ON stg.ProviderDataExplorerIndustryBillHeader (OdsCustomerId,BillId,TypeOfBill);


TRUNCATE TABLE stg.ProviderDataExplorerIndustryBillLine;

DECLARE @ODSPDEICPRCodeTypePharma  VARCHAR(100),
		@ODSPDEICUB04 VARCHAR(10),
		@ODSPDEICCMS1500 VARCHAR(10),
		@ODSPDEICBillLineTypePharma VARCHAR(30),
		@ODSPDEICBillLineType VARCHAR(30),
		@ODSPDEICPRDescPharma VARCHAR(100),
		@ODSPDEICPRCategoryPharma VARCHAR(100),
		@ODSPDEICPRSubCategoryPharma VARCHAR(100);

		SELECT @ODSPDEICUB04 = ParameterValue FROM  adm.ReportParameters WHERE ReportId = '+CAST(@ReportId AS VARCHAR(3))+' AND ParameterName = ''ODSPDEICUB04''
		SELECT @ODSPDEICCMS1500 = ParameterValue FROM  adm.ReportParameters WHERE ReportId = '+CAST(@ReportId AS VARCHAR(3))+' AND ParameterName = ''ODSPDEICCMS1500''
		SELECT @ODSPDEICBillLineType = ParameterValue FROM  adm.ReportParameters WHERE ReportId = '+CAST(@ReportId AS VARCHAR(3))+' AND ParameterName = ''ODSPDEICBillLineType''
		SELECT @ODSPDEICPRCodeTypePharma = ParameterValue FROM adm.ReportParameters WHERE ReportId = '+CAST(@ReportId AS VARCHAR(3))+' AND ParameterName = ''ODSPDEICPRCodeTypePharma''
		SELECT @ODSPDEICPRDescPharma = ParameterValue FROM adm.ReportParameters WHERE ReportId = '+CAST(@ReportId AS VARCHAR(3))+' AND ParameterName = ''ODSPDEICPRDescPharma''
		SELECT @ODSPDEICPRCategoryPharma = ParameterValue FROM adm.ReportParameters WHERE ReportId = '+CAST(@ReportId AS VARCHAR(3))+' AND ParameterName = ''ODSPDEICPRCategoryPharma''
		SELECT @ODSPDEICPRSubCategoryPharma = ParameterValue FROM adm.ReportParameters WHERE ReportId = '+CAST(@ReportId AS VARCHAR(3))+' AND ParameterName = ''ODSPDEICPRSubCategoryPharma''
		SELECT @ODSPDEICBillLineTypePharma = ParameterValue FROM  adm.ReportParameters WHERE ReportId = '+CAST(@ReportId AS VARCHAR(3))+' AND ParameterName = ''ODSPDEICBillLineTypePharma''

		-- Loading BillLines  and PharmabillLines by Union
INSERT INTO stg.ProviderDataExplorerIndustryBillLine(
			OdsCustomerId,
			BillId,
			LineNumber,			
			OverRide,
			DateofService,
			ProcedureCode,			
			Charged,
			Allowed,			
			RefLineNo,
			POSRevCode,
			Adjustment,
			FormType,
			CodeType,
			Code,
			BillLineType,
			CodeDescription,
			Category,
			SubCategory,
			IsCodeNumeric		
)
SELECT 		
			b.OdsCustomerId,
			b.BillIdNo,
			b.LINE_NO,			
			b.Over_Ride,
			b.DT_SVC,
			b.PRC_CD,
			b.Charged,
			b.Allowed,
			b.REF_LINE_NO,
			b.POS_RevCode,
			ISNULL(b.CHARGED, 0) - ISNULL(b.ALLOWED, 0) AS Adjustment,
			    CASE
                  WHEN(bh.Flags&4096) = 4096
                  THEN @ODSPDEICUB04
                  ELSE @ODSPDEICCMS1500
              END AS FormTypeDesc,
			  CASE
					WHEN (bh.Flags&4096) = ''4096'' AND ISNULL(b.prc_cd,'''')<>'''' AND ISNULL(b.pos_revcode,'''')<>'''' AND SUBSTRING(bh.TypeOfBill,1,1)=''3'' THEN ''Procedure''
					WHEN (bh.Flags&4096) = ''4096'' AND ISNULL(b.prc_cd,'''')<>'''' AND ISNULL(b.pos_revcode,'''')<>'''' AND SUBSTRING(bh.TypeOfBill,1,1)<>''3'' THEN ''REVENUE''
					WHEN (bh.Flags&4096) = ''4096'' AND ISNULL(b.prc_cd,'''')='''' THEN ''REVENUE''
			ELSE ''Procedure'' END PR_Code_Type,
			  CASE
					WHEN (bh.Flags&4096) = ''4096'' AND ISNULL(b.prc_cd,'''')<>'''' AND ISNULL(b.pos_revcode,'''')<>'''' AND SUBSTRING(bh.TypeOfBill,1,1)=''3'' THEN b.prc_cd
					WHEN (bh.Flags&4096) = ''4096'' AND ISNULL(b.prc_cd,'''')<>'''' AND ISNULL(b.pos_revcode,'''')<>'''' AND SUBSTRING(bh.TypeOfBill,1,1)<>''3'' THEN b.pos_revcode
					WHEN (bh.Flags&4096) = ''4096'' AND ISNULL(b.prc_cd,'''')='''' THEN b.pos_revcode
			ELSE b.prc_cd END PR_Code,
			@ODSPDEICBillLineType,
			ch.Description CodeDescription,
			ch.Category CodeCategory,
			ch.SubCategory CodeSubCategory,
			CASE WHEN ISNUMERIC(b.PRC_CD) = 1 THEN 1 
				 WHEN ISNUMERIC(b.PRC_CD) = 0 THEN 0 END		

	FROM '+@SourceDatabaseName+'.dbo.BILLS b 
	INNER JOIN stg.ProviderDataExplorerIndustryBillHeader bh ON b.OdsCustomerId = bh.OdsCustomerId 
																				AND b.BillIdNo = bh.BillId
	LEFT JOIN #CodeHierarchy ch ON	 CASE
					WHEN (bh.Flags&4096) = ''4096'' AND ISNULL(b.prc_cd,'''')<>'''' AND ISNULL(b.pos_revcode,'''')<>'''' AND SUBSTRING(bh.TypeOfBill,1,1)=''3'' THEN ''Procedure''
					WHEN (bh.Flags&4096) = ''4096'' AND ISNULL(b.prc_cd,'''')<>'''' AND ISNULL(b.pos_revcode,'''')<>'''' AND SUBSTRING(bh.TypeOfBill,1,1)<>''3'' THEN ''Revenue''
					WHEN (bh.Flags&4096) = ''4096'' AND ISNULL(b.prc_cd,'''')='''' THEN ''Revenue''
			ELSE ''Procedure'' END = ch.Dataset
			AND
					 CASE
							WHEN (bh.Flags&4096) = ''4096'' AND ISNULL(b.prc_cd,'''')<>'''' AND ISNULL(b.pos_revcode,'''')<>'''' AND SUBSTRING(bh.TypeOfBill,1,1)=''3'' THEN b.prc_cd
							WHEN (bh.Flags&4096) = ''4096'' AND ISNULL(b.prc_cd,'''')<>'''' AND ISNULL(b.pos_revcode,'''')<>'''' AND SUBSTRING(bh.TypeOfBill,1,1)<>''3'' THEN b.pos_revcode
							WHEN (bh.Flags&4096) = ''4096'' AND ISNULL(b.prc_cd,'''')='''' THEN b.pos_revcode
					ELSE b.prc_cd END = ch.Code
			AND b.DT_SVC BETWEEN ch.StartDate AND ch.EndDate
			AND b.OdsCustomerId = ch.OdsCustomerId        
		
		WHERE  b.PRC_CD <> ''COORD''

UNION 
-- Loading Pharmacy bills
SELECT 		
			bp.OdsCustomerId,
			bp.BillIdNo,
			bp.LINE_NO,
			bp.OverRide,
			bp.DateOfService,
			REPLACE(bp.NDC,''-'','''') AS NDC,
			bp.Charged,
			bp.Allowed,
			0,
			bp.POS_RevCode,
			ISNULL(bp.CHARGED, 0) - ISNULL(bp.ALLOWED, 0) AS Adjustment,
			CASE
               WHEN(bh.Flags&4096) = 4096
               THEN @ODSPDEICUB04
               ELSE @ODSPDEICCMS1500
			 END AS FormTypeDesc,			
			@ODSPDEICPRCodeTypePharma AS PR_Code_Type,			 
			CONVERT(VARCHAR(100),REPLACE(NDC,''-'','''')) AS PR_Code,
			@ODSPDEICBillLineTypePharma,			
			@ODSPDEICPRDescPharma,
			@ODSPDEICPRCategoryPharma,
			@ODSPDEICPRSubCategoryPharma,
			CASE WHEN ISNUMERIC(REPLACE(bp.NDC,''-'','''')) = 1 THEN 1 
				 WHEN ISNUMERIC(REPLACE(bp.NDC,''-'','''')) = 0 THEN 0 END			

		FROM '+@SourceDatabaseName+'.dbo.Bills_Pharm bp
		INNER JOIN stg.ProviderDataExplorerIndustryBillHeader bh ON bp.OdsCustomerId = bh.OdsCustomerId 
																				AND bp.BillIdNo = bh.BillId												
			
		DROP INDEX IDX_PDE_IC_CHOdsCustomerIdBillIdNo ON stg.ProviderDataExplorerIndustryBillHeader;
			
	   DELETE b  
       FROM  stg.ProviderDataExplorerIndustryBillLine b 
	   INNER JOIN '+@SourceDatabaseName+'.dbo.BILLS_Endnotes e ON b.BillId = e.BillIDNo 
													AND b.LineNumber = e.LINE_NO 
													AND b.OdsCustomerId = e.OdsCustomerId
       WHERE e.EndNote = 45 ;
	   
-- Update the category and subcategory for RC codes like 
-- RC250 is replaced with 0250 and provider category and subcategory 
	   
UPDATE	b 
SET
	b.Category = rc.Category,
	b.SubCategory = rc.SubCategory
FROM
	stg.ProviderDataExplorerIndustryBillLine b
    INNER JOIN  rpt.ProviderDataExplorerPRCodeDataQuality Pr ON b.Code = pr.Code 
												AND  ISNULL(pr.Category,'''' ) = '''' 
												AND pr.MappedCode = ''RC''
												AND b.Code like ''RC%''
	INNER JOIN #CodeHierarchy rc ON REPLACE(b.Code,''RC'',''0'') = rc.Code 
												AND b.OdsCustomerId = rc.OdsCustomerId ;

		
IF EXISTS (SELECT Name FROM sys.indexes  WHERE Name = ''IDPA_ProviderDataExplorerIndustryBillLinePOSRevCode'' 
    AND object_id = OBJECT_ID(''stg.ProviderDataExplorerIndustryBillLine''))
	BEGIN
    DROP INDEX IDPA_ProviderDataExplorerIndustryBillLinePOSRevCode ON stg.ProviderDataExplorerIndustryBillLine;
  END
CREATE INDEX IDPA_ProviderDataExplorerIndustryBillLinePOSRevCode ON stg.ProviderDataExplorerIndustryBillLine (BillId,POSRevCode);


-- Calculation for subformtype based on UB_BillType and PlaceOfServiceDictionary tables.

IF OBJECT_ID(''tempdb..#SubFormTypeTemp'') IS NOT NULL
	DROP TABLE #SubFormTypeTemp
SELECT  Bl.OdsCustomerId,
		Bl.BillId,
		Bl.LineNumber,
		ISNULL(CASE WHEN  bl.FormType = ''CMS-1500'' THEN Ps.Description 
								     WHEN  bl.FormType = ''UB-04''    THEN SUBSTRING(bt.Description,1,CHARINDEX('';'',bt.Description)-1)						   
						        END ,''N/A'') SubFormType
		INTO #SubFormTypeTemp
FROM stg.ProviderDataExplorerIndustryBillHeader bh 
INNER JOIN stg.ProviderDataExplorerIndustryBillLine bl ON bl.BillId = bh.BillId 
												AND bl.OdsCustomerId = bh.OdsCustomerId 												
LEFT JOIN '+@SourceDatabaseName+'.dbo.UB_BillType bt on bh.TypeOfBill = bt.tob 
												AND bl.OdsCustomerId = bt.OdsCustomerId 												
LEFT JOIN '+@SourceDatabaseName+'.dbo.PlaceOfServiceDictionary ps ON  bl.POSRevCode = RIGHT(CONCAT(''00'', ISNULL(CONVERT(VARCHAR(2),ps.PlaceOfServiceCode),'''')),2)
												AND bl.OdsCustomerId = ps.OdsCustomerId 
												AND (CONVERT(DATE,bl.DateOfService) BETWEEN StartDate AND EndDate)
		
		
	IF EXISTS (SELECT Name FROM tempdb.sys.indexes  WHERE Name = ''IDXPA_PDE_IC_SubFormTypeTempBillIdNo'' 
    AND object_id = OBJECT_ID(''tempdb..#SubFormTypeTemp''))
  BEGIN
    DROP INDEX IDXPA_PDE_IC_SubFormTypeTempBillIdNo ON #SubFormTypeTemp;
  END
CREATE INDEX IDXPA_PDE_IC_SubFormTypeTempBillIdNo ON #SubFormTypeTemp (OdsCustomerId,BillId,LineNumber);
		
	-- Update Subformtype into ProviderDataExplorerIndustryBillLine table
												
	UPDATE bl 
		SET 
		bl.SubFormType = ISNULL(UPPER( sf.SubFormType ), ''N/A'')
FROM stg.ProviderDataExplorerIndustryBillLine bl 
INNER JOIN  #SubFormTypeTemp SF ON SF.OdsCustomerId= bl.OdsCustomerId 
									AND  SF.BillId = bl.BillId 
									AND SF.LineNumber = bl.LineNumber
	
	
IF EXISTS (SELECT Name FROM sys.indexes  WHERE Name = ''IDPA_ProviderDataExplorerIndustryBillLinePOSRevCode'' 
    AND object_id = OBJECT_ID(''stg.ProviderDataExplorerIndustryBillLine''))
	BEGIN
    DROP INDEX IDPA_ProviderDataExplorerIndustryBillLinePOSRevCode ON stg.ProviderDataExplorerIndustryBillLine;
  END

  


  /*Implementing Category and subscategory logic.
  Using static rpt tables.
  */

   DECLARE @ODSPDEICPRDesc VARCHAR(100),
		@ODSPDEICPRCategory VARCHAR(100),
		@ODSPDEICPRSubCategory VARCHAR(100)	
		
		SELECT @ODSPDEICPRDesc = ParameterValue FROM  adm.ReportParameters WHERE ReportId = '+CAST(@ReportId AS VARCHAR(3))+' AND ParameterName = ''ODSPDEICPRDesc''
		SELECT @ODSPDEICPRCategory = ParameterValue FROM  adm.ReportParameters WHERE ReportId = '+CAST(@ReportId AS VARCHAR(3))+' AND ParameterName = ''ODSPDEICPRCategory''
		SELECT @ODSPDEICPRSubCategory = ParameterValue FROM  adm.ReportParameters WHERE ReportId = '+CAST(@ReportId AS VARCHAR(3))+' AND ParameterName = ''ODSPDEICPRSubCategory''



  IF OBJECT_ID(''tempdb..#IsCodeNumericzeroDP'',''U'') IS NOT NULL
		DROP TABLE #IsCodeNumericzeroDP;

   SELECT CodeStart,
	      CodeEnd,
	      Category,
	      SubCategory,
	      Description,
	      CodeType,
	      IsCodeNumeric
	INTO #IsCodeNumericzeroDP
	FROM rpt.ProviderDataExplorerCodeHierarchy WHERE IsCodeNumeric = 0
IF EXISTS (SELECT Name FROM tempdb.sys.indexes
			WHERE Name = ''IX_IsCodeNumericzeroDP''
			AND OBJECT_ID = OBJECT_ID(''tempdb..#IsCodeNumericzeroDP''))
BEGIN
DROP INDEX IX_IsCodeNumericzeroDP ON #IsCodeNumericzeroDP ;
END
CREATE INDEX IX_IsCodeNumericzeroDP ON #IsCodeNumericzeroDP (CodeStart,CodeEnd);


IF OBJECT_ID(''tempdb..#IsCodeNumericOneDP'',''U'') IS NOT NULL
		DROP TABLE #IsCodeNumericOneDP;

   SELECT CodeStart,
	      Category,
	      SubCategory,
	      Description,
	      CodeType,
	      IsCodeNumeric
	INTO #IsCodeNumericOneDP
	FROM rpt.ProviderDataExplorerCodeHierarchy WHERE IsCodeNumeric = 1 
IF EXISTS (SELECT Name FROM tempdb.sys.indexes
			WHERE Name = ''IX_IsCodeNumericOneDP''
			AND OBJECT_ID = OBJECT_ID(''tempdb..#IsCodeNumericOneDP''))
BEGIN
DROP INDEX IX_IsCodeNumericOneDP ON #IsCodeNumericOneDP ;
END
CREATE INDEX IX_IsCodeNumericOneDP ON #IsCodeNumericOneDP (CodeStart);


UPDATE  b
			SET 
			CodeType = CASE WHEN b.CodeType IN (''Procedure'',''NDC'') AND b.IsCodeNumeric = 0 THEN ISNULL(chy.CodeType,@ODSPDEICPRDesc)
							WHEN b.CodeType IN (''Procedure'',''NDC'') AND b.IsCodeNumeric = 1 THEN ISNULL(ndcchy.CodeType,@ODSPDEICPRDesc)
							WHEN b.CodeType = ''Revenue'' THEN ISNULL(b.CodeType,@ODSPDEICPRDesc)
							ELSE ISNULL(b.CodeType,@ODSPDEICPRDesc) END ,			
			
			CodeDescription = CASE WHEN b.CodeType = ''NDC'' AND b.IsCodeNumeric = 0 THEN ISNULL(ndcchy.Description,@ODSPDEICPRDesc)
									WHEN b.CodeType = ''NDC'' AND b.IsCodeNumeric = 1 THEN ISNULL(chy.Description,@ODSPDEICPRDesc)
									WHEN b.CodeType IN (''Procedure'',''Revenue'') THEN ISNULL(b.CodeDescription,@ODSPDEICPRDesc)
								END ,
			Category = CASE WHEN b.CodeType IN (''Procedure'',''NDC'') AND b.IsCodeNumeric = 0 THEN ISNULL(chy.Category,@ODSPDEICPRCategory)
							 WHEN b.CodeType IN (''Procedure'',''NDC'') AND b.IsCodeNumeric = 1 THEN ISNULL(ndcchy.Category,@ODSPDEICPRCategory)
							 WHEN b.CodeType = ''Revenue'' THEN ISNULL(b.Category,@ODSPDEICPRCategory)
								END ,
			SubCategory = CASE WHEN b.CodeType IN (''Procedure'',''NDC'') AND b.IsCodeNumeric = 0 THEN ISNULL(chy.SubCategory,@ODSPDEICPRSubCategory)
								WHEN b.CodeType IN (''Procedure'',''NDC'') AND b.IsCodeNumeric = 1 THEN ISNULL(ndcchy.SubCategory,@ODSPDEICPRSubCategory)
								WHEN b.CodeType = ''Revenue'' THEN ISNULL(b.SubCategory,@ODSPDEICPRSubCategory)
							END		
						
			
FROM  stg.ProviderDataExplorerIndustryBillLine b 
		LEFT JOIN #IsCodeNumericzeroDP chy ON b.Code BETWEEN chy.CodeStart AND chy.CodeEnd
			    AND b.IsCodeNumeric = chy.IsCodeNumeric
			    AND b.CodeType IN (''Procedure'',''NDC'')
			    AND b.IsCodeNumeric = 0			          
	LEFT JOIN #IsCodeNumericOneDP ndcchy ON b.Code = ndcchy.CodeStart
			    AND b.IsCodeNumeric = Ndcchy.IsCodeNumeric
			    AND b.CodeType IN (''Procedure'',''NDC'')
			    AND b.IsCodeNumeric = 1
	
		'

IF(@Debug = 1)
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




