IF OBJECT_ID('src.BillAdjustment', 'U') IS NULL
    BEGIN
        CREATE TABLE src.BillAdjustment
            (
              OdsPostingGroupAuditId INT NOT NULL ,
              OdsCustomerId INT NOT NULL ,
              OdsCreateDate DATETIME2(7) NOT NULL ,
              OdsSnapshotDate DATETIME2(7) NOT NULL ,
              OdsRowIsCurrent BIT NOT NULL ,
              OdsHashbytesValue VARBINARY(8000) NULL ,
              DmlOperation CHAR(1) NOT NULL ,
              BillLineAdjustmentId BIGINT NOT NULL,
			  BillIdNo INT NULL ,
			  LineNumber INT NULL ,
			  Adjustment MONEY NULL ,
			  EndNote INT NULL ,
			  EndNoteTypeId INT NULL
            )ON DP_Ods_PartitionScheme(OdsCustomerId)
            WITH (
                 DATA_COMPRESSION = PAGE);

        ALTER TABLE src.BillAdjustment ADD 
        CONSTRAINT PK_BillAdjustment PRIMARY KEY CLUSTERED (OdsPostingGroupAuditId, OdsCustomerId, BillLineAdjustmentId) WITH (DATA_COMPRESSION = PAGE) ON DP_Ods_PartitionScheme(OdsCustomerId);

		ALTER INDEX PK_BillAdjustment ON src.BillAdjustment REBUILD WITH(STATISTICS_INCREMENTAL = ON);

    END
GO
