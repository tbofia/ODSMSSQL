IF OBJECT_ID('rpt.SetIncompletePostingGroupAuditIdStatus') IS NOT NULL
    DROP PROCEDURE rpt.SetIncompletePostingGroupAuditIdStatus
GO

CREATE PROCEDURE rpt.SetIncompletePostingGroupAuditIdStatus ( 
@PostingGroupAuditId INT, 
@DBSnapshotName VARCHAR(100))
AS
BEGIN
-- DECLARE @PostingGroupAuditId INT
    SET NOCOUNT ON

    DECLARE  @Status VARCHAR(2); 

	-- Check to see if there are any queued records associated with this group
    SELECT   @Status = p.Status
    FROM    rpt.PostingGroupAudit p
    WHERE   p.PostingGroupAuditId = @PostingGroupAuditId

	-- Set Status to Er... Error
	IF @Status <> 'FI'
	BEGIN
		UPDATE rpt.PostingGroupAudit
		SET Status = 'Er'
		WHERE PostingGroupAuditId = @PostingGroupAuditId;

		INSERT INTO rpt.PostingGroupAuditError
		VALUES(@PostingGroupAuditId,'DS','Snapshot[s] created for this postinggroupauditid no longer exist[s].',GETDATE());

		-- Reset Change Tracking checkpoint to last completed
		UPDATE pc
		SET    pc.PreviousCheckpoint = psa.PreviousCheckpoint
		FROM   rpt.ProcessCheckpoint pc
				INNER JOIN rpt.ProcessAudit pa ON pc.ProcessId = pa.ProcessId
				INNER JOIN rpt.ProcessStepAudit psa ON pa.ProcessAuditId = psa.ProcessAuditId
		WHERE  pa.PostingGroupAuditId = @PostingGroupAuditId;

		-- Attemp to drop snapshots in case one existed but not the other
		EXEC rpt.DropDatabaseSnapshot @DBSnapshotName
	END

END
GO
