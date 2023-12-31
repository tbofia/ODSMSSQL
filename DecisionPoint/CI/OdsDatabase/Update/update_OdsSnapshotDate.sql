DECLARE  @ProcessId INT
		,@TargetTableName VARCHAR(255)
		,@SQLScript VARCHAR(MAX);	

DECLARE csr_PostingGroupAuditId CURSOR FOR  
SELECT P.ProcessId
FROM  adm.Process P
WHERE P.ProcessId <=108 -- Just Make sure the tables have been deployed as of this version 1.2.0.0

OPEN csr_PostingGroupAuditId   
FETCH NEXT FROM csr_PostingGroupAuditId INTO @ProcessId

WHILE @@FETCH_STATUS = 0   
BEGIN

SET @TargetTableName = (SELECT TargetTableName FROM adm.Process WHERE ProcessId = @ProcessId);

SET @SQLScript  = 'UPDATE T 
SET T.OdsSnapshotDate = PGA.SnapshotCreateDate
FROM src.'+@TargetTableName+' T
INNER JOIN adm.PostingGroupAudit PGA
	ON T.OdsPostingGroupAuditId = PGA.PostingGroupAuditId
WHERE PGA.SnapshotCreateDate >= ''2016-10-26'' -- Update this with the actual date on which the bug was introduced.
	AND PGA.OdsVersion <> ''1.3.0.0'';
	
'

BEGIN TRANSACTION UpdateTrans
BEGIN TRY 
EXEC(@SQLScript)
COMMIT TRANSACTION UpdateTrans
END TRY
BEGIN CATCH
ROLLBACK TRANSACTION UpdateTrans
END CATCH


FETCH NEXT FROM csr_PostingGroupAuditId INTO @ProcessId

END

CLOSE csr_PostingGroupAuditId
DEALLOCATE csr_PostingGroupAuditId