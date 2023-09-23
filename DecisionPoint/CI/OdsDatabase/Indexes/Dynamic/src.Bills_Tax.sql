IF NOT EXISTS (
SELECT object_id
FROM sys.indexes
WHERE object_id = OBJECT_ID('src.Bills_Tax')
	AND NAME = 'IX_BillsTaxId_OdsCustomerId_OdsPostingGroupAuditId')
	
CREATE NONCLUSTERED INDEX IX_BillsTaxId_OdsCustomerId_OdsPostingGroupAuditId 
ON src.Bills_Tax (BillsTaxId, OdsCustomerId, OdsPostingGroupAuditId DESC)
WITH (DATA_COMPRESSION = PAGE);
GO

IF NOT EXISTS (
SELECT object_id
FROM sys.indexes
WHERE object_id = OBJECT_ID(N'src.Bills_Tax')
	AND NAME = N'IX_OdsPostingGroupAuditId_DmlOperation')

CREATE NONCLUSTERED INDEX IX_OdsPostingGroupAuditId_DmlOperation 
ON src.Bills_Tax(OdsPostingGroupAuditId DESC,DmlOperation ASC,OdsCustomerId)
INCLUDE (BillsTaxId);
GO

IF NOT EXISTS (
SELECT object_id
FROM sys.indexes
WHERE object_id = OBJECT_ID(N'src.Bills_Tax')
	AND NAME = N'IX_OdsCustomerId_OdsRowIsCurrent')
	
CREATE NONCLUSTERED INDEX IX_OdsCustomerId_OdsRowIsCurrent
ON src.Bills_Tax(OdsCustomerId,OdsRowIsCurrent)
INCLUDE (OdsPostingGroupAuditId,BillsTaxId);
GO

