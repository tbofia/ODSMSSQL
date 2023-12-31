IF OBJECT_ID ('dbo.vwAdjustorWorkspaceServiceRequested', 'V') IS NOT NULL
DROP VIEW dbo.vwAdjustorWorkspaceServiceRequested;
GO
CREATE VIEW dbo.vwAdjustorWorkspaceServiceRequested
AS
SELECT DP.OdsCustomerId
      ,DP.Customer
      ,DP.Company
      ,DP.Office
      ,DP.SOJ
      ,DP.RequestedByUserName
      ,DP.DateTimeReceived
      ,DP.DemandClaimantId
      ,DP.DemandPackageId
      ,DP.Size
      ,DP.FileCount
      ,DP.PageCount
      ,SR.DemandPackageRequestedServiceId
      ,SR.DemandPackageRequestedServiceName
      ,SR.IsRush
      ,SR.IsSupplemental
      ,DP.RunDate
FROM dbo.AdjustorWorkspaceDemandPackage_Output DP
LEFT OUTER JOIN dbo.AdjustorWorkspaceServiceRequested_Output SR
ON DP.OdsCustomerId = SR.OdsCustomerId
AND DP.DemandPackageId = SR.DemandPackageId

GO
