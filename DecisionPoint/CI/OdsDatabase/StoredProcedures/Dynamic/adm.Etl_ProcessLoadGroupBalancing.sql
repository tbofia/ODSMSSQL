IF OBJECT_ID('adm.Etl_ProcessLoadGroupBalancing', 'P') IS NOT NULL
    DROP PROCEDURE adm.Etl_ProcessLoadGroupBalancing
GO

CREATE PROCEDURE adm.Etl_ProcessLoadGroupBalancing
AS
BEGIN
DECLARE  @SQLScript NVARCHAR(MAX)
		,@NextLoadGroup INT;

-- Initialize Load Groups
UPDATE P
SET LoadGroup = S.LoadGroup
FROM adm.Process P
INNER JOIN (
	SELECT ProcessId
		 ,ROW_NUMBER()OVER (ORDER BY SUM(CAST(ExtractRowCount AS BIGINT)) DESC) AS LoadGroup
	FROM adm.ProcessAudit
	WHERE Status = 'FI'
	GROUP BY  ProcessId) AS S
ON P.ProcessId = S.ProcessId;

-- Get Next Load Group to Assign
SET @SQLScript = '
;WITH CTE_NextLoadGroup AS(
SELECT P.LoadGroup
	  ,SUM(CAST(PA.ExtractRowCount AS BIGINT)) LoadGroupSize
FROM adm.ProcessAudit PA
INNER JOIN adm.Process P
ON PA.ProcessId = P.ProcessId
WHERE PA.Status = ''FI''
	AND LoadGroup BETWEEN 1 AND 3
GROUP BY  P.LoadGroup)
SELECT TOP 1 @NextLoadGroup = LoadGroup
FROM CTE_NextLoadGroup C
INNER JOIN (
	SELECT MIN(LoadGroupSize) MinLoadGroupSize
	FROM CTE_NextLoadGroup) M ON C.LoadGroupSize = M.MinLoadGroupSize;'


DECLARE @ProcessId INT
DECLARE db_cursor_nextloadgroup  CURSOR FOR  
SELECT ProcessId
FROM adm.Process
WHERE LoadGroup > 3

OPEN db_cursor_nextloadgroup   
FETCH NEXT FROM db_cursor_nextloadgroup INTO @ProcessId

WHILE @@FETCH_STATUS = 0   
BEGIN 

EXEC sp_executesql @SQLScript,N'@NextLoadGroup INT OUTPUT',@NextLoadGroup = @NextLoadGroup OUTPUT;

UPDATE adm.Process
SET LoadGroup = @NextLoadGroup
WHERE ProcessId = @ProcessId

FETCH NEXT FROM db_cursor_nextloadgroup INTO @ProcessId

END

CLOSE db_cursor_nextloadgroup   
DEALLOCATE db_cursor_nextloadgroup

END
GO
