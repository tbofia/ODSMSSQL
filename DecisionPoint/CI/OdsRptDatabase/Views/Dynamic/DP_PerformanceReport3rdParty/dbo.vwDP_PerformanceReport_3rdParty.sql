IF OBJECT_ID ('dbo.vwDP_PerformanceReport_3rdParty', 'V') IS NOT NULL
DROP VIEW dbo.vwDP_PerformanceReport_3rdParty;
GO
CREATE VIEW dbo.vwDP_PerformanceReport_3rdParty
AS
SELECT ReportTypeID
	  ,CASE WHEN ReportTypeID = 1 THEN 'FirstBillCreateDate'
			WHEN ReportTypeID = 2 THEN 'DateOfLoss'
			WHEN ReportTypeID = 3 THEN 'ClaimantCreateDate'
			WHEN ReportTypeID = 4 THEN 'MitchellCompleteDate'
			WHEN ReportTypeID = 5 THEN 'LastBillCreateDate' END AS ReportName
--First Day of PostDateMonth defined
   	  ,CAST(
				CAST(DATEPART(MONTH,StartOfMonth) AS VARCHAR(2)) 
			+ '/'
			+ '01/'
			+ CAST(DATEPART(YEAR ,StartOfMonth) AS VARCHAR(4)) 
			AS DATE) as StartofMonth 
      ,Customer
      ,Year
      ,Month
      ,Company
      ,Office
      ,SOJ
      ,Coverage
      ,Form_Type
      ,ClaimIDNo
      ,CmtIDNo
      ,Total_Claims
      ,Total_Claimants
      ,Total_Bills
      ,Total_Lines
      ,Total_Units
      ,Total_Provider_Charges
      ,Total_Final_Allowed
      ,Total_Reductions
      ,Total_BillAdjustments
      ,Standard
      ,Premium
      ,FeeSchedule
      ,Benchmark
      ,VPN
      ,Override

-- Reporting Month defined
	  ,CAST(
	         CAST(DATEPART(MONTH,DATEADD(MONTH,-1,GETDATE())) AS VARCHAR(2)) 
		   + '/'
		   + '01/'
	       + CAST(DATEPART(YEAR ,DATEADD(MONTH,-1,GETDATE())) AS VARCHAR(4)) 
		 AS DATE) AS ReportingMonthDefined

-- "First day of prior month" defined 
-- If it is January, the "Prior Month" would be November. This is because the "Reporting Month" is the last complete month (December).
	  ,CAST(
	         CAST(DATEPART(MONTH,DATEADD(MONTH,-2,GETDATE())) AS VARCHAR(2)) 
		   + '/'
		   + '01/'
	       + CAST(DATEPART(YEAR ,DATEADD(MONTH,-2,GETDATE())) AS VARCHAR(4)) 
		 AS DATE) AS PriorMonthDefined

-- Reporting Month Flagged (Last month with complete data) (last month essentially) 
,CASE 
	      WHEN 
		  CAST(
				CAST(DATEPART(MONTH,StartOfMonth) AS VARCHAR(2)) 
			+ '/'
			+ '01/'
			+ CAST(DATEPART(YEAR ,StartOfMonth) AS VARCHAR(4)) 
			AS DATE)
		       = 
		  CAST(
				CAST(DATEPART(MONTH,DATEADD(MONTH,-1,GETDATE())) AS VARCHAR(2)) 
			+ '/'
			+ '01/'
			+ CAST(DATEPART(YEAR ,DATEADD(MONTH,-1,GETDATE())) AS VARCHAR(4)) 
			AS DATE)
			 THEN 1
		ELSE NULL
	   END AS ReportingMonth


-- If "First Day of PostDateMonth" = "first day of prior month" then flag that as "Prior Month" 
	  ,CASE 
	      WHEN 
		  CAST(
				CAST(DATEPART(MONTH,StartOfMonth) AS VARCHAR(2)) 
			+ '/'
			+ '01/'
			+ CAST(DATEPART(YEAR ,StartOfMonth) AS VARCHAR(4)) 
			AS DATE)
		       = 
		  CAST(
				CAST(DATEPART(MONTH,DATEADD(MONTH,-2,GETDATE())) AS VARCHAR(2)) 
			+ '/'
			+ '01/'
			+ CAST(DATEPART(YEAR ,DATEADD(MONTH,-2,GETDATE())) AS VARCHAR(4)) 
			AS DATE)
			 THEN 1
		ELSE NULL
	   END AS PriorMonth



-- PRIOR 3 MONTHS   

-- Logic is as follows:
	-- If the first day of the post date month is between the first day of the "5th month prior to today" and the "Last Day of the 2th month prior to today", 
	-- then flag it as Prior3Months 
	-- "Last Day of the 2th month prior to today" is defined by subtracting one day from the first day of last month. 

-- First Day of the post date month 
 ,CASE 
    WHEN 
			CAST(
					CAST(DATEPART(MONTH,StartOfMonth) AS VARCHAR(2)) 
				+ '/'
				+ '01/'
				+ CAST(DATEPART(YEAR ,StartOfMonth) AS VARCHAR(4)) 
				AS DATE)
   BETWEEN 
 -- First Day of 5 months ago. 
				   CAST(
						  CAST(DATEPART(MONTH,DATEADD(MONTH,-5,GETDATE())) AS VARCHAR(2)) 
						+ '/'
						+ '01/'
						+ CAST(DATEPART(YEAR,DATEADD(MONTH,-5,GETDATE())) AS VARCHAR(4))
						AS DATE)
   AND 
 --Last Day of whatever month we were in 2 months ago 
              --Subtracting one day from the first day of last month
			     DATEADD(DAY,-1,
				  CAST(
						  CAST(DATEPART(MONTH,DATEADD(MONTH,-1,GETDATE())) AS VARCHAR(2)) 
						+ '/'
						+ '01/'
						+ CAST(DATEPART(YEAR,DATEADD(MONTH,-1,GETDATE())) AS VARCHAR(4))
						AS DATE) 
					  ) 
   THEN 1 
   ELSE NULL 
   END AS ThreeMonthsPrior






-- PRIOR 12 MONTHS   

-- Logic is as follows:
	-- If the first day of the post date month is between the first day of the 13th month prior to today and the Last Day of Prior Month, 
	-- then flag it as Prior12Months 
	-- "Last Day of Prior Month" is defined by subtracting one day from the first day this month. 

-- First Day of the post date month 
 ,CASE 
    WHEN 
			CAST(
					CAST(DATEPART(MONTH,StartOfMonth) AS VARCHAR(2)) 
				+ '/'
				+ '01/'
				+ CAST(DATEPART(YEAR ,StartOfMonth) AS VARCHAR(4)) 
				AS DATE)
   BETWEEN 
 -- First Day of 13 months ago. 
				   CAST(
						  CAST(DATEPART(MONTH,DATEADD(MONTH,-14,GETDATE())) AS VARCHAR(2)) 
						+ '/'
						+ '01/'
						+ CAST(DATEPART(YEAR,DATEADD(MONTH,-14,GETDATE())) AS VARCHAR(4))
						AS DATE)
   AND 
 --Last Day of whatever month we were in 2 months ago 
              --Subtracting one day from the first day of last month
			    DATEADD(DAY,-1,
					  CAST(
							  CAST(DATEPART(MONTH,DATEADD(MONTH,-1,GETDATE())) AS VARCHAR(2)) 
							+ '/'
							+ '01/'
							+ CAST(DATEPART(YEAR,DATEADD(MONTH,-1,GETDATE())) AS VARCHAR(4))
							AS DATE) 
						  ) 
   THEN 1 
   ELSE NULL 
   END AS TwelveMonthsPrior

   -- Same Month Prior Year Defined
  ,CAST(
				CAST(DATEPART(MONTH,DATEADD(MONTH,-13,GETDATE())) AS VARCHAR(2)) 
			+ '/'
			+ '01/'
			+ CAST(DATEPART(YEAR ,DATEADD(MONTH,-13,GETDATE())) AS VARCHAR(4)) 
			AS DATE) as SameMonthPriorYearDefined 


-- Same Month Prior Year

 ,CASE 
	WHEN 
	-- Post Date Month
	CAST(
				CAST(DATEPART(MONTH,StartOfMonth) AS VARCHAR(2)) 
			+ '/'
			+ '01/'
			+ CAST(DATEPART(YEAR ,StartOfMonth) AS VARCHAR(4)) 
			AS DATE)  

			=

   		CAST(
				CAST(DATEPART(MONTH,DATEADD(MONTH,-13,GETDATE())) AS VARCHAR(2)) 
			+ '/'
			+ '01/'
			+ CAST(DATEPART(YEAR ,DATEADD(MONTH,-13,GETDATE())) AS VARCHAR(4)) 
			AS DATE)
		THEN 1 
		ELSE NULL 
	 END AS SameMonthPriorYear 


-- First Day of 5 months ago (Beginning of the Prior3Months Date Range) 
   ,  CAST(
			  CAST(DATEPART(MONTH,DATEADD(MONTH,-5,GETDATE())) AS VARCHAR(2)) 
			+ '/'
			+ '01/'
			+ CAST(DATEPART(YEAR,DATEADD(MONTH,-5,GETDATE())) AS VARCHAR(4))
			AS DATE) as ThreeMonthsPriorBegin

-- First Day of 14 months ago (Beginning of the Prior12Months Date Range) 
   ,  CAST(
			  CAST(DATEPART(MONTH,DATEADD(MONTH,-14,GETDATE())) AS VARCHAR(2)) 
			+ '/'
			+ '01/'
			+ CAST(DATEPART(YEAR,DATEADD(MONTH,-14,GETDATE())) AS VARCHAR(4))
			AS DATE) as TwelveMonthsPriorBegin

---- Last Day of the Prior Month (End of all the Period Groups) 
   , DATEADD(DAY,-1,
		  CAST(
				  CAST(DATEPART(MONTH,DATEADD(MONTH,-1,GETDATE())) AS VARCHAR(2)) 
				+ '/'
				+ '01/'
				+ CAST(DATEPART(YEAR,DATEADD(MONTH,-1,GETDATE())) AS VARCHAR(4))
				AS DATE) 
              ) as BaselinePeriodEndDate   
      ,RunDate
	  ,GETDATE() as ReportingDate
  FROM dbo.DP_PerformanceReport_3rdParty_Output
  GO
