IF OBJECT_ID('dbo.DP_PerformanceReport_Output', 'U') IS NULL
BEGIN
CREATE TABLE dbo.DP_PerformanceReport_Output (
	 OdsCustomerId INT NOT NULL
	,StartOfMonth datetime NOT NULL
	,Customer nvarchar(200) NOT NULL
	,Year int NOT NULL
	,Month int NOT NULL
	,Company varchar(50) NOT NULL
	,Office varchar(40) NOT NULL
	,SOJ varchar(2) NOT NULL
	,Coverage varchar(2) NOT NULL
	,Form_Type varchar(12) NOT NULL
	,ClaimIDNo int NULL
	,CmtIDNo int NULL
	,Total_Claims int NULL
	,Total_Claimants int NULL
	,Total_Bills int NULL
	,Total_Lines int NULL
	,Total_Units int NULL
	,Total_Provider_Charges money NULL
	,Total_Final_Allowed money NULL
	,Total_Reductions money NULL
	,Total_Bill_Review_Reductions money NULL
	,BillsWithOneOrMoreDuplicateLinesCount int NULL
	,PartialDuplicateBills int NULL
	,DuplicateBillsCount int NULL
	,Dup_Lines_Count int NULL
	,Duplicate_Reductions money NULL
	,BenefitsExhausted_Bills_Count int NULL
	,BenefitsExhausted_Lines_Count int NULL
	,BenefitsExhausted_Reductions money NULL
	,Analyst_Reductions money NULL
	,Fee_Schedule_Reductions money NULL
	,Benchmark_Reductions money NULL
	,CTG_Reductions money NULL
	,VPN_Reductions money NULL
	,Override_Impact money NULL
	,ReportTypeID INT NOT NULL
	,RunDate datetime NOT NULL DEFAULT GETDATE()
	,LastUpdate datetime NULL
	);
END
GO



