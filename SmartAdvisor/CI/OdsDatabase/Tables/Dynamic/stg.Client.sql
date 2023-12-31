IF OBJECT_ID('stg.Client', 'U') IS NOT NULL 
	DROP TABLE stg.Client  
BEGIN
	CREATE TABLE stg.Client
		(
		  ClientCode CHAR (4) NULL,
		  Name VARCHAR (30) NULL,
		  Jurisdiction CHAR (2) NULL,
		  ControlNum VARCHAR (20) NULL,
		  PolicyTimeLimit SMALLINT NULL,
		  PolicyLimitWarningPct SMALLINT NULL,
		  PolicyLimit MONEY NULL,
		  PolicyDeductible MONEY NULL,
		  PolicyCoPayPct SMALLINT NULL,
		  PolicyCoPayAmount MONEY NULL,
		  BEDiagnosis CHAR (1) NULL,
		  InvoiceBRCycle CHAR (1) NULL,
		  Status CHAR (1) NULL,
		  InvoiceGroupBy CHAR (1) NULL,
		  BEDOI CHAR (1) NULL,
		  DrugMarkUpBrand SMALLINT NULL,
		  SupplyLimit SMALLINT NULL,
		  InvoicePPOCycle CHAR (1) NULL,
		  InvoicePPOTax SMALLINT NULL,
		  DrugMarkUpGen SMALLINT NULL,
		  DrugDispGen SMALLINT NULL,
		  DrugDispBrand SMALLINT NULL,
		  BEAdjuster CHAR (1) NULL,
		  InvoiceTax SMALLINT NULL,
		  CompanySeq SMALLINT NULL,
		  BEMedAlert CHAR (1) NULL,
		  UCRPercentile SMALLINT NULL,
		  ClientComment VARCHAR (6000) NULL,
		  RemitAttention VARCHAR (30) NULL,
		  RemitAddress1 VARCHAR (30) NULL,
		  RemitAddress2 VARCHAR (30) NULL,
		  RemitCityStateZip VARCHAR (30) NULL,
		  RemitPhone VARCHAR (12) NULL,
		  ExternalID VARCHAR (10) NULL,
		  BEOther CHAR (1) NULL,
		  MedAlertDays SMALLINT NULL,
		  MedAlertVisits SMALLINT NULL,
		  MedAlertMaxCharge MONEY NULL,
		  MedAlertWarnVisits SMALLINT NULL,
		  ProviderSubSet CHAR (4) NULL,
		  AllowReReview CHAR (1) NULL,
		  AcctRep CHAR (2) NULL,
		  ClientType CHAR (1) NULL,
		  UCRMarkUp SMALLINT NULL,
		  InvoiceCombined CHAR (1) NULL,
		  BESubmitDt CHAR (1) NULL,
		  BERcvdCarrierDate CHAR (1) NULL,
		  BERcvdBillReviewDate CHAR (1) NULL,
		  BEDueDate CHAR (1) NULL,
		  ProductCode CHAR (1) NULL,
		  BEProvInvoice CHAR (1) NULL,
		  ClaimSysSubSet CHAR (4) NULL,
		  DefaultBRtoUCR CHAR (1) NULL,
		  BasePPOFeesOffFS CHAR (1) NULL,
		  BEClientTOBTableCode CHAR (2) NULL,
		  BEForcePay CHAR (1) NULL,
		  BEPayAuthorization CHAR (1) NULL,
		  BECarrierSeqFlag CHAR (1) NULL,
		  BEProvTypeTableCode CHAR (2) NULL,
		  BEProvSpcl1TableCode CHAR (2) NULL,
		  BEProvLicense CHAR (1) NULL,
		  BEPayAuthTableCode CHAR (2) NULL,
		  PendReasonTableCode CHAR (2) NULL,
		  VocRehab CHAR (1) NULL,
		  EDIAckRequired CHAR (1) NULL,
		  StateRptInd CHAR (1) NULL,
		  BEPatientAcctNum CHAR (1) NULL,
		  AutoDup CHAR (1) NULL,
		  UseAllowOnDup CHAR (1) NULL,
		  URImportUsed CHAR (1) NULL,
		  URProgStartDate CHAR (1) NULL,
		  URImportCtrlNum CHAR (4) NULL,
		  URImportCtrlGroup CHAR (4) NULL,
		  UCRSource CHAR (1) NULL,
		  UCRMarkup2 SMALLINT NULL,
		  NGDTableCode CHAR (2) NULL,
		  BESubProductTableCode CHAR (2) NULL,
		  CountryTableCode CHAR (2) NULL,
		  BERefPhys CHAR (1) NULL,
		  BEPmtWarnDays SMALLINT NULL,
		  GeoState CHAR (2) NULL,
		  BEDisableDOICheck CHAR (1) NULL,
		  DelayDays SMALLINT NULL,
		  BEValidateTotal CHAR (1) NULL,
		  BEFastMatch CHAR (1) NULL,
		  BEPriorBillDefault CHAR (1) NULL,
		  BEClientDueDays SMALLINT NULL,
		  BEAutoCalcDueDate CHAR (1) NULL,
		  UCRSource2 CHAR (1) NULL,
		  UCRPercentile2 SMALLINT NULL,
		  BEProvSpcl2TableCode CHAR (2) NULL,
		  FeeRateCntrlEx CHAR (4) NULL,
		  FeeRateCntrlIn CHAR (4) NULL,
		  BECollisionProvBills CHAR (1) NULL,
		  BECollisionBills CHAR (1) NULL,
		  SupplyMarkup SMALLINT NULL,
		  BECollisionProviders CHAR (1) NULL,
		  DefaultCoPayDeduct CHAR (1) NULL,
		  AutoBundling CHAR (1) NULL,
		  BEValidateBillClaimICD9 CHAR (1) NULL,
		  EnableGenericReprice CHAR (1) NULL,
		  BESubProdFeeInfo CHAR (1) NULL,
		  DenyNonInjDrugs CHAR (1) NULL,
		  BECollisionDosLines CHAR (1) NULL,
		  PPOProfileSiteCode CHAR (3) NULL,
		  PPOProfileID INT NULL,
		  BEShowDEAWarning CHAR (1) NULL,
		  BEHideAdjusterColumn CHAR (1) NULL,
		  BEHideCoPayColumn CHAR (1) NULL,
		  BEHideDeductColumn CHAR (1) NULL,
		  BEPaidDate CHAR (1) NULL,
		  BEProcCrossWalk CHAR (1) NULL,
		  CreateUserID CHAR (2) NULL,
		  CreateDate DATETIME NULL,
		  ModUserID CHAR (2) NULL,
		  ModDate DATETIME NULL,
		  BEConsultDate CHAR (1) NULL,
		  BEShowPharmacyColumns CHAR (1) NULL,
		  BEAdjVerifDates CHAR (1) NULL,
		  FutureDOSMonthLimit SMALLINT NULL,
		  BEStopAtLineUnits CHAR (1) NULL,
		  BENYNF10Fields CHAR (1) NULL,
		  EnableDRGGrouper CHAR (1) NULL,
		  ApplyCptAmaUcrRules CHAR (1) NULL,
		  BEProvSigOnFile CHAR (1) NULL,
		  BETimeEntry CHAR (1) NULL,
		  SalesTaxExempt CHAR (1) NULL,
		  InvoiceRetailProfile CHAR (4) NULL,
		  InvoiceWholesaleProfile CHAR (4) NULL,
		  BEDefaultTaxZip CHAR (1) NULL,
		  ReceiptHandlingCode CHAR (1) NULL,
		  PaymentHandlingCode CHAR (1) NULL,
		  DefaultRetailSalesTaxZip VARCHAR (9) NULL,
		  DefaultWholesaleSalesTaxZip VARCHAR (9) NULL,
		  TxNonSubscrib CHAR (1) NULL,
		  RootClaimLength SMALLINT NULL,
		  BEDAWTableCode VARCHAR (4) NULL,
		  EORProfileSeq INT NULL,
		  BEOtherBillingProvider CHAR (1) NULL,
		  BEDocCtrlID CHAR (1) NULL,
		  ReportingETL CHAR (1) NULL,
		  ClaimVerification CHAR (1) NULL,
		  ProvVerification CHAR (1) NULL,
		  BEPermitAllowOver CHAR (1) NULL,
		  BEStopAtLineDxRef CHAR (1) NULL,
		  BEQuickInfoCode CHAR (12) NULL,
		  ExcludedSmartClientSelect CHAR (1) NULL,
		  CollisionsSearchBy CHAR (1) NULL,
		  AutoDupIncludeProv CHAR (1) NULL,
		  URProfileID VARCHAR (8) NULL,
		  ExcludeURDM CHAR (1) NULL,
		  BECollisionURCases CHAR (1) NULL,
		  MUEEdits CHAR (1) NULL,
		  CPTRarity NUMERIC (5,2) NULL,
		  ICDRarity NUMERIC (5,2) NULL,
		  ICDToCPTRarity NUMERIC (5,2) NULL,
		  BEDisablePPOSearch CHAR (1) NULL,
		  BEShowLineExternalIDColumn CHAR (1) NULL,
		  BEShowLinePriorAuthColumn CHAR (1) NULL,
		  SmartGuidelinesFlag CHAR (1) NULL,
		  BEProvBillingLicense CHAR (1) NULL,
		  BEProvFacilityLicense CHAR (1) NULL,
		  VendorProviderSubSet CHAR (4) NULL,
		  DefaultJurisClientCode CHAR (1) NULL,
		  ClientGroupId INT NULL,
		  DrugDispFeeApplyTo CHAR (1) NULL,
		  DmlOperation CHAR(1) NOT NULL 
		 )
END 
GO

