SELECT P.[PostingGroupAuditId]
	,P.[OltpPostingGroupAuditId]
	,P.[PostingGroupId]
	,P.[CustomerId]
	,p.STATUS
INTO #dupPostinggroups
FROM [AcsOds].[adm].[PostingGroupAudit] P
INNER JOIN [AcsOds].[adm].[PostingGroupAudit] P2 ON P.OltpPostingGroupAuditId = p2.OltpPostingGroupAuditId
	AND P.CustomerId = p2.CustomerId
	AND P2.STATUS = 'FI'
WHERE P.STATUS = 's'

UNION

SELECT P2.PostingGroupAuditId
	,P.[OltpPostingGroupAuditId]
	,P.[PostingGroupId]
	,P.[CustomerId]
	,p2.STATUS
FROM [AcsOds].[adm].[PostingGroupAudit] P
INNER JOIN [AcsOds].[adm].[PostingGroupAudit] P2 ON P.OltpPostingGroupAuditId = p2.OltpPostingGroupAuditId
	AND P.CustomerId = p2.CustomerId
	AND P2.STATUS = 'FI'
WHERE P.STATUS = 's'
ORDER BY 4
	,1

SELECT DISTINCT CustomerId
	,OltpPostingGroupAuditId
	,ProcessId
	,ExtractRowCount
	,UpdateRowCount
	,LoadRowCount
INTO #mult
FROM #dupPostinggroups D
INNER JOIN [AcsOds].[adm].[ProcessAudit] P ON D.PostingGroupAuditId = P.PostingGroupAuditId
WHERE LoadRowCount <> 0
ORDER BY 1
	,2
	,3

SELECT CustomerId
	,OltpPostingGroupAuditId
	,ProcessId
	,COUNT(1) NumberOfInserts
INTO #processes
FROM #mult
GROUP BY CustomerId
	,OltpPostingGroupAuditId
	,ProcessId
HAVING COUNT(1) > 1

SELECT P.*
	,g.PostingGroupAuditId
	,ExtractRowCount
	,UpdateRowCount
	,LoadRowCount
	,g.STATUS
INTO #updated
FROM #processes P
INNER JOIN #dupPostinggroups g ON p.CustomerId = g.CustomerId
	AND p.OltpPostingGroupAuditId = g.OltpPostingGroupAuditId
INNER JOIN [AcsOds].[adm].[ProcessAudit] Pa ON g.PostingGroupAuditId = pa.PostingGroupAuditId
	AND p.ProcessId = pa.ProcessId
WHERE g.STATUS = 'S'

--UPDATE  P
--SET  P.UpdateRowCount = 0
--	,P.LoadRowCount = 0
--FROM [AcsOds].[adm].[ProcessAudit] P
--INNER JOIN #updated U ON P.ProcessId = u.ProcessId
--	AND p.PostingGroupAuditId = U.PostingGroupAuditId

