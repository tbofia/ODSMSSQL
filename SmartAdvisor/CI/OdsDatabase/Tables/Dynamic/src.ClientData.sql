IF OBJECT_ID('src.ClientData', 'U') IS NULL 
	BEGIN
		CREATE TABLE src.ClientData
			(
			  OdsPostingGroupAuditId INT NOT NULL ,  
			  OdsCustomerId INT NOT NULL , 
			  OdsCreateDate DATETIME2(7) NOT NULL ,
			  OdsSnapshotDate DATETIME2(7) NOT NULL , 
			  OdsRowIsCurrent BIT NOT NULL ,
			  OdsHashbytesValue VARBINARY(8000) NULL ,
			  DmlOperation CHAR(1) NOT NULL ,  
			  ClientCode CHAR (4) NOT NULL ,
			  TypeCode CHAR (6) NOT NULL ,
			  SubType CHAR (12) NOT NULL ,
			  SubSeq SMALLINT NOT NULL ,
			  NumData NUMERIC (18,6) NULL ,
			  TextData VARCHAR (6000) NULL ,
			  CreateDate DATETIME NULL ,
			  CreateUserID CHAR (2) NULL ,
			  ModDate DATETIME NULL ,
			  ModUserID CHAR (2) NULL ,
 ) ON DP_Ods_PartitionScheme(OdsCustomerId) 
 WITH (
       DATA_COMPRESSION = PAGE); 

     ALTER TABLE src.ClientData ADD 
     CONSTRAINT PK_ClientData PRIMARY KEY CLUSTERED (OdsPostingGroupAuditId, OdsCustomerId, ClientCode, TypeCode, SubType, SubSeq) WITH (DATA_COMPRESSION = PAGE) ON
     DP_Ods_PartitionScheme(OdsCustomerId);

     ALTER INDEX PK_ClientData ON src.ClientData   REBUILD WITH(STATISTICS_INCREMENTAL = ON); 
 END 
 GO
