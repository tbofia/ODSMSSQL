IF OBJECT_ID('dbo.PPOContract', 'V') IS NOT NULL
    DROP VIEW dbo.PPOContract;
GO

CREATE VIEW dbo.PPOContract
AS

SELECT 
	 OdsPostingGroupAuditId
	,OdsCustomerId
	,OdsCreateDate
	,OdsSnapshotDate
	,OdsRowIsCurrent
	,OdsHashbytesValue
	,DmlOperation
	,PPONetworkID
	,PPOContractID
	,SiteCode
	,TIN
	,AlternateTIN
	,StartDate
	,EndDate
	,OPLineItemDefaultDiscount
	,CompanyName
	,First
	,GroupCode
	,GroupName
	,OPDiscountBaseValue
	,OPOffFS
	,OPOffUCR
	,OPOffCharge
	,OPEffectiveDate
	,OPAdditionalDiscountOffLink
	,OPTerminationDate
	,OPUCRPercentile
	,OPCondition
	,IPDiscountBaseValue
	,IPOffFS
	,IPOffUCR
	,IPOffCharge
	,IPEffectiveDate
	,IPTerminationDate
	,IPCondition
	,IPStopCapAmount
	,IPStopCapRate
	,MinDisc
	,MaxDisc
	,MedicalPerdiem
	,SurgicalPerdiem
	,ICUPerdiem
	,PsychiatricPerdiem
	,MiscParm
	,SpcCode
	,PPOType
	,BillingAddress1
	,BillingAddress2
	,BillingCity
	,BillingState
	,BillingZip
	,PracticeAddress1
	,PracticeAddress2
	,PracticeCity
	,PracticeState
	,PracticeZip
	,PhoneNum
	,OutFile
	,InpatFile
	,URCoordinatorFlag
	,ExclusivePPOOrgFlag
	,StopLossTypeCode
	,BR_RNEDiscount
	,ModDate
	,ExportFlag
	,OPManualIndicator
	,OPStopCapAmount
	,OPStopCapRate
	,Specialty1
	,Specialty2
	,LessorOfThreshold
	,BilateralDiscount
	,SurgeryDiscount2
	,SurgeryDiscount3
	,SurgeryDiscount4
	,SurgeryDiscount5
	,Matrix
	,ProvType
	,AllInclusive
	,Region
	,PaymentAddressFlag
	,MedicalGroup
	,MedicalGroupCode
	,RateMode
	,PracticeCounty
	,FIPSCountyCode
	,PrimaryCareFlag
	,PPOContractIDOld
	,MultiSurg
	,BiLevel
	,DRGRate
	,DRGGreaterThanBC
	,DRGMinPercentBC
	,CarveOut
	,PPOtoFSSeq
	,LicenseNum
	,MedicareNum
	,NPI
FROM src.PPOContract
WHERE   OdsRowIsCurrent = 1
	AND DmlOperation <> 'D';
GO


