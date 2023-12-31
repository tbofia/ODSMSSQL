IF OBJECT_ID('src.ExtractCat', 'U') IS NULL
    BEGIN
        CREATE TABLE src.ExtractCat
            (
              OdsPostingGroupAuditId INT NOT NULL ,
              OdsCustomerId INT NOT NULL ,
              OdsCreateDate DATETIME2(7) NOT NULL ,
              OdsSnapshotDate DATETIME2(7) NOT NULL ,
              OdsRowIsCurrent BIT NOT NULL ,
              OdsHashbytesValue VARBINARY(8000) NULL ,
              DmlOperation CHAR(1) NOT NULL ,
              CatIdNo INT NOT NULL ,
			  Description VARCHAR(50) NULL ,					  
            )ON DP_Ods_PartitionScheme(OdsCustomerId)
            WITH (
                 DATA_COMPRESSION = PAGE);

        ALTER TABLE src.ExtractCat ADD 
        CONSTRAINT PK_ExtractCat PRIMARY KEY CLUSTERED (OdsPostingGroupAuditId, OdsCustomerId, CatIdNo) WITH (DATA_COMPRESSION = PAGE) ON DP_Ods_PartitionScheme(OdsCustomerId);

		ALTER INDEX PK_ExtractCat ON src.ExtractCat REBUILD WITH(STATISTICS_INCREMENTAL = ON);

    END
GO
