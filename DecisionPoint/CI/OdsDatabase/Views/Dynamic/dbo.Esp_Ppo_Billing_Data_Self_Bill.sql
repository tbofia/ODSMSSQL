IF OBJECT_ID('dbo.Esp_Ppo_Billing_Data_Self_Bill', 'V') IS NOT NULL
    DROP VIEW dbo.Esp_Ppo_Billing_Data_Self_Bill;
GO

CREATE VIEW dbo.Esp_Ppo_Billing_Data_Self_Bill
AS

SELECT 
	 OdsPostingGroupAuditId
	,OdsCustomerId
	,OdsCreateDate
	,OdsSnapshotDate
	,OdsRowIsCurrent
	,OdsHashbytesValue
	,DmlOperation
	,COMPANYCODE
	,TRANSACTIONTYPE
	,BILL_HDR_AMTALLOWED
	,BILL_HDR_AMTCHARGED
	,BILL_HDR_BILLIDNO
	,BILL_HDR_CMT_HDR_IDNO
	,BILL_HDR_CREATEDATE
	,BILL_HDR_CV_TYPE
	,BILL_HDR_FORM_TYPE
	,BILL_HDR_NOLINES
	,BILLS_ALLOWED
	,BILLS_ANALYZED
	,BILLS_CHARGED
	,BILLS_DT_SVC
	,BILLS_LINE_NO
	,CLAIMANT_CLIENTREF_CMTSUFFIX
	,CLAIMANT_CMTFIRST_NAME
	,CLAIMANT_CMTIDNO
	,CLAIMANT_CMTLASTNAME
	,CMTSTATEOFJURISDICTION
	,CLAIMS_COMPANYID
	,CLAIMS_CLAIMNO
	,CLAIMS_DATELOSS
	,CLAIMS_OFFICEINDEX
	,CLAIMS_POLICYHOLDERSNAME
	,CLAIMS_POLICYNUMBER
	,PNETWKEVENTLOG_EVENTID
	,PNETWKEVENTLOG_LOGDATE
	,PNETWKEVENTLOG_NETWORKID
	,ACTIVITY_FLAG
	,PPO_AMTALLOWED
	,PREPPO_AMTALLOWED
	,PREPPO_ALLOWED_FS
	,PRF_COMPANY_COMPANYNAME
	,PRF_OFFICE_OFCNAME
	,PRF_OFFICE_OFCNO
	,PROVIDER_PVDFIRSTNAME
	,PROVIDER_PVDGROUP
	,PROVIDER_PVDLASTNAME
	,PROVIDER_PVDTIN
	,PROVIDER_STATE
	,UDFCLAIM_UDFVALUETEXT
	,ENTRY_DATE
	,UDFCLAIMANT_UDFVALUETEXT
	,SOURCE_DB
	,CLAIMS_CV_CODE
	,VPN_TRANSACTIONID
	,VPN_TRANSACTIONTYPEID
	,VPN_BILLIDNO
	,VPN_LINE_NO
	,VPN_CHARGED
	,VPN_DPALLOWED
	,VPN_VPNALLOWED
	,VPN_SAVINGS
	,VPN_CREDITS
	,VPN_HASOVERRIDE
	,VPN_ENDNOTES
	,VPN_NETWORKIDNO
	,VPN_PROCESSFLAG
	,VPN_LINETYPE
	,VPN_DATETIMESTAMP
	,VPN_SEQNO
	,VPN_VPN_REF_LINE_NO
	,VPN_NETWORKNAME
	,VPN_SOJ
	,VPN_CAT3
	,VPN_PPODATESTAMP
	,VPN_NINTEYDAYS
	,VPN_BILL_TYPE
	,VPN_NET_SAVINGS
	,CREDIT
	,RECON
	,DELETED
	,STATUS_FLAG
	,DATE_SAVED
	,SUB_NETWORK
	,INVALID_CREDIT
	,PROVIDER_SPECIALTY
	,ADJUSTOR_IDNUMBER
	,ACP_FLAG
	,OVERRIDE_ENDNOTES
	,OVERRIDE_ENDNOTES_DESC
FROM src.Esp_Ppo_Billing_Data_Self_Bill
WHERE   OdsRowIsCurrent = 1
	AND DmlOperation <> 'D';
GO


