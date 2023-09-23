IF OBJECT_ID('stg.IndustryComparison_ProviderTypeClient', 'U') IS NOT NULL
DROP TABLE stg.IndustryComparison_ProviderTypeClient
BEGIN
 CREATE TABLE stg.IndustryComparison_ProviderTypeClient(
	 ReportName Varchar(50) 
	,OdsCustomerID int
	,CoverageType Varchar(20)
	,FormType Varchar(20)
	,State Varchar(20)
	,County Varchar(50)
	,Year Int
	,Quarter Int
	,ProviderType Varchar(50)
	,TotalClaims Int
	,TotalClaimants Int
	,TotalCharged Money
	,TotalAllowed Money
	,TotalReductions Money
	,TotalBills Int
	,TotalUnits real
	,TotalLines Int
	)
END
GO
