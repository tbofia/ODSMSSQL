IF OBJECT_ID('dbo.PrePpoBillInfo', 'V') IS NOT NULL
    DROP VIEW dbo.PrePpoBillInfo;
GO

CREATE VIEW dbo.PrePpoBillInfo
AS

SELECT 
	 OdsPostingGroupAuditId
	,OdsCustomerId
	,OdsCreateDate
	,OdsSnapshotDate
	,OdsRowIsCurrent
	,OdsHashbytesValue
	,DmlOperation
	,DateSentToPPO
	,ClaimNo
	,ClaimIDNo
	,CompanyID
	,OfficeIndex
	,CV_Code
	,DateLoss
	,Deductible
	,PaidCoPay
	,PaidDeductible
	,LossState
	,CmtIDNo
	,CmtCoPaymentMax
	,CmtCoPaymentPercentage
	,CmtDedType
	,CmtDeductible
	,CmtFLCopay
	,CmtPolicyLimit
	,CmtStateOfJurisdiction
	,PvdIDNo
	,PvdTIN
	,PvdSPC_List
	,PvdTitle
	,PvdFlags
	,DateSaved
	,DateRcv
	,InvoiceDate
	,NoLines
	,AmtCharged
	,AmtAllowed
	,Region
	,FeatureID
	,Flags
	,WhoCreate
	,WhoLast
	,CmtPaidDeductible
	,InsPaidLimit
	,StatusFlag
	,CmtPaidCoPay
	,Category
	,CatDesc
	,CreateDate
	,PvdZOS
	,AdmissionDate
	,DischargeDate
	,DischargeStatus
	,TypeOfBill
	,PaymentDecision
	,PPONumberSent
	,BillIDNo
	,LINE_NO
	,LINE_NO_DISP
	,OVER_RIDE
	,DT_SVC
	,PRC_CD
	,UNITS
	,TS_CD
	,CHARGED
	,ALLOWED
	,ANALYZED
	,REF_LINE_NO
	,SUBNET
	,FEE_SCHEDULE
	,POS_RevCode
	,CTGPenalty
	,PrePPOAllowed
	,PPODate
	,PPOCTGPenalty
	,UCRPerUnit
	,FSPerUnit
	,HCRA_Surcharge
	,NDC
	,PriceTypeCode
	,PharmacyLine
	,Endnotes
	,SentryEN
	,CTGEN
	,CTGRuleType
	,CTGRuleID
	,OverrideEN
	,UserId
	,DateOverriden
	,AmountBeforeOverride
	,AmountAfterOverride
	,CodesOverriden
	,NetworkID
	,BillSnapshot
	,PPOSavings
	,RevisedDate
	,ReconsideredDate
	,TierNumber
	,PPOBillInfoID
	,PrePPOBillInfoID
	,CtgCoPayPenalty
	,PpoCtgCoPayPenaltyPercentage
	,CtgVunPenalty
	,PpoCtgVunPenaltyPercentage
FROM src.PrePpoBillInfo
WHERE   OdsRowIsCurrent = 1
	AND DmlOperation <> 'D';
GO


