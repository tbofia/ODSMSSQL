IF OBJECT_ID('src.ny_Pharmacy', 'U') IS NULL
    BEGIN
        CREATE TABLE src.ny_Pharmacy
            (
              OdsPostingGroupAuditId INT NOT NULL ,
              OdsCustomerId INT NOT NULL ,
              OdsCreateDate DATETIME2(7) NOT NULL ,
              OdsSnapshotDate DATETIME2(7) NOT NULL ,
              OdsRowIsCurrent BIT NOT NULL ,
              OdsHashbytesValue VARBINARY(8000) NULL,
              DmlOperation CHAR(1) NOT NULL ,
              NDCCode VARCHAR(13) NOT NULL ,
              StartDate DATETIME NOT NULL ,
              EndDate DATETIME NULL ,
              Description VARCHAR(125) NULL ,
              Fee MONEY NOT NULL ,
              TypeOfDrug SMALLINT NOT NULL 
              
            )ON DP_Ods_PartitionScheme(OdsCustomerId)
            WITH (
                 DATA_COMPRESSION = PAGE);

        ALTER TABLE src.ny_Pharmacy ADD 
        CONSTRAINT PK_ny_Pharmacy PRIMARY KEY CLUSTERED (OdsPostingGroupAuditId, OdsCustomerId, NDCCode, StartDate, TypeOfDrug) WITH (DATA_COMPRESSION = PAGE) ON DP_Ods_PartitionScheme(OdsCustomerId);

		ALTER INDEX PK_ny_Pharmacy ON src.ny_Pharmacy REBUILD WITH(STATISTICS_INCREMENTAL = ON);

    END
GO

-- Update index for incremental statistics update
IF NOT EXISTS ( SELECT 	1
				FROM sys.stats
				WHERE name = 'PK_ny_Pharmacy'
				AND is_incremental = 1)
BEGIN
	ALTER INDEX PK_ny_Pharmacy ON src.ny_Pharmacy REBUILD WITH(STATISTICS_INCREMENTAL = ON);
END;
GO

