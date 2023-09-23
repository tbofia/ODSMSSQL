IF OBJECT_ID('src.Tag', 'U') IS NULL
    BEGIN
        CREATE TABLE src.Tag
            (
              OdsPostingGroupAuditId INT NOT NULL ,
              OdsCustomerId INT NOT NULL ,
              OdsCreateDate DATETIME2(7) NOT NULL ,
              OdsSnapshotDate DATETIME2(7) NOT NULL ,
              OdsRowIsCurrent BIT NOT NULL ,
              OdsHashbytesValue VARBINARY(8000) NULL ,
              DmlOperation CHAR(1) NOT NULL ,
			  TagId int NOT NULL,
	          NAME varchar(50) NULL,
	          DateCreated datetimeoffset(7) NULL,
	          DateModified datetimeoffset(7) NULL,
	          CreatedBy varchar(15) NULL,
	          ModifiedBy varchar(15) NULL
	          
            )ON DP_Ods_PartitionScheme(OdsCustomerId)
            WITH (
                 DATA_COMPRESSION = PAGE);

        ALTER TABLE src.Tag ADD 
        CONSTRAINT PK_Tag PRIMARY KEY CLUSTERED (OdsPostingGroupAuditId, OdsCustomerId,TagId) WITH (DATA_COMPRESSION = PAGE) ON DP_Ods_PartitionScheme(OdsCustomerId);

		ALTER INDEX PK_Tag ON src.Tag REBUILD WITH(STATISTICS_INCREMENTAL = ON);

    END
GO

-- Update index for incremental statistics update
IF NOT EXISTS ( SELECT 	1
				FROM sys.stats
				WHERE name = 'PK_Tag'
				AND is_incremental = 1)
BEGIN
	ALTER INDEX PK_Tag ON src.Tag REBUILD WITH(STATISTICS_INCREMENTAL = ON);
END;
GO
