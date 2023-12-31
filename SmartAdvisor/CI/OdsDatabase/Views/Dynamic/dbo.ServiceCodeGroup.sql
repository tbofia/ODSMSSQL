IF OBJECT_ID('dbo.ServiceCodeGroup', 'V') IS NOT NULL
    DROP VIEW dbo.ServiceCodeGroup;
GO

CREATE VIEW dbo.ServiceCodeGroup
AS

SELECT 
	 OdsPostingGroupAuditId
	,OdsCustomerId
	,OdsCreateDate
	,OdsSnapshotDate
	,OdsRowIsCurrent
	,OdsHashbytesValue
	,DmlOperation
	,SiteCode
	,GroupType
	,Family
	,Revision
	,GroupCode
	,CodeOrder
	,ServiceCode
	,ServiceCodeType
	,LinkGroupType
	,LinkGroupFamily
	,CodeLevel
	,GlobalPriority
	,Active
	,Comment
	,CustomParameters
	,CreateDate
	,CreateUserID
	,ModDate
	,ModUserID
FROM src.ServiceCodeGroup
WHERE   OdsRowIsCurrent = 1
	AND DmlOperation <> 'D';
GO


