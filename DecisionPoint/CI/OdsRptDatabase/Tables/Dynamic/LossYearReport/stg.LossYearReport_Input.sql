IF OBJECT_ID('stg.LossYearReport_Input', 'U') IS NOT NULL
DROP TABLE stg.LossYearReport_Input;
BEGIN
CREATE TABLE stg.LossYearReport_Input (
	 OdsCustomerId INT NOT NULL
	,BillIDNo INT NULL
	,LINE_NO INT NULL
	,LineType INT NULL
	,CMT_HDR_IDNo INT NULL
	,ClaimIDNo INT NULL
	,CmtIDNo INT NULL
	,DateLoss DATETIME NULL
	,CreateDate DATETIME NULL
	,AnchorDate DATETIME NULL
	,AnchorDateQuarter DATETIME NULL
	,OfficeId INT NULL
	,PvdZOS VARCHAR(12) NULL
	,[State] VARCHAR(10) NULL
	,County VARCHAR(50) NULL
	,TypeOfBill VARCHAR(4) NULL
	,BillTypeDesc VARCHAR(max) NULL
	,CV_Code VARCHAR(2) NULL
	,Form_Type VARCHAR(12) NULL
	,Migrated INT NULL
	,AdmissionDate DATETIME NULL
	,DischargeDate DATETIME NULL
	,CmtDOB DATETIME NULL
	,CmtSEX VARCHAR(2) NULL
	,CmtSOJ VARCHAR(2) NULL
	,CmtState VARCHAR(2) NULL
	,CmtCounty VARCHAR(50) NULL
	,CmtZip VARCHAR(12) NULL
	,CompanyName VARCHAR(50) NULL
	,PRC_CD VARCHAR(20) NULL
	,POS_RevCode VARCHAR(20) NULL
	,POSDesc VARCHAR(255) NULL
	,DT_SVC DATETIME NULL
	,PvdIDNo INT NULL
	,PvdZip VARCHAR(12) NULL
	,PvdSPC_List VARCHAR(50) NULL
	,PvdTitle VARCHAR(5) NULL
	,Cmt_Allowed Money NULL
	,CHARGED money NULL
	,ALLOWED money NULL
	,UNITS real NULL
	,DX VARCHAR(10) NULL
	,DX_SeqNum SMALLINT NULL
	,DX_IcdVersion tinyINT NULL
	,ICD VARCHAR(10) NULL
	,ICD_SeqNum SMALLINT NULL
	,ICD_IcdVersion tinyINT NULL
	,Period_Days INT NULL
	,Period VARCHAR(80) NULL
	,Age INT NULL
	,AgeGroup VARCHAR(50) NULL
	,Outlier_cat VARCHAR(100) NULL
	,Bill_Type VARCHAR(100) NULL
	,DX_Score float NULL
	,ER_Bill_Flag INT NULL
	,RevenueCodeCategoryId INT NULL
	,YOL INT NULL
	,ServiceGroup VARCHAR(500) NULL
	,Outlier INT NULL
	,InjuryNatureId INT NULL
	,EncounterTypeId INT NULL
	,RunDate DATETIME NOT NULL DEFAULT GETDATE()
	
)ON rpt_PartitionScheme(OdsCustomerId)
            WITH (
                 DATA_COMPRESSION = PAGE);
END
GO