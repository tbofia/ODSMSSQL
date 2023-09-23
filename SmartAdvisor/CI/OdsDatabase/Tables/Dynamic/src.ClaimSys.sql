IF OBJECT_ID('src.ClaimSys', 'U') IS NULL 
	BEGIN
		CREATE TABLE src.ClaimSys
			(
			  OdsPostingGroupAuditId INT NOT NULL ,  
			  OdsCustomerId INT NOT NULL , 
			  OdsCreateDate DATETIME2(7) NOT NULL ,
			  OdsSnapshotDate DATETIME2(7) NOT NULL , 
			  OdsRowIsCurrent BIT NOT NULL ,
			  OdsHashbytesValue VARBINARY(8000) NULL ,
			  DmlOperation CHAR(1) NOT NULL ,  
			  ClaimSysSubset CHAR (4) NOT NULL ,
			  ClaimIDMask VARCHAR (35) NULL ,
			  ClaimAccess CHAR (1) NULL ,
			  ClaimSysDesc VARCHAR (30) NULL ,
			  PolicyholderReq CHAR (1) NULL ,
			  ValidateBranch CHAR (1) NULL ,
			  ValidatePolicy CHAR (1) NULL ,
			  LglCode1TableCode CHAR (2) NULL ,
			  LglCode2TableCode CHAR (2) NULL ,
			  LglCode3TableCode CHAR (2) NULL ,
			  UROccTableCode CHAR (2) NULL ,
			  Policy5DaysTableCode CHAR (2) NULL ,
			  Policy90DaysTableCode CHAR (2) NULL ,
			  Job5DaysTableCode CHAR (2) NULL ,
			  Job90DaysTableCode CHAR (2) NULL ,
			  HCOTransIndTableCode CHAR (2) NULL ,
			  QualifiedInjWorkTableCode CHAR (2) NULL ,
			  PermStationaryTableCode CHAR (2) NULL ,
			  ValidateAdjuster CHAR (1) NULL ,
			  MCOProgram CHAR (1) NULL ,
			  AdjusterRequired CHAR (1) NULL ,
			  HospitalAdmitTableCode CHAR (2) NULL ,
			  AttorneyTaxAddrRequired CHAR (1) NULL ,
			  BodyPartTableCode CHAR (2) NULL ,
			  PolicyDefaults CHAR (1) NULL ,
			  PolicyCoPayAmount MONEY NULL ,
			  PolicyCoPayPct SMALLINT NULL ,
			  PolicyDeductible MONEY NULL ,
			  PolicyLimit MONEY NULL ,
			  PolicyTimeLimit SMALLINT NULL ,
			  PolicyLimitWarningPct SMALLINT NULL ,
			  RestrictUserAccess CHAR (1) NULL ,
			  BEOverridePermissionFlag CHAR (1) NULL ,
			  RootClaimLength SMALLINT NULL ,
			  RelateClaimsTotalPolicyDetail CHAR (1) NULL ,
			  PolicyLimitResult CHAR (1) NULL ,
			  EnableClaimClientCodeDefault CHAR (1) NULL ,
			  ReevalCopyDocCtrlID CHAR (1) NULL ,
			  EnableCEPHeaderFieldEdits CHAR (1) NULL ,
			  EnableSmartClientSelection CHAR (1) NULL ,
			  SCSClientSelectionCode CHAR (12) NULL ,
			  SCSProviderSubset CHAR (4) NULL ,
			  SCSClientCodeMask CHAR (4) NULL ,
			  SCSDefaultClient CHAR (4) NULL ,
			  ClaimExternalIDasCarrierClaimID CHAR (1) NULL ,
			  PolicyExternalIDasCarrierPolicyID CHAR (1) NULL ,
			  URProfileID VARCHAR (8) NULL ,
			  BEUROverridesRequireReviewRef CHAR (1) NULL ,
			  UREntryValidations CHAR (1) NULL ,
			  PendPPOEDIControl CHAR (1) NULL ,
			  BEReevalLineAddDelete CHAR (1) NULL ,
			  CPTGroupToIndividual CHAR (1) NULL ,
			  ClaimExternalIDasClaimAdminClaimNum CHAR (1) NULL ,
			  CreateUserID CHAR (2) NULL ,
			  CreateDate DATETIME NULL ,
			  ModUserID CHAR (2) NULL ,
			  ModDate DATETIME NULL ,
			  FinancialAggregation XML NULL ,

 ) ON DP_Ods_PartitionScheme(OdsCustomerId) 
 WITH (
       DATA_COMPRESSION = PAGE); 

     ALTER TABLE src.ClaimSys ADD 
     CONSTRAINT PK_ClaimSys PRIMARY KEY CLUSTERED (OdsPostingGroupAuditId, OdsCustomerId, ClaimSysSubset) WITH (DATA_COMPRESSION = PAGE) ON
     DP_Ods_PartitionScheme(OdsCustomerId);

     ALTER INDEX PK_ClaimSys ON src.ClaimSys   REBUILD WITH(STATISTICS_INCREMENTAL = ON); 
 END 
 GO
IF NOT EXISTS ( SELECT  1
				FROM    sys.columns  
				WHERE   object_id = OBJECT_ID(N'src.ClaimSys')
						AND NAME = 'FinancialAggregation' )
	BEGIN
		ALTER TABLE src.ClaimSys ADD FinancialAggregation XML NULL ;
	END ; 
GO


