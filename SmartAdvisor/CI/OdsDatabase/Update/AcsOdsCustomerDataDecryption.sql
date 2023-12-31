--OPEN MASTER KEY DECRYPTION BY PASSWORD = 'SFclpwd2O18O1O2@ml';

OPEN SYMMETRIC KEY AcsOds_SymmetricKey
DECRYPTION BY CERTIFICATE AcsOds_Certificate;

SELECT TOP 1000 OdsPostingGroupAuditId
      ,OdsCustomerId
      ,S.ClaimIDNo
      ,CONVERT(VARCHAR, DecryptByKey(CONVERT(VARBINARY(MAX), S.ClaimNo, 2))) ClaimNo
	  ,S.ClaimNo

  FROM src.CLAIMS S
  INNER JOIN '<ImportTableName>' D
  ON S.ClaimIDNo = D.CLAIMIDNO
  WHERE  OdsCustomerId = 48


   -- Close the symmetric key
CLOSE SYMMETRIC KEY AcsOds_SymmetricKey;