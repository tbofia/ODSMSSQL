IF OBJECT_ID('dbo.prf_Profile', 'V') IS NOT NULL
    DROP VIEW dbo.prf_Profile;
GO

CREATE VIEW dbo.prf_Profile
AS

SELECT 
	 OdsPostingGroupAuditId
	,OdsCustomerId
	,OdsCreateDate
	,OdsSnapshotDate
	,OdsRowIsCurrent
	,OdsHashbytesValue
	,DmlOperation
	,ProfileId
	,OfficeId
	,CoverageId
	,StateId
	,AnHeader
	,AnFooter
	,ExHeader
	,ExFooter
	,AnalystEdits
	,DxEdits
	,DxNonTraumaDays
	,DxNonSpecDays
	,PrintCopies
	,NewPvdState
	,bDuration
	,bLimits
	,iDurPct
	,iLimitPct
	,PolicyLimit
	,CoPayPercent
	,CoPayMax
	,Deductible
	,PolicyWarn
	,PolicyWarnPerc
	,FeeSchedules
	,DefaultProfile
	,FeeAncillaryPct
	,iGapdol
	,iGapTreatmnt
	,bGapTreatmnt
	,bGapdol
	,bPrintAdjustor
	,sPrinterName
	,ErEdits
	,ErAllowedDays
	,UcrFsRules
	,LogoIdNo
	,LogoJustify
	,BillLine
	,Version
	,ClaimDeductible
	,IncludeCommitted
	,FLMedicarePercent
	,UseLevelOfServiceUrl
	,LevelOfServiceURL
	,CCIPrimary
	,CCISecondary
	,CCIMutuallyExclusive
	,CCIComprehensiveComponent
	,PayDRGAllowance
	,FLHospEmPriceOn
	,EnableBillRelease
	,DisableSubmitBill
	,MaxPaymentsPerBill
	,NoOfPmtPerBill
	,DefaultDueDate
	,CheckForNJCarePaths
	,NJCarePathPercentFS
	,ApplyEndnoteForNJCarePaths
	,FLMedicarePercent2008
	,RequireEndnoteDuringOverride
	,StorePerUnitFSandUCR
	,UseProviderNetworkEnrollment
	,UseASCRule
	,AsstCoSurgeonEligible
	,LastChangedOn
	,IsNJPhysMedCapAfterCTG
	,IsEligibleAmtFeeBased
	,HideClaimTreeTotalsGrid
	,SortBillsBy
	,SortBillsByOrder
	,ApplyNJEmergencyRoomBenchmarkFee
	,AllowIcd10ForNJCarePaths
	,EnableOverrideDeductible
	,AnalyzeDiagnosisPointers
	,MedicareFeePercent
	,EnableSupplementalNdcData
	,ApplyOriginalNdcAwp
	,NdcAwpNotAvailable
	,PayEapgAllowance
	,MedicareInpatientApcEnabled
	,MedicareOutpatientAscEnabled
	,MedicareAscEnabled
	,UseMedicareInpatientApcFee
	,MedicareInpatientDrgEnabled
	,MedicareInpatientDrgPricingType
	,MedicarePhysicianEnabled
	,MedicareAmbulanceEnabled
	,MedicareDmeposEnabled
	,MedicareAspDrugAndClinicalEnabled
	,MedicareInpatientPricingType
	,MedicareOutpatientPricingRulesEnabled
	,MedicareAscPricingRulesEnabled
	,NjUseAdmitTypeEnabled
	,MedicareClinicalLabEnabled
	,MedicareInpatientEnabled
	,MedicareOutpatientApcEnabled
	,MedicareAspDrugEnabled
	,ShowAllocationsOnEob
	,EmergencyCarePricingRuleId
	,OutOfStatePricingEffectiveDateId
	,PreAllocation
	,AssistantCoSurgeonModifiers
	,AssistantSurgeryModifierNotMedicallyNecessary
	,AssistantSurgeryModifierRequireAdditionalDocument
	,CoSurgeryModifierNotMedicallyNecessary
	,CoSurgeryModifierRequireAdditionalDocument
	,DxNoDiagnosisDays
	,ModifierExempted
FROM src.prf_Profile
WHERE   OdsRowIsCurrent = 1
	AND DmlOperation <> 'D';
GO


