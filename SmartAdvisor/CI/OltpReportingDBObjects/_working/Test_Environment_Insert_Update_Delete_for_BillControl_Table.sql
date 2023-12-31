-- Insert Record into dbo.Bill Table to satisfy foreign key referencial integrity
INSERT INTO dbo.Bill
SELECT ClientCode
      ,15
      ,ClaimSeq
      ,ClaimSysSubSet
      ,ProviderSeq
      ,ProviderSubSet
      ,PostDate
      ,DOSFirst
      ,Invoiced
      ,InvoicedPPO
      ,CreateUserID
      ,CarrierSeqNew
      ,DocCtrlType
      ,DOSLast
      ,PPONetworkID
      ,POS
      ,ProvType
      ,ProvSpecialty1
      ,ProvZip
      ,ProvState
      ,SubmitDate
      ,ProvInvoice
      ,Region
      ,HospitalSeq
      ,ModUserID
      ,Status
      ,StatusPrior
      ,BillableLines
      ,TotalCharge
      ,BRReduction
      ,BRFee
      ,TotalAllow
      ,TotalFee
      ,DupClientCode
      ,DupBillSeq
      ,FupStartDate
      ,FupEndDate
      ,SendBackMsg1SiteCode
      ,SendBackMsg1
      ,SendBackMsg2SiteCode
      ,SendBackMsg2
      ,PPOReduction
      ,PPOPrc
      ,PPOContractID
      ,PPOStatus
      ,PPOFee
      ,NGDReduction
      ,NGDFee
      ,URFee
      ,OtherData
      ,ExternalStatus
      ,URFlag
      ,Visits
      ,TOS
      ,TOB
      ,SubProductCode
      ,ForcePay
      ,PmtAuth
      ,FlowStatus
      ,ConsultDate
      ,RcvdDate
      ,AdmissionType
      ,PaidDate
      ,AdmitDate
      ,DischargeDate
      ,TxBillType
      ,RcvdBrDate
      ,DueDate
      ,Adjuster
      ,DOI
      ,RetCtrlFlg
      ,RetCtrlNum
      ,SiteCode
      ,SourceID
      ,CaseType
      ,SubProductID
      ,SubProductPrice
      ,URReduction
      ,ProvLicenseNum
      ,ProvMedicareNum
      ,ProvSpecialty2
      ,PmtExportDate
      ,PmtAcceptDate
      ,ClientTOB
      ,BRFeeNet
      ,PPOFeeNet
      ,NGDFeeNet
      ,URFeeNet
      ,SubProductPriceNet
      ,BillSeqNewRev
      ,BillSeqOrgRev
      ,VocPlanSeq
      ,ReviewDate
      ,AuditDate
      ,ReevalAllow
      ,CheckNum
      ,NegoType
      ,DischargeHour
      ,UB92TOB
      ,MCO
      ,DRG
      ,PatientAccount
      ,ExaminerRevFlag
      ,RefProvName
      ,PaidAmount
      ,AdmissionSource
      ,AdmitHour
      ,PatientStatus
      ,DRGValue
      ,CompanySeq
      ,TotalCoPay
      ,UB92ProcMethod
      ,TotalDeductible
      ,PolicyCoPayAmount
      ,PolicyCoPayPct
      ,DocCtrlID
      ,ResourceUtilGroup
      ,PolicyDeductible
      ,PolicyLimit
      ,PolicyTimeLimit
      ,PolicyWarningPct
      ,AppBenefits
      ,AppAssignee
      ,CreateDate
      ,ModDate
      ,IncrementValue
      ,AdjVerifRequestDate
      ,AdjVerifRcvdDate
      ,RenderingProvLastName
      ,RenderingProvFirstName
      ,RenderingProvMiddleName
      ,RenderingProvSuffix
      ,RereviewCount
      ,DRGBilled
      ,DRGCalculated
      ,ProvRxLicenseNum
      ,ProvSigOnFile
      ,RefProvFirstName
      ,RefProvMiddleName
      ,RefProvSuffix
      ,RefProvDEANum
      ,SendbackMsg1Subset
      ,SendbackMsg2Subset
      ,PPONetworkJurisdictionInd
      ,ManualReductionMode
      ,WholesaleSalesTaxZip
      ,RetailSalesTaxZip
      ,PPONetworkJurisdictionInsurerSeq
      ,InvoicedWholesale
      ,InvoicedPPOWholesale
      ,AdmittingDxRef
      ,AdmittingDxCode
      ,ProvFacilityNPI
      ,ProvBillingNPI
      ,ProvRenderingNPI
      ,ProvOperatingNPI
      ,ProvReferringNPI
      ,ProvOther1NPI
      ,ProvOther2NPI
      ,ProvOperatingLicenseNum
      ,EHubID
      ,OtherBillingProviderSubset
      ,OtherBillingProviderSeq
      ,ResubmissionReasonCode
      ,ContractType
      ,ContractAmount
      ,PriorAuthReferralNum1
      ,PriorAuthReferralNum2
      ,DRGCompositeFactor
      ,DRGDischargeFraction
      ,DRGInpatientMultiplier
      ,DRGWeight
      ,EFTPmtMethodCode
      ,EFTPmtFormatCode
      ,EFTSenderDFIID
      ,EFTSenderAcctNum
      ,EFTOrigCoSupplCode
      ,EFTReceiverDFIID
      ,EFTReceiverAcctQual
      ,EFTReceiverAcctNum
      ,PolicyLimitResult
      ,HistoryBatchNumber
      ,ProvBillingTaxonomy
      ,ProvFacilityTaxonomy
      ,ProvRenderingTaxonomy
      ,PPOStackList
      ,ICDVersion
      ,ODGFlag
      ,ProvBillLicenseNum
      ,ProvFacilityLicenseNum
      ,ProvVendorExternalID
      ,BRActualClientCode
      ,BROverrideClientCode
      ,BillReevalReasonCode
FROM dbo.Bill
WHERE  ClientCode = '09CA'
AND billseq = 14

-- Insert Dummy Record into BillControl Table
BEGIN TRANSACTION 
BEGIN TRY
INSERT INTO dbo.BillControl
SELECT '09CA'
      ,15
      ,billControlSeq
      ,GETDATE()
      ,GETDATE()
      ,'D'
      ,'DUMMY'
      ,0
      ,NULL
      ,NULL
FROM dbo.BillControl
WHERE  ClientCode = '09CA'
AND billseq = 1
COMMIT TRANSACTION;
END TRY
BEGIN CATCH
PRINT 'Could Not Insert Records';
ROLLBACK TRANSACTION
END CATCH


-- Update Dummy Record
BEGIN TRANSACTION 
BEGIN TRY
UPDATE  dbo.BillControl
SET Control = 1,
	ModDate = GETDATE()
FROM dbo.BillControl
WHERE  ClientCode = '09CA'
AND billseq = 1
COMMIT TRANSACTION;
END TRY
BEGIN CATCH
PRINT 'Could Not Update Records';
ROLLBACK TRANSACTION
END CATCH

-- Delete Records From BillControl Table
BEGIN TRANSACTION 
BEGIN TRY

DELETE  from dbo.BillControl
WHERE  ClientCode = '09CA'
AND  BillSeq = 15

COMMIT TRANSACTION;
END TRY
BEGIN CATCH
PRINT 'Could Not Delete Records';
ROLLBACK TRANSACTION
END CATCH
