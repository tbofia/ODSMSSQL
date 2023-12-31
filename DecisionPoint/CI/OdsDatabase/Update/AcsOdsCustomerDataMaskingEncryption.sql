 DECLARE @OdsCustomerid INT = 48;

-- Update Claimant Information
BEGIN TRANSACTION UpdateTrans
BEGIN TRY

UPDATE CMT
SET  CMT.CmtSSN = NULL
	,CMT.CmtLastName = NULL
	,CMT.CmtFirstName = NULL
	,CMT.CmtMI = NULL
	,CMT.CmtDOB = '01/01/'+CAST(YEAR(CmtDOB) AS VARCHAR(4))
	,CMT.CmtAddr1 = NULL
	,CMT.CmtAddr2 = NULL
	,CMT.CmtCity = NULL
	,CMT.CmtZip = LEFT(CmtZip,3)
	,CMT.CmtPhone = NULL
	,CMT.CmtPGFirstName = NULL
	,CMT.CmtPGLastName = NULL
FROM src.CLAIMANT CMT
INNER JOIN '<ImportTableName>' C 
ON C.ClaimIDNo = CMT.ClaimIDNo
WHERE CMT.OdsCustomerId = @OdsCustomerid;


-- Update Bill_Hdr
UPDATE BH
SET	 BH.AdmissionDate = NULL
	,BH.DischargeDate = NULL
	,BH.AmbulanceZipOfPickup = LEFT(BH.AmbulanceZipOfPickup,3)
FROM src.BILL_HDR BH
INNER JOIN src.CMT_HDR CH
ON BH.OdsCustomerId = CH.OdsCustomerId
AND BH.CMT_HDR_IDNo = CH.CMT_HDR_IDNo
INNER JOIN src.CLAIMANT CMT
ON CMT.OdsCustomerId = CH.OdsCustomerId
AND CMT.CmtIDNo = CH.CmtIDNo
INNER JOIN '<ImportTableName>' C 
ON  C.ClaimIDNo = CMT.ClaimIDNo
WHERE BH.OdsCustomerId = @OdsCustomerid;

-- Update PrePPOBillInfo
UPDATE PPO
SET	 PPO.AdmissionDate = NULL
	,PPO.DischargeDate = NULL
FROM src.PrePPOBillInfo PPO
INNER JOIN '<ImportTableName>' C 
ON PPO.ClaimIDNo = C.ClaimIDNo
AND PPO.ClaimNo = C.ClaimNo
WHERE PPO.OdsCustomerId = @OdsCustomerid;

-- Opens the symmetric key for use
OPEN SYMMETRIC KEY AcsOds_SymmetricKey
DECRYPTION BY CERTIFICATE AcsOds_Certificate;

--INSERT INTO ReportDB..OdsCustomerCLAIMS_Encrypted(
--	 OdsPostingGroupAuditId
--	,OdsCustomerId
--	,ClaimIDNo
--	,ClaimNo_Encrypted
--	,ClaimNo
--	,RunDate)
--SELECT C.OdsPostingGroupAuditId
--      ,C.OdsCustomerId
--      ,C.ClaimIDNo
--	  ,CONVERT(VARCHAR(MAX),CONVERT(VARBINARY(MAX),ENCRYPTBYKEY(KEY_GUID('AcsOds_SymmetricKey'),C.ClaimNo)),2)
--	  ,C.ClaimNo
--	  ,GETDATE()
--FROM AcsOds.src.CLAIMS C
--INNER JOIN '<ImportTableName>' C2 
--ON  C.ClaimIDNo = C2.ClaimIDNo
--WHERE C.OdsCustomerId = @OdsCustomerid;

-- Update Claims
UPDATE C
SET	 C.PolicyNumber = NULL
	,C.PolicyHoldersName = NULL
	,C.PolicyEffDate = NULL
	,C.ClaimNo = CONVERT(VARCHAR(MAX),CONVERT(VARBINARY(MAX),ENCRYPTBYKEY(KEY_GUID('AcsOds_SymmetricKey'),C.ClaimNo)),2)
FROM src.CLAIMS C 
INNER JOIN '<ImportTableName>' C2 
ON  C.ClaimIDNo = C2.ClaimIDNo
WHERE C.OdsCustomerId = @OdsCustomerid;

-- Closes the symmetric key
CLOSE SYMMETRIC KEY AcsOds_SymmetricKey;



COMMIT TRANSACTIOn UpdateTrans
END TRY
BEGIN CATCH
ROLLBACK TRANSACTION UpdateTrans
END CATCH
GO





