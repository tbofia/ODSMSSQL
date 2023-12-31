IF OBJECT_ID('adm.Etl_GetProcessAuditId', 'P') IS NOT NULL
    DROP PROCEDURE adm.Etl_GetProcessAuditId
GO

CREATE PROCEDURE adm.Etl_GetProcessAuditId (
@ProcessId INT,
@ControlRowCount INT,
@TotalRecordsInSource BIGINT,
@CustomerId INT,
@IsSnapshot BIT,
@PostingGroupAuditId INT,
@DataExtractTypeId INT)
AS
BEGIN
--DECLARE @ProcessId INT=26,@ControlRowCount INT = 0,@CustomerId INT=1,@IsSnapshot BIT=1,@PostingGroupAuditId INT=6,@DataExtractTypeId INT=0
DECLARE  @FullLoadStatus INT 
		,@ProcessAuditId INT;
DECLARE @InsertedRecord TABLE(ProcessAuditId INT);

DECLARE @SourceServer VARCHAR(255) = (SELECT ServerName FROm adm.Customer WHERE CustomerId = @CustomerId)

-- Set Process FullLoadStatus
IF EXISTS(SELECT TOP 1 PA.ProcessId
FROM adm.ProcessAudit PA
INNER JOIN adm.PostingGroupAudit PGA
	ON PA.PostingGroupAuditId = PGA.PostingGroupAuditId 
INNER JOIN adm.Customer C
	ON PGA.CustomerId = C.CustomerId 
WHERE PA.ProcessId = @ProcessId
-- For snapshot Tables check that the table has not been loaded for the server in Question.
	AND CASE WHEN @IsSnapshot = 1 THEN C.ServerName ELSE CAST(C.CustomerId AS VARCHAR(5)) END = CASE WHEN @IsSnapshot = 1 THEN @SourceServer ELSE CAST(@CustomerId AS VARCHAR(5)) END 
	AND PGA.DataExtractTypeId = 0
	AND PA.Status = 'FI')

SET @FullLoadStatus = 1
ELSE SET @FullLoadStatus = 0

-- Get ProcessAuditId
SELECT TOP 1 @ProcessAuditId = ProcessAuditId 
FROM adm.ProcessAudit
WHERE ProcessId = @ProcessId
AND PostingGroupAuditId = @PostingGroupAuditId
AND Status = 'I';

IF @ProcessAuditId IS NULL
INSERT INTO adm.ProcessAudit WITH (TABLOCKX)(
       PostingGroupAuditId
      ,ProcessId
      ,Status
	  ,ControlRowCount
	  ,TotalRecordsInSource
      ,CreateDate
      ,LastChangeDate)
OUTPUT INSERTED.ProcessAuditId
INTO @InsertedRecord
VALUES (@PostingGroupAuditId,@ProcessId,'S',@ControlRowCount,@TotalRecordsInSource,GETDATE(),GETDATE())

SELECT COALESCE(ProcessAuditId,@ProcessAuditId,-1),@FullLoadStatus
FROM @InsertedRecord;

END
GO

