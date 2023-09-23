IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'dbo.AdjusterWorkspaceServiceRequest') AND type in (N'P', N'PC'))
DROP PROCEDURE dbo.AdjusterWorkspaceServiceRequest
GO

CREATE PROCEDURE dbo.AdjusterWorkspaceServiceRequest(
@Customer nvarchar(200))
AS
BEGIN
-- DECLARE @Customer nvarchar(200) = 'MMedical_AAAFL'
DECLARE @SQLScript VARCHAR(MAX);

SET @SQLScript = '
INSERT INTO dbo.AdjusterWorkspaceServiceRequestReport (
	Customer
	,Company
	,Office
	,SOJ
	,RequestedByUserName
	,DateTimeReceived
	,DemandClaimantId
	,DemandPackageId
	,DemandPackageRequestedServiceId
	,DemandPackageUploadedFileId
	,Size
	,FileName
	,FileCount
	,PageCount
	)
SELECT DCMNT.OrganizationId
	,ISNULL(CPNY.CompanyName, '' UNKNOWN '') Company
	,ISNULL(OFC.OfcName, '' UNKNOWN '') Office
	,CMNT.CmtStateOfJurisdiction SOJ
	,DP.RequestedByUserName Adjuster
	,CAST(DateTimeReceived AS DATE) DateReceived
	,DCMNT.DemandClaimantId
	,DP.DemandPackageId
	,DPRS.DemandPackageRequestedServiceId
	,DPF.DemandPackageUploadedFileId
	,DPF.Size
	,DPF.FileName
	,CASE WHEN DPF.DemandPackageUploadedFileId IS NULL THEN 0 ELSE 1 END
	,DP.PageCount
FROM '+@Customer+'.dm.DemandClaimant DCMNT
LEFT OUTER JOIN '+@Customer+'.dbo.CLAIMANT CMNT ON DCMNT.ExternalClaimantId = CMNT.CmtIDNo
INNER JOIN '+@Customer+'.dbo.CLAIMS CLM ON CLM.ClaimIDNo = CMNT.ClaimIDNo
INNER JOIN '+@Customer+'.dbo.prf_Office OFC ON OFC.CompanyId = CLM.CompanyID
	AND OFC.OfficeId = CLM.OfficeIndex
INNER JOIN '+@Customer+'.dbo.prf_COMPANY CPNY ON CPNY.CompanyId = OFC.CompanyId
INNER JOIN '+@Customer+'.dm.DemandPackage DP ON DCMNT.DemandClaimantId = DP.DemandClaimantId
INNER JOIN '+@Customer+'.dm.DemandPackageUploadedFile DPF ON DP.DemandPackageid = DPF.DemandPackageid
INNER JOIN '+@Customer+'.dm.DemandPackageRequestedService DPRS ON DPRS.DemandPackageId = DP.DemandPackageId; '
	
EXEC (@SQLScript);
              
END

GO

IF OBJECT_ID('rpt.CheckForQueuedPostingGroupRecords') IS NOT NULL
    DROP PROCEDURE rpt.CheckForQueuedPostingGroupRecords
GO

CREATE PROCEDURE rpt.CheckForQueuedPostingGroupRecords ( @PostingGroupId INT )
AS
BEGIN
    SET NOCOUNT ON

    DECLARE @PostingGroupAuditId INT = -1; 

-- Check to see if there are any queued records associated with this group
    SELECT TOP 1
            @PostingGroupAuditId = p.PostingGroupAuditId
    FROM    rpt.PostingGroupAudit p
            INNER JOIN rpt.ProcessAudit e ON p.PostingGroupAuditId = e.PostingGroupAuditId
    WHERE   p.PostingGroupId = @PostingGroupId
            AND e.STATUS <> 'FI'

    IF @PostingGroupAuditId = -1
        RAISERROR ('INFO: No queued posting group records exist.  Let''s create a new posting group.', 0, 1) WITH NOWAIT, LOG
    ELSE
        RAISERROR ('INFO: There are queued posting group records.  Let''s pick up from where we left off.', 0, 1) WITH NOWAIT, LOG

    SELECT  @PostingGroupAuditId AS PostingGroupAuditId

END
GO
IF OBJECT_ID('rpt.CreateDatabaseSnapshot') IS NOT NULL
    DROP PROCEDURE rpt.CreateDatabaseSnapshot
GO

CREATE PROCEDURE rpt.CreateDatabaseSnapshot
    (
      @DatabaseName VARCHAR(100) = NULL
    )
AS
BEGIN
    SET NOCOUNT ON

    DECLARE @DBSnapshotName VARCHAR(100) ,
        @SnapshotCreateDate DATETIME2 ,
        @Timestamp VARCHAR(14) ,
        @DBLogicalName VARCHAR(100) ,
        @DBPath VARCHAR(100) ,
        @Sql NVARCHAR(MAX) ,
        @SpExecuteSql NVARCHAR(MAX) ,
        @CurrentCTVersion BIGINT ,
        @DPAppVersion VARCHAR(10) ,
        @DPAppVersionId INT ,
        @DMAppVersion VARCHAR(10) ,
        @DMAppVersionId INT ,
        @MMedStaticDataVersionId INT ,
        @ErrMsg NVARCHAR(4000) ,
        @ErrSeverity INT ,
-- This is for you, Dustin...
        @CRLF NCHAR(2)	= CHAR(13) + CHAR(10) ,	-- Carriage Return + Line Feed
        @TB NCHAR(1)	= CHAR(9) ,		-- Tab character
        @SQ NCHAR(1)	= CHAR(39)		-- Single quote character

    SET @DatabaseName = ISNULL(@DatabaseName, DB_NAME());

    IF NOT EXISTS ( SELECT  1
                    FROM    sys.databases
                    WHERE   name = @DatabaseName )
        RAISERROR ('@DatabaseName does not exist on this server.  Aborting.', 16, 1) WITH LOG

-- Now, let's create the SQL to create our snapshot
    SET @SnapshotCreateDate = GETDATE();
    SET @SnapshotCreateDate = DATEADD(ms, -DATEPART(ms, @SnapshotCreateDate), @SnapshotCreateDate); -- Remove milliseconds from date
    SET @Timestamp = CONVERT(VARCHAR(8), @SnapshotCreateDate, 112) + RIGHT('0' + CAST(DATEPART(hh, @SnapshotCreateDate) AS VARCHAR(2)), 2) + RIGHT('0' + CAST(DATEPART(mi, @SnapshotCreateDate) AS VARCHAR(2)), 2) + RIGHT('0' + CAST(DATEPART(ss, @SnapshotCreateDate) AS VARCHAR(2)), 2);
    SET @DBSnapshotName = @DatabaseName + '_' + @Timestamp;

	SET @Sql = 'CREATE DATABASE' + @CRLF
		  + @TB + '[' + @DBSnapshotName + ']' + @CRLF
		  + 'ON' 

	SELECT
		@Sql += 
		  +	CASE WHEN y.FileSequence = 1
				THEN @TB
				ELSE ' ,' + @TB
				END
		  +	'(   ' + 'NAME = [' + y.LogicalFileName + ']' 
		  +	'  ,  FILENAME = ' + @SQ + y.SnapshotFileName + @SQ 
		  +	'  )' + @CRLF
	FROM
		(
		SELECT
			SnapshotFileName ,
			LogicalFileName ,
			FileSequence 
		FROM
			(
			SELECT	REVERSE(SUBSTRING(REVERSE(mf.physical_name), CHARINDEX('\', REVERSE(mf.physical_name)), 520)) + mf.name + '_' + @Timestamp + '.ss' AS SnapshotFileName ,
				mf.name AS LogicalFileName ,
				RANK() OVER (ORDER BY mf.name) AS FileSequence
			FROM	sys.master_files mf
			INNER JOIN sys.databases d ON mf.database_id = d.database_id
			WHERE     d.NAME = @DatabaseName
			AND	mf.type = 0
			) x
		) y
	;

	SET @Sql += 
		  + 'AS SNAPSHOT OF' + @CRLF
		  + @TB + '[' + @DatabaseName + ']' + @CRLF
		  + ';' + @CRLF
	;

-- Now let's create the snapshot
    BEGIN TRY
        EXEC (@Sql);

-- Assuming the snapshot was created successfully, we're going to query it for info we'll need to produce our
-- data extracts.  
        SET @SpExecuteSql = @DbSnapshotName + '.sys.sp_executesql' -- This allows me to make calls on our snapshot without changing the db context

-- Get @CurrentCTVersion
        EXEC @SpExecuteSql N'SELECT @CurrentCTVersion = CHANGE_TRACKING_CURRENT_VERSION()', N'@CurrentCTVersion BIGINT OUTPUT', @CurrentCTVersion = @CurrentCTVersion OUTPUT

-- Get @DPAppVersion, @DPAppVersionId
        EXEC @SpExecuteSql N'SELECT TOP 1  @DPAppVersion = AppVersion, @DPAppVersionId = AppVersionId FROM dbo.AppVersion WHERE AppVersion IS NOT NULL ORDER BY AppVersionId DESC', N'@DPAppVersion VARCHAR(10) OUTPUT, @DPAppVersionId INT OUTPUT', @DPAppVersion = @DPAppVersion OUTPUT, @DPAppVersionId = @DPAppVersionId OUTPUT

-- Get @MMedStaticDataVersionId
        EXEC @SpExecuteSql N'SELECT TOP 1  @MMedStaticDataVersionId = AppVersionId FROM dbo.MMedStaticDataAppVersion WHERE DataUpdateVersion IS NOT NULL ORDER BY AppVersionId DESC', N'@MMedStaticDataVersionId INT OUTPUT', @MMedStaticDataVersionId = @MMedStaticDataVersionId OUTPUT

-- Get @DMAppVersion, @DMAppVersionId, if they exist
        EXEC @SpExecuteSql N'IF OBJECT_ID(''dm.AppVersion'', ''U'') IS NOT NULL
SELECT TOP 1  @DMAppVersion = AppVersion, @DMAppVersionId = AppVersionId FROM dm.AppVersion WHERE AppVersion IS NOT NULL ORDER BY AppVersionId DESC
ELSE IF OBJECT_ID(''aw.AppVersion'', ''U'') IS NOT NULL
SELECT TOP 1  @DMAppVersion = AppVersion, @DMAppVersionId = AppVersionId FROM aw.AppVersion WHERE AppVersion IS NOT NULL ORDER BY AppVersionId DESC', N'@DMAppVersion VARCHAR(10) OUTPUT, @DMAppVersionId INT OUTPUT', @DMAppVersion = @DMAppVersion OUTPUT, @DMAppVersionId = @DMAppVersionId OUTPUT

-- Return info about newly created snapshot to client
        SELECT  @DBSnapshotName AS DBSnapshotName ,
                @CurrentCTVersion AS CurrentCTVersion ,
                @DPAppVersion AS DpAppVersion ,
                @SnapshotCreateDate AS SnapshotCreateDate ,
                @@SERVERNAME AS DBSnapshotServer ,
                @DPAppVersionId AS DpAppVersionId ,
                @MMedStaticDataVersionId AS MMedStaticDataVersionId ,
				@DMAppVersion AS DMAppVersion ,
				@DMAppVersionId AS DMAppVersionId

    END TRY

    BEGIN CATCH
        IF XACT_STATE() <> 0
            ROLLBACK TRANSACTION

        SELECT  @ErrMsg = ERROR_MESSAGE() ,
                @ErrSeverity = ERROR_SEVERITY()

		-- Drop the snapshot (it won't rollback with the transaction); if something failed at this step, 
		-- we don't want it hanging around since we'll have to recreate the snapshot anyway.
        EXEC ('DROP DATABASE ' + @DBSnapshotName + ';');

        RAISERROR (@ErrMsg, @ErrSeverity, 1) WITH LOG

        RETURN
    END CATCH
END
GO
IF OBJECT_ID('rpt.DropDatabaseSnapshot') IS NOT NULL
    DROP PROCEDURE rpt.DropDatabaseSnapshot
GO

CREATE PROCEDURE rpt.DropDatabaseSnapshot    (
@DBSnapshotName VARCHAR(100)  )
AS
BEGIN
-- DECLARE  @DBSnapshotName VARCHAR(100) = ''
    SET NOCOUNT ON

	IF EXISTS(SELECT  1
                    FROM    sys.databases
                    WHERE   name = @DBSnapshotName)
    EXEC ('DROP DATABASE ' + @DBSnapshotName + ';');

END
GO
IF OBJECT_ID('rpt.GenerateControlFile') IS NOT NULL
    DROP PROCEDURE rpt.GenerateControlFile
GO

CREATE PROCEDURE rpt.GenerateControlFile
    (
      @PostingGroupAuditId INT,
      @OutputPath Varchar(200)

    )
AS
BEGIN
    SET NOCOUNT ON
	
    DECLARE @SourceQuery VARCHAR(MAX) ,
        @FileName VARCHAR(100) ,
        @FileExtension VARCHAR(4) = 'ctl' ,
        @FileColumnDelimiter VARCHAR(2) = ',' ,
        @AcsOdsVersion VARCHAR(10) ,
		@DatabaseName VARCHAR(100) = DB_NAME()


 SELECT		@FileName = pga.DBSnapshotName + '_' + RIGHT('0000000000' + CAST(PostingGroupAuditId AS VARCHAR(10)), 10) + '_' +
			det.DataExtractTypeCode ,
			@AcsOdsVersion = pga.AcsOdsVersion
    FROM    rpt.PostingGroupAudit pga
            INNER JOIN rpt.PostingGroup pg ON pga.PostingGroupId = pg.PostingGroupId
			INNER JOIN rpt.DataExtractType det ON pga.DataExtractTypeId = det.DataExtractTypeId
    WHERE   pga.PostingGroupAuditId = @PostingGroupAuditId;
	
	

    SET @SourceQuery = 'SELECT ''' + @FileName + '.ctl'+ '''  ,pga.PostingGroupAuditId,pga.SnapshotCreateDate, pga.DBSnapshotName + ''_'' + p.BaseFileName + ''.txt'' AS FileName ,p.BaseFileName,
            psa.TotalRowsAffected,pa.TotalRowCount, ''' + @AcsOdsVersion + '''
    FROM    ' + @DatabaseName + '.rpt.ProcessStepAudit psa
            INNER JOIN ' + @DatabaseName + '.rpt.ProcessAudit pa ON psa.ProcessAuditId = pa.ProcessAuditId
            INNER JOIN ' + @DatabaseName + '.rpt.Process p ON pa.ProcessId = p.ProcessId
            INNER JOIN ' + @DatabaseName + '.rpt.PostingGroupAudit pga ON pa.PostingGroupAuditId = pga.PostingGroupAuditId 
    WHERE   pga.PostingGroupAuditId = ' + CAST(@PostingGroupAuditId AS VARCHAR(10));    

    EXEC rpt.GenerateDataExtract @SourceQuery = @SourceQuery, @OutputPath = @OutputPath, @FileName = @FileName, @FileExtension = @FileExtension, @FileColumnDelimiter = @FileColumnDelimiter

END
GO
 IF OBJECT_ID('rpt.GenerateDataExtract') IS NOT NULL
    DROP PROCEDURE rpt.GenerateDataExtract
GO

CREATE PROCEDURE rpt.GenerateDataExtract  (
@ProcessStepId INT  = NULL,
@SourceQuery VARCHAR(MAX) ,
@OutputPath VARCHAR(100) ,
@FileName VARCHAR(100) ,
@FileExtension VARCHAR(4) ,
@FileColumnDelimiter VARCHAR(2),
@DBSnapshotName VARCHAR(100) = NULL)
AS
BEGIN
    SET NOCOUNT ON

    DECLARE @BcpCommand VARCHAR(8000) , -- xp_cmdshell limitation!
        @TotalRowsAffected INT = 0,
		@SQLScriptSP NVARCHAR(MAX) = '',
		@BaseFileName VARCHAR(100),
		@TableSchema VARCHAR(50),
		@TotalRowCount BIGINT;

    CREATE TABLE #CommandPromptOutput
        (
          CommandPromptOutputId INT IDENTITY(1, 1) PRIMARY KEY CLUSTERED ,
          ResultText VARCHAR(MAX)
        );

    CREATE TABLE #ErrorWhiteList
        (
          CommandPromptOutputId INT
        );

-- Get Table or View name
	SELECT 	@BaseFileName = P.BaseFileName
	FROM rpt.ProcessStep ps
	INNER JOIN rpt.Process P ON ps.ProcessId = P.ProcessId
	WHERE ps.ProcessStepId = @ProcessStepId

-- Let's add a backslash if we don't have one.
    IF SUBSTRING(REVERSE(@OutputPath), 1, 1) <> '\'
        SET @OutputPath = @OutputPath + '\';

-- Let's build our bcp command
    SET @BcpCommand = 'bcp "' + REPLACE(REPLACE(@SourceQuery, CHAR(13), ' '), CHAR(10), ' ') + -- newlines are causing issues for bcp
        '" queryout ' + @OutputPath + @FileName + '.' + @FileExtension + ' -c -t "' + @FileColumnDelimiter + '" -S ' + @@SERVERNAME + ' -T';

-- Now, we're going to execute the bcp command via the cmdshell, save the results to #CommandPromptOutput,
-- then look for errors and total row count.
    BEGIN TRY
        INSERT  INTO #CommandPromptOutput
                EXEC master.sys.xp_cmdshell @BcpCommand;

-- MSSQL 2012 is throwing an error when it encounters certain warnings, which is throwing off our error
-- handling below.  Let's remove these if we run into them.
-- First, let's collect the lines that have the warnings we want to suppress
        INSERT  INTO #ErrorWhiteList
                ( CommandPromptOutputId
                )
                SELECT  CommandPromptOutputId
                FROM    #CommandPromptOutput
                WHERE   ResultText LIKE 'Error%Warning: BCP import with a format file will convert empty strings in delimited columns to NULL%'

-- Now remove them from our command prompt output; we have to also remove the previous lines (which contain the error number)
        DELETE  FROM a
        FROM    #CommandPromptOutput a
                INNER JOIN ( SELECT CommandPromptOutputId - 1 AS CommandPromptOutputId -- Previous line (containing error number)
                             FROM   #ErrorWhiteList
                             UNION ALL
                             SELECT CommandPromptOutputId -- Error description
                             FROM   #ErrorWhiteList ) b ON a.CommandPromptOutputId = b.CommandPromptOutputId;

-- Did we run into any issues on the bcp?
        IF EXISTS ( SELECT  1
                    FROM    #CommandPromptOutput
                    WHERE   ResultText LIKE '%Error%' )
            BEGIN
                RAISERROR ('There is a problem with our bcp command!', 16, 1)
            END

        SELECT  @TotalRowsAffected = CAST(ISNULL(SUBSTRING(ResultText, 1, PATINDEX('%rows copied.%', ResultText) - 1), '0') AS INT)
        FROM    #CommandPromptOutput
        WHERE   ResultText LIKE '%rows copied.%';

-- Get Total Records in source table, will be used to control total records in target table in the ods
		SET @TableSchema =(SELECT TABLE_SCHEMA FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_TYPE IN ('BASE TABLE') AND TABLE_NAME = @BaseFileName);
		IF  @TableSchema IS NOT NULL
			SET @SQLScriptSP = '
			BEGIN TRY
				SELECT @TotalRowCount = COUNT(1) FROM '+@DBSnapshotName+'.'+@TableSchema+'.'+@BaseFileName+'
			END TRY
			BEGIN CATCH
				SELECT @TotalRowCount = 0
			END CATCH'
		ELSE
		BEGIN  
			SET @TableSchema =(SELECT TABLE_SCHEMA FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_TYPE IN ('VIEW') AND TABLE_NAME = @BaseFileName);
			IF  @TableSchema IS NOT NULL
				SET @SQLScriptSP = '
				BEGIN TRY
					SELECT @TotalRowCount = COUNT(1) FROM '+@DBSnapshotName+'.'+@TableSchema+'.'+@BaseFileName+'
				END TRY
				BEGIN CATCH
					SELECT @TotalRowCount = 0
				END CATCH'
			ELSE 
				SET @SQLScriptSP = 'SELECT @TotalRowCount = 0'
		END 

		EXEC sp_executesql @SQLScriptSP,N'@TotalRowCount BIGINT OUT',@TotalRowCount OUT;

        SELECT  @TotalRowsAffected AS TotalRowsAffected,@TotalRowCount AS TotalRowCount;


    END TRY

    BEGIN CATCH
        IF XACT_STATE() <> 0
            ROLLBACK TRANSACTION

        DECLARE @ErrMsg NVARCHAR(4000) ,
            @ErrSeverity INT

        SELECT  @ErrMsg = ERROR_MESSAGE() ,
                @ErrSeverity = ERROR_SEVERITY()

        SELECT  @ErrMsg += '; ' + ResultText
        FROM    #CommandPromptOutput
        WHERE   ResultText LIKE '%Error%'
        ORDER BY CommandPromptOutputId;

        RAISERROR (@ErrMsg, @ErrSeverity, 1) WITH LOG

        RETURN
    END CATCH

END
GO
IF OBJECT_ID('rpt.GetDataExtractInformation') IS NOT NULL
    DROP PROCEDURE rpt.GetDataExtractInformation
GO

CREATE PROCEDURE rpt.GetDataExtractInformation ( @ProcessAuditId INT )
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @ProcessStepAuditId INT ,
        @NextStatus VARCHAR(2)

-- Let's get the next step associated with this process
    SELECT TOP 1
            @ProcessStepAuditId = psa.ProcessStepAuditId
    FROM    rpt.ProcessStep ps
            INNER JOIN rpt.Process p ON ps.ProcessId = p.ProcessId
            INNER JOIN rpt.ProcessStepAudit psa ON ps.ProcessStepId = psa.ProcessStepId
            INNER JOIN rpt.ProcessAudit pa ON psa.ProcessAuditId = pa.ProcessAuditId
            INNER JOIN rpt.PostingGroupAudit pga ON pa.PostingGroupAuditId = pga.PostingGroupAuditId
    WHERE   psa.ProcessAuditId = @ProcessAuditId
            AND psa.CompleteDate IS NULL
    ORDER BY psa.ProcessStepAuditId;

-- Let's make sure we've found the ETL meta data
    IF @@ROWCOUNT = 0
        BEGIN
            RAISERROR ('Oh, oh.  Something went wrong when I tried to look up the ETL meta data.  Aborting.', 16, 1);
            RETURN;
        END

---- Let's find out if there's a subsequent step so we can update ProcessAudit.Status when complete
    SELECT TOP 1
            @NextStatus = RIGHT('00' + CAST(ps.Priority AS VARCHAR(2)), 2)
    FROM    rpt.ProcessStep ps
            INNER JOIN rpt.ProcessStepAudit psa ON ps.ProcessStepId = psa.ProcessStepId
    WHERE   psa.ProcessAuditId = @ProcessAuditId
            AND psa.CompleteDate IS NULL
            AND psa.ProcessStepAuditId > @ProcessStepAuditId
    ORDER BY ProcessStepAuditId;

    SET @NextStatus = ISNULL(@NextStatus, 'FI');

-- Let's return info about this step to the client
    SELECT  psa.ProcessStepAuditId ,
	-- If this isn't a full load, let's see if any data has changed by looking at our checkpoints in ProcessStepAudit.
	-- If no data has changed, then make this NULL
            ISNULL(CASE WHEN det.IsFullExtract = 0
                      AND psa.PreviousCheckpoint = psa.CurrentCheckpoint THEN NULL
                 ELSE
	-- Otherwise, we're getting the SourceQuery from ProcessStep.FullSql or ProcessStep.IncrementalSql.
	-- There are a couple of keywords that get replaced in the SQL string:
	--		~SNAPSHOT~ - Name of the database snapshot that's being used to generate the data extract.
	--		~PREVIOUSCTVERSION~ - For tables with change tracking enabled, this tells us where the last run left off.
                      REPLACE(REPLACE(CASE WHEN det.IsFullExtract = 1
                                                OR p.IsSnapshot = 1 THEN ps.FullSql
                                           ELSE ps.IncrementalSql
                                      END, '~SNAPSHOT~', pga.DBSnapshotName), '~PREVIOUSCTVERSION~', ISNULL(psa.PreviousCheckpoint, '0'))
            END, 'SELECT 1 FROM sys.databases WHERE 0 = 1') AS SourceQuery , -- If NULL, then we'll create a dummy query that can run anywhere on the server to create a file with no rows.
            pga.DBSnapshotName + '_' + p.BaseFileName AS FileName ,
            p.FileExtension ,
            @NextStatus AS NextStatus ,
            pga.DBSnapshotServer ,
            pga.DBSnapshotName ,
			p.FileColumnDelimiter,
			ps.ProcessStepId
    FROM    rpt.ProcessStep ps
            INNER JOIN rpt.Process p ON ps.ProcessId = p.ProcessId
            INNER JOIN rpt.ProcessStepAudit psa ON ps.ProcessStepId = psa.ProcessStepId
            INNER JOIN rpt.ProcessAudit pa ON psa.ProcessAuditId = pa.ProcessAuditId
            INNER JOIN rpt.PostingGroupAudit pga ON pa.PostingGroupAuditId = pga.PostingGroupAuditId
			INNER JOIN rpt.DataExtractType det ON pga.DataExtractTypeId = det.DataExtractTypeId
    WHERE   psa.ProcessStepAuditId = @ProcessStepAuditId;

END
GO
IF OBJECT_ID('rpt.GetProcessAuditIdFromQueue') IS NOT NULL
    DROP PROCEDURE rpt.GetProcessAuditIdFromQueue
GO

CREATE PROCEDURE rpt.GetProcessAuditIdFromQueue
    (
      @PostingGroupAuditId INT
    )
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    DECLARE @ProcessAuditId INT = -1; 

    BEGIN TRANSACTION

    SELECT TOP 1
            @ProcessAuditId = pa.ProcessAuditId
    FROM    rpt.ProcessAudit pa WITH ( UPDLOCK, ROWLOCK, READPAST )
    WHERE   pa.Status NOT IN ( 'FI', 'ER' )
            AND pa.Status NOT LIKE 'P%'
            AND pa.PostingGroupAuditId = @PostingGroupAuditId
    ORDER BY pa.ProcessAuditId;
/*
-- Now that picking up the record from the queue is done separately from
-- gathering the data, we'll need to have a way to prevent another process from
-- grabbing the same record.  For now, I'll replace the first character of the Status
-- with an 'P' for Pending.
    IF ( @@ROWCOUNT > 0 )
        BEGIN
            UPDATE  rpt.ProcessAudit
            SET     Status = 'P' + SUBSTRING(Status, 2, LEN(Status))
            WHERE   ProcessAuditId = @ProcessAuditId;
        END
*/
    SELECT  @ProcessAuditId AS ProcessAuditId;

    COMMIT TRANSACTION
END
GO
IF OBJECT_ID('rpt.GetReplicaServerName') IS NOT NULL
    DROP PROCEDURE rpt.GetReplicaServerName
GO

CREATE PROCEDURE rpt.GetReplicaServerName
    (
      @DatabaseName VARCHAR(100) = NULL
    )
AS
BEGIN

	-- If an AlwaysOn AG exists for this database, let's use
	-- one of the secondary replicas as the source of our
	-- data extracts.  If not, we'll just use the current server.

	SET @DatabaseName = ISNULL(@DatabaseName, DB_NAME());

    IF NOT EXISTS ( SELECT  1
                    FROM    sys.databases
                    WHERE   name = @DatabaseName )
        RAISERROR ('@DatabaseName does not exist on this server.  Aborting.', 16, 1) WITH LOG

	-- By default, use the current server
    DECLARE @ReplicaServerName SYSNAME = @@SERVERNAME;

    IF SERVERPROPERTY('IsHadrEnabled') = 1
        BEGIN
		-- Get the name of the first secondary replica (by replica_id)
            SELECT TOP 1
                    @ReplicaServerName = rcs.replica_server_name
            FROM    sys.availability_groups_cluster agc
                    INNER JOIN sys.dm_hadr_availability_replica_cluster_states rcs ON rcs.group_id = agc.group_id
                    INNER JOIN sys.dm_hadr_availability_replica_states ars ON ars.replica_id = rcs.replica_id
            WHERE   ars.role = 2 -- SECONDARY
                    AND ars.connected_state = 1 -- CONNECTED
                    AND ars.synchronization_health = 2 -- HEALTHY
			-- Make sure that this database is part of the AG cluster
                    AND EXISTS ( SELECT 1
                                 FROM   sys.dm_hadr_availability_replica_states ars1
                                        INNER JOIN sys.databases d ON ars1.replica_id = d.replica_id
                                 WHERE  d.NAME = @DatabaseName
                                        AND ars1.role = 1 -- PRIMARY
                                        AND ars.group_id = ars1.group_id )
            ORDER BY rcs.replica_id;
        END

    SELECT  @ReplicaServerName AS ReplicaServerName;
END
GO
IF OBJECT_ID('rpt.IsSnapshotStillInUse') IS NOT NULL
    DROP PROCEDURE rpt.IsSnapshotStillInUse
GO

CREATE PROCEDURE rpt.IsSnapshotStillInUse
    (
      @PostingGroupAuditId INT 
    )
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @DropSnapshot BIT = 0;

-- Are there any more items in the queue for this posting group?  If not,
-- let's signal that the snapshot can be dropped.
    IF NOT EXISTS ( SELECT TOP 1
                            PostingGroupAuditId
                    FROM    rpt.ProcessAudit
                    WHERE   PostingGroupAuditId = @PostingGroupAuditId
                            AND Status <> 'FI' )
        BEGIN
            SET @DropSnapshot = 1
            UPDATE  rpt.PostingGroupAudit
            SET     Status = 'FI' ,
                    SnapshotDropDate = GETDATE() ,
                    LastChangeDate = GETDATE()
            WHERE   PostingGroupAuditId = @PostingGroupAuditId;
        END

    SELECT  @DropSnapshot AS DropSnapshot;
END
GO

IF OBJECT_ID('rpt.QueuePostingGroup') IS NOT NULL
    DROP PROCEDURE rpt.QueuePostingGroup
GO

CREATE PROCEDURE rpt.QueuePostingGroup
    (
      @PostingGroupId INT ,
      @CurrentCTVersion BIGINT ,
      @DBSnapshotName VARCHAR(100) ,
      @DBSnapshotServer VARCHAR(100) ,
      @DPAppVersion VARCHAR(10) ,
      @SnapshotCreateDate DATETIME2 ,
      @CurrentDPAppVersionId INT ,
      @CurrentMmedStaticDataVersionId INT ,
      @DataExtractTypeId TINYINT = 0 ,
      @DMAppVersion VARCHAR(10) = NULL ,
      @CurrentDMAppVersionId INT = NULL
    )
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @PostingGroupAuditId INT,
		@AcsOdsVersion VARCHAR(10),
		@IsFullExtract BIT,
		@FullLoadVersion VARCHAR(20),
		@IsFullExtractDifferential BIT,
		@LatestODSVersion VARCHAR(20)

-- When AppVersion is NULL or empty string , let's set this to '0.0'  (when no
-- value exists for AppVersion, SSIS is passing an empty string).  We're doing this
-- because we have rpt.ProcessStep records associated with version 0.0 of DemandManager
-- that will produce empty files if DemandManager doesn't exist.

    IF @DPAppVersion = '' OR @DPAppVersion IS NULL
        SET @DPAppVersion = '0.0';

    IF @DMAppVersion = '' OR @DMAppVersion IS NULL
        SET @DMAppVersion = '0.0';


-- Let's also store the version of the ODS. We'll pass this information along in the control files.
	SELECT TOP 1
		@AcsOdsVersion = AppVersion
	FROM    rpt.AppVersion
	ORDER BY AppVersionId DESC;

-- Get Top 2 level version numbers
	SELECT @LatestODSVersion = rpt.GetSubstringUpToNthOccurence(@AcsOdsVersion,'.',2)

    BEGIN TRY

        BEGIN TRANSACTION

		SELECT @IsFullExtract = IsFullExtract,
			   @FullLoadVersion = FullLoadVersion,
			   @IsFullExtractDifferential = ISNULL(IsFullLoadDifferential, 0)
		FROM rpt.DataExtractType 
		WHERE DataExtractTypeId = @DataExtractTypeId;

		-- Let's make sure we have a valid DataExtractTypeId
		IF @@ROWCOUNT = 0
        BEGIN
            RAISERROR ('DataExtractTypeId is invalid!', 16, 1);
			SELECT  0 AS PostingGroupAuditId;
			ROLLBACK TRANSACTION
            RETURN;
        END
-- If this is full load and there are no processes with the latest version then dont log any posting groups 
		IF @DataExtractTypeId = 1 AND @FullLoadVersion = '0.0' AND NOT EXISTS (SELECT TOP 1 ProcessId FROM rpt.Process WHERE MinODSVersion = @LatestODSVersion)
		BEGIN
			SELECT  0 AS PostingGroupAuditId;
			ROLLBACK TRANSACTION
			RETURN;
		END

        INSERT  INTO rpt.PostingGroupAudit
                ( PostingGroupId ,
                  DataExtractTypeId ,
                  Status ,
                  CurrentCTVersion ,
                  CurrentDPAppVersionId ,
                  CurrentMmedStaticDataVersionId ,
                  DBSnapshotName ,
                  DBSnapshotServer ,
                  DPAppVersion ,
                  SnapshotCreateDate ,
                  CreateDate ,
                  LastChangeDate ,
				  AcsOdsVersion ,
				  DMAppVersion ,
				  CurrentDMAppVersionId
			    )
                SELECT  @PostingGroupId ,
                        @DataExtractTypeId ,
                        '01' ,
                        @CurrentCTVersion ,
                        @CurrentDPAppVersionId ,
                        @CurrentMmedStaticDataVersionId ,
                        @DBSnapshotName ,
                        @DBSnapshotServer ,
                        @DPAppVersion ,
                        @SnapshotCreateDate ,
                        GETDATE() ,
                        GETDATE() ,
						@AcsOdsVersion,
						@DMAppVersion ,
						@CurrentDMAppVersionId;

        SET @PostingGroupAuditId = SCOPE_IDENTITY();

        INSERT  INTO rpt.ProcessAudit
                ( PostingGroupAuditId ,
                  ProcessId ,
                  STATUS ,
                  QueueDate ,
                  CreateDate ,
                  LastChangeDate
			    )
                SELECT  @PostingGroupAuditId ,
                        p.ProcessId ,
                        '01' ,
                        GETDATE() ,
                        GETDATE() ,
                        GETDATE()
                FROM    rpt.PostingGroup g
                        INNER JOIN rpt.PostingGroupProcess p ON g.PostingGroupid = p.PostingGroupId
						INNER JOIN rpt.Process p2 ON p.ProcessId = p2.ProcessId
                WHERE   g.PostingGroupId = @PostingGroupId
						AND (
							(@DataExtractTypeId = 1 AND ((@FullLoadVersion = '0.0' AND p2.MinODSVersion = @LatestODSVersion) 
														OR (@FullLoadVersion <> '0.0' AND @IsFullExtractDifferential = 1 AND CAST('/' + REPLACE(p2.MinODSVersion,'.','.1') + '/' AS HIERARCHYID) >= CAST('/' + REPLACE(@FullLoadVersion,'.','.1') + '/' AS HIERARCHYID))
														OR (@FullLoadVersion <> '0.0' AND @IsFullExtractDifferential = 0 AND p2.MinODSVersion = @FullLoadVersion)))
							OR
							@DataExtractTypeId <> 1
						)
                ORDER BY p.Priority ,
                        p.ProcessId;                
				    	
        INSERT  INTO rpt.ProcessStepAudit
                ( ProcessAuditId ,
                  ProcessStepId ,
                  PreviousCheckpoint ,
                  CurrentCheckpoint ,
                  CreateDate ,
                  LastChangeDate
			    )
                SELECT  pa.ProcessAuditId ,
                        ec.ProcessStepId ,
                        ISNULL(cp.PreviousCheckpoint, 0) ,
						/** Current Checkpoint Logic **/
						-- If someone kicks off a full extract, and it isn't the initial extract, let's keep the old checkpoint.
						-- This way, the next incremental extract will include all changes since the last incremental.
                        CASE WHEN @IsFullExtract = 1
                                  AND ISNULL(cp.PreviousCheckpoint, 0) > 0 THEN ISNULL(cp.PreviousCheckpoint, 0)
						-- If the minimum application version is '0.0', then we want to keep the old checkpoint (which should be 0).
						-- These records will just dump out empty files, so we don't want to move forward until the customer upgrades
						-- to a supported version of the application (this doesn't apply to DP, which would just bomb out).
							 WHEN ec.MinAppVersion = '0.0' THEN ISNULL(cp.PreviousCheckpoint, 0)
						-- We've got several checkpoint types:
						-- 1) rpt.Process.IsSnapshot = 0: Change Tracking
						-- 2) rpt.Process.IsSnapshot = 1 AND rpt.Process.IsHimStatic = 0 AND rpt.Process.ProductKey = 'DemandManager' : DMAppVersionId
						-- 3) rpt.Process.IsSnapshot = 1 AND rpt.Process.IsHimStatic = 0 AND rpt.Process.ProductKey = 'DecisionPoint' : DPAppVersionId
						-- 4) rpt.Process.IsSnapshot = 1 AND rpt.Process.IsHimStatic = 1: MmedStaticDataVersionId
                             WHEN p.IsSnapshot = 0 THEN @CurrentCTVersion
                             WHEN p.IsSnapshot = 1
                                  AND p.IsHimStatic = 0 
								  AND p.ProductKey = 'DemandManager' THEN @CurrentDMAppVersionId
                             WHEN p.IsSnapshot = 1
                                  AND p.IsHimStatic = 0 
								  AND p.ProductKey = 'DecisionPoint'  THEN @CurrentDPAppVersionId
                             WHEN p.IsSnapshot = 1
                                  AND p.IsHimStatic = 1 THEN @CurrentMmedStaticDataVersionId
                             ELSE NULL
                        END ,
                        GETDATE() ,
                        GETDATE()
                FROM    rpt.ProcessAudit pa
                        INNER JOIN rpt.Process p ON pa.ProcessId = p.ProcessId
						-- Let's use the HIERARCHYID data type to compare application versions.
                        INNER JOIN ( SELECT ec1.ProcessId ,
                                            MAX(CAST('/' + ec1.MinAppVersion + '/' AS HIERARCHYID)) AS MinAppVersion
                                     FROM   rpt.ProcessStep ec1
									 INNER JOIN rpt.Process p1 ON ec1.ProcessId = p1.ProcessId
									 -- We want to get the greatest (relative to supported AppVersion) from ProcessStep records
									 -- that's less than or equal to our current product version.
									 WHERE CAST('/' + ec1.MinAppVersion + '/' AS HIERARCHYID) <= CAST('/' + CASE WHEN p1.ProductKey = 'DemandManager' THEN @DMAppVersion -- DemandManager AppVersion
																												WHEN p1.ProductKey = 'DecisionPoint' THEN @DPAppVersion -- DecisionPoint AppVersion
																											END + '/' AS HIERARCHYID)
                                     GROUP BY ec1.ProcessId ) a ON p.ProcessId = a.ProcessId
                        INNER JOIN rpt.ProcessStep ec ON a.ProcessId = ec.ProcessId
                                                         AND a.MinAppVersion = CAST('/' + ec.MinAppVersion + '/' AS HIERARCHYID)
                        LEFT OUTER JOIN rpt.ProcessCheckpoint cp ON p.ProcessId = cp.ProcessId
                WHERE   pa.PostingGroupAuditId = @PostingGroupAuditId
                ORDER BY ec.Priority ,
                        pa.ProcessAuditId;       

-- Let's make sure we've retrieved some ETL steps.
        IF @@ROWCOUNT = 0
            RAISERROR ('Insert into rpt.ProcessStep failed.  Are you sure the AppVersion is correct?', 16, 1) WITH LOG

        SELECT  @PostingGroupAuditId AS PostingGroupAuditId;

        COMMIT TRANSACTION

    END TRY

    BEGIN CATCH
        IF XACT_STATE() <> 0
            ROLLBACK TRANSACTION

        DECLARE @ErrMsg NVARCHAR(4000) ,
            @ErrSeverity INT

        SELECT  @ErrMsg = ERROR_MESSAGE() ,
                @ErrSeverity = ERROR_SEVERITY()

        RAISERROR (@ErrMsg, @ErrSeverity, 1) WITH LOG

        RETURN
    END CATCH

END
GO
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
IF OBJECT_ID('rpt.UpdateJobStatus') IS NOT NULL
    DROP PROCEDURE rpt.UpdateJobStatus
GO

CREATE PROCEDURE rpt.UpdateJobStatus
    (
      @ProcessAuditId INT ,
      @Status VARCHAR(2) ,
      @ProcessStepAuditId INT = -1 ,
      @TotalRowsAffected INT = 0 ,
	  @TotalRowCount BIGINT = 0

    )
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    DECLARE @PreviousCheckpoint BIGINT ,
        @ProcessId SMALLINT

    BEGIN TRANSACTION

-- Update rpt.ProcessAudit
    UPDATE  rpt.ProcessAudit
    SET     Status = @Status ,
            ExtractDate = CASE WHEN @Status = 'FI' THEN GETDATE()
                               ELSE NULL
                          END ,
			TotalRowCount = @TotalRowCount,
            LastChangeDate = GETDATE()
    WHERE   ProcessAuditId = @ProcessAuditId;

-- Update rpt.ProcessStepAudit, if info available
    IF @ProcessStepAuditId <> -1
        BEGIN
    -- Let's get the CurrentCheckpoint and ProcessId associated with this @ProcessStepAuditId
            SELECT  @PreviousCheckpoint = psa.CurrentCheckpoint ,
                    @ProcessId = pa.ProcessId
            FROM    rpt.ProcessAudit pa
                    INNER JOIN rpt.ProcessStepAudit psa ON pa.ProcessAuditId = psa.ProcessAuditId
            WHERE   psa.ProcessStepAuditId = @ProcessStepAuditId;

            IF EXISTS ( SELECT  1
                        FROM    rpt.ProcessCheckpoint
                        WHERE   ProcessId = @ProcessId )
                UPDATE  rpt.ProcessCheckpoint
                SET     PreviousCheckpoint = @PreviousCheckpoint ,
                        LastChangeDate = GETDATE()
                WHERE   ProcessId = @ProcessId
                        AND PreviousCheckpoint < @PreviousCheckpoint; -- Let's only update when checkpoint changes
            ELSE
                INSERT  INTO rpt.ProcessCheckpoint
                        ( ProcessId ,
                          PreviousCheckpoint ,
                          LastChangeDate
                        )
                VALUES  ( @ProcessId ,
                          @PreviousCheckpoint ,
                          GETDATE()
                        );

    -- Now, let's update rpt.ProcessStepAudit
            UPDATE  rpt.ProcessStepAudit
            SET     TotalRowsAffected = @TotalRowsAffected ,
                    CompleteDate = GETDATE() ,
                    LastChangeDate = GETDATE()
            WHERE   ProcessStepAuditId = @ProcessStepAuditId;
        END

    COMMIT TRANSACTION
END
GO
IF OBJECT_ID('rpt.CheckForQueuedPostingGroupRecords') IS NOT NULL
    DROP PROCEDURE rpt.CheckForQueuedPostingGroupRecords
GO

CREATE PROCEDURE rpt.CheckForQueuedPostingGroupRecords ( @PostingGroupId INT )
AS
BEGIN
    SET NOCOUNT ON

    DECLARE  @PostingGroupAuditId INT = -1
			,@DBSnapshotName VARCHAR(100); 

-- Check to see if there are any queued records associated with this group
    SELECT TOP 1
             @PostingGroupAuditId = p.PostingGroupAuditId
			,@DBSnapshotName = p.DBSnapshotName
    FROM    rpt.PostingGroupAudit p
            INNER JOIN rpt.ProcessAudit e ON p.PostingGroupAuditId = e.PostingGroupAuditId
    WHERE   p.PostingGroupId = @PostingGroupId
            AND e.STATUS = '01'
	ORDER BY p.PostingGroupAuditId DESC

	IF @PostingGroupAuditId <> -1 AND (NOT EXISTS(SELECT  1
												FROM    sys.databases
												WHERE   name = @DBSnapshotName))
	BEGIN
		EXEC rpt.SetIncompletePostingGroupAuditIdStatus @PostingGroupAuditId,@DBSnapshotName
		-- Reset to No incomplete Postinggroupauditids
		SET @PostingGroupAuditId = -1
	END

    IF @PostingGroupAuditId = -1
        RAISERROR ('INFO: No queued posting group records exist.  Let''s create a new posting group.', 0, 1) WITH NOWAIT, LOG
    ELSE
		RAISERROR ('INFO: There are queued posting group records.  Let''s pick up from where we left off.', 0, 1) WITH NOWAIT, LOG

    SELECT  @PostingGroupAuditId AS PostingGroupAuditId

END
GO
