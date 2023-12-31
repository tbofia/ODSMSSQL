USE [AcsOds]
GO
/****** Object:  StoredProcedure [adm].[Etl_UpdateTargetColumnsWithStaging]    Script Date: 4/6/2019 10:59:23 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO

ALTER PROCEDURE [adm].[Etl_UpdateTargetColumnsWithStaging] (
@CustomerId INT,
@SnapshotDate VARCHAR(50),
@OdsPostingGroupAuditId INT)
AS
BEGIN
-- DECLARE @CustomerId INT = 68, @SnapshotDate VARCHAR(50), @PostingGroupId INT = 1, @OdsPostingGroupAuditId INT = 23;

DECLARE  @ProcessId INT
		,@ProcessAuditId INT
		,@UpdateSQL NVARCHAR(MAX)
		,@JoinClause VARCHAR(MAX)
		,@TargetSchemaName CHAR(3)
		,@TargetTableName VARCHAR(255);

-- Check if all processes have been loaded	   
IF EXISTS (
SELECT 1
FROM stg.ETL_ControlFiles C
INNER JOIN adm.Process P ON C.TargetTableName = P.TargetTableName
LEFT OUTER JOIN adm.ProcessAudit PA ON P.ProcessId = PA.ProcessId
	AND PA.Status IN ('I','FI')
	AND PA.PostingGroupAuditId = @OdsPostingGroupAuditId
WHERE C.SnapshotDate = @SnapshotDate
HAVING COUNT(DISTINCT P.ProcessId) = COUNT(DISTINCT PA.ProcessId))

BEGIN

	--BEGIN TRANSACTION UpdateTrans
	BEGIN TRY 

	-- Get all Loaded Processes and their ProcessAuditids for update.
	DECLARE process_cursor CURSOR FOR  
	SELECT P.ProcessId, PA.ProcessAuditId
	FROM stg.ETL_ControlFiles C
	INNER JOIN adm.Process P ON C.TargetTableName = P.TargetTableName
	INNER JOIN adm.ProcessAudit PA ON P.ProcessId = PA.ProcessId
		AND PA.Status = 'I'
		AND PA.PostingGroupAuditId = @OdsPostingGroupAuditId
	WHERE C.SnapshotDate = @SnapshotDate;
	
	OPEN process_cursor ;  
	FETCH NEXT FROM process_cursor INTO @ProcessId,@ProcessAuditId;

	WHILE @@FETCH_STATUS = 0   
	BEGIN
	
	SET @TargetSchemaName= (SELECT TargetSchemaName FROM adm.Process WHERE ProcessId = @ProcessId)
	SET @TargetTableName = (SELECT TargetTableName FROM adm.Process WHERE ProcessId = @ProcessId)
	SET @JoinClause = NULL;
	 		
	SELECT @JoinClause =  COALESCE(@JoinClause+' AND ','')+'T.'+TargetColumnName+' = S.'+TargetColumnName
	FROM(
	SELECT DISTINCT I.COLUMN_NAME AS TargetColumnName
	FROM INFORMATION_SCHEMA.KEY_COLUMN_USAGE I
	INNER JOIN adm.Process P
		ON I.TABLE_NAME = P.TargetTableName
		AND OBJECTPROPERTY(OBJECT_ID(I.CONSTRAINT_SCHEMA + '.' + I.CONSTRAINT_NAME), 'IsPrimaryKey') = 1
		AND I.TABLE_SCHEMA = 'src'
	WHERE P.TargetTableName = @TargetTableName
		AND I.COLUMN_NAME NOT IN ('OdsPostingGroupAuditId')) AS T
		
	-- Build Update Script
	SET @UpdateSQL =
	'SET ROWCOUNT 50000'+CHAR(13)+CHAR(10)+
	'WHILE (1=1)'+CHAR(13)+CHAR(10)+
	'BEGIN'+CHAR(13)+CHAR(10)+
	'UPDATE T'+CHAR(13)+CHAR(10)+
	'SET T.OdsRowIsCurrent = CASE WHEN T.OdsPostingGroupAuditId = '+CAST(@OdsPostingGroupAuditId AS VARCHAR(20))+ ' THEN 1 ELSE 0 END'+CHAR(13)+CHAR(10)+
	'FROM '+@TargetSchemaName+'.'+@TargetTableName+' T'+CHAR(13)+CHAR(10)+
	'INNER JOIN '+@TargetSchemaName+'.'+@TargetTableName+' S'+CHAR(13)+CHAR(10)+
	'	ON '+@JoinClause+CHAR(13)+CHAR(10)+
	'	AND S.OdsPostingGroupAuditId = '+CAST(@OdsPostingGroupAuditId AS VARCHAR(20))+CHAR(13)+CHAR(10)+
	'   AND S.OdsRowIsCurrent = 0'+CHAR(13)+CHAR(10)+
	'WHERE T.OdsCustomerId = '+CAST(@CustomerId AS VARCHAR(3))+CHAR(13)+CHAR(10)+
	'AND ((T.OdsRowIsCurrent = 1 AND T.OdsPostingGroupAuditId <> '+CAST(@OdsPostingGroupAuditId AS VARCHAR(20))+') OR (T.OdsRowIsCurrent = 0 AND T.OdsPostingGroupAuditId = '+CAST(@OdsPostingGroupAuditId AS VARCHAR(20))+'));'+CHAR(13)+CHAR(10)+CHAR(13)+CHAR(10)+
	'IF @@ROWCOUNT = 0'+CHAR(13)+CHAR(10)+
	'BREAK'+CHAR(13)+CHAR(10)+
	'END'+CHAR(13)+CHAR(10)+
	'SET ROWCOUNT 0'	
	
	-- Execute Update Statement for current process
	EXEC(@UpdateSQL);
	-- Update adm.ProcessAudit Table with number of updated records
	UPDATE adm.ProcessAudit
	SET  Status = 'FI'
	 ,LastUpdateDate = GETDATE()
	 ,UpdateRowCount = @@ROWCOUNT
	 ,LastChangeDate = GETDATE()
	WHERE ProcessAuditId = @ProcessAuditId
	  
	FETCH NEXT FROM process_cursor INTO @ProcessId,@ProcessAuditId;
	END
	
	CLOSE process_cursor;   
	DEALLOCATE process_cursor;
		
	--COMMIT TRANSACTION UpdateTrans
	END TRY
	BEGIN CATCH
	--ROLLBACK TRANSACTION UpdateTrans
	RETURN
	END CATCH

END

END

