IF OBJECT_ID('src.SENTRY_RULE_ACTION_DETAIL', 'U') IS NULL 
	BEGIN
		CREATE TABLE src.SENTRY_RULE_ACTION_DETAIL
			(
			  OdsPostingGroupAuditId INT NOT NULL ,  
			  OdsCustomerId INT NOT NULL , 
			  OdsCreateDate DATETIME2(7) NOT NULL ,
			  OdsSnapshotDate DATETIME2(7) NOT NULL , 
			  OdsRowIsCurrent BIT NOT NULL ,
			  OdsHashbytesValue VARBINARY(8000) NULL ,
			  DmlOperation CHAR(1) NOT NULL ,  
			  RuleID INT NOT NULL ,
			  LineNumber INT NOT NULL ,
			  ActionID INT NULL ,
			  ActionValue VARCHAR (1000) NULL ,
 ) ON DP_Ods_PartitionScheme(OdsCustomerId) 
 WITH (
       DATA_COMPRESSION = PAGE); 

     ALTER TABLE src.SENTRY_RULE_ACTION_DETAIL ADD 
     CONSTRAINT PK_SENTRY_RULE_ACTION_DETAIL PRIMARY KEY CLUSTERED (OdsPostingGroupAuditId, OdsCustomerId, RuleID, LineNumber) WITH (DATA_COMPRESSION = PAGE) ON
     DP_Ods_PartitionScheme(OdsCustomerId);

     ALTER INDEX PK_SENTRY_RULE_ACTION_DETAIL ON src.SENTRY_RULE_ACTION_DETAIL   REBUILD WITH(STATISTICS_INCREMENTAL = ON); 
 END 
 GO
