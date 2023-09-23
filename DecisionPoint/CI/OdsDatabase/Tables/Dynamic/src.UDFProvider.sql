IF OBJECT_ID('src.UDFProvider', 'U') IS NULL
BEGIN
    CREATE TABLE src.UDFProvider
        (
          OdsPostingGroupAuditId INT NOT NULL ,
          OdsCustomerId INT NOT NULL ,
          OdsCreateDate DATETIME2(7) NOT NULL ,
          OdsSnapshotDate DATETIME2(7) NOT NULL ,
          OdsRowIsCurrent BIT NOT NULL ,
          OdsHashbytesValue VARBINARY(8000) NULL,
          DmlOperation CHAR(1) NOT NULL ,
          PvdIdNo INT NOT NULL ,
          UDFIdNo INT NOT NULL ,
          UDFValueText VARCHAR(255) NULL ,
          UDFValueDecimal DECIMAL(19, 4) NULL ,
          UDFValueDate DATETIME NULL 
        ) ON DP_Ods_PartitionScheme(OdsCustomerId)
        WITH (DATA_COMPRESSION = PAGE);

    ALTER TABLE src.UDFProvider ADD 
    CONSTRAINT PK_UDFProvider PRIMARY KEY CLUSTERED (OdsPostingGroupAuditId, OdsCustomerId, PvdIdNo, UDFIdNo) WITH (DATA_COMPRESSION = PAGE) ON DP_Ods_PartitionScheme(OdsCustomerId);

	ALTER INDEX PK_UDFProvider ON src.UDFProvider  REBUILD WITH(STATISTICS_INCREMENTAL = ON);

END
GO

IF EXISTS ( SELECT  *
            FROM    sys.columns c
                    INNER JOIN sys.types t ON c.user_type_id = t.user_type_id
            WHERE   c.object_id = OBJECT_ID(N'src.UDFProvider')
                    AND c.name = 'UDFValueDecimal'
                    AND NOT ( t.name = 'DECIMAL'
                              AND c.precision = 19 AND c.scale = 4
                            ) )
    BEGIN
        ALTER TABLE src.UDFProvider ALTER COLUMN UDFValueDecimal DECIMAL(19, 4) NULL;
    END;
GO

-- Update index for incremental statistics update
IF NOT EXISTS ( SELECT 	1
				FROM sys.stats
				WHERE name = 'PK_UDFProvider'
				AND is_incremental = 1)
BEGIN
	ALTER INDEX PK_UDFProvider ON src.UDFProvider  REBUILD WITH(STATISTICS_INCREMENTAL = ON);
END;
GO

