IF OBJECT_ID('adm.Etl_CreateUnpartitionedTableSchema', 'P') IS NOT NULL
    DROP PROCEDURE adm.Etl_CreateUnpartitionedTableSchema
GO

CREATE PROCEDURE adm.Etl_CreateUnpartitionedTableSchema (
@CustomerId INT,
@ProcessId INT,
@SwitchOut INT = 0,
@returnstatus INT OUTPUT)
AS
BEGIN
-- DECLARE @ProcessId INT = 26,@CustomerId INT = 19,@SwitchOut INT = 0,@returnstatus INT;
DECLARE  @SQLScript VARCHAR(MAX) = 'CREATE TABLE '
		,@DatabaseCollation VARCHAR(255)
		,@SrcColumnList VARCHAR(MAX)
		,@StagingSchemaName CHAR(3) = 'stg'
		,@TargetSchemaName CHAR(3) = (SELECT TargetSchemaName FROM adm.Process WHERE ProcessId = @ProcessId)
		,@TargetTableName VARCHAR(255) = (SELECT TargetTableName FROM adm.Process WHERE ProcessId = @ProcessId);

--Get Database Collation ** Use in Case Column Collation is Different
SET @DatabaseCollation = (SELECT CONVERT (varchar, DATABASEPROPERTYEX(DB_NAME(),'collation')));  

-- Build Column definitions for the table.
SELECT @SrcColumnList =  COALESCE(@srcColumnList+CHAR(13)+CHAR(10)+CHAR(9)+',','')
+'['+ COLUMN_NAME +']' +' '
+ DATA_TYPE 
+ CASE WHEN DATA_TYPE in ('decimal','numeric') THEN '('+CAST(NUMERIC_PRECISION AS VARCHAR(5))+','+CAST(NUMERIC_SCALE AS VARCHAR(5))+')' ELSE '' END
+ CASE WHEN CHARACTER_MAXIMUM_LENGTH = -1 AND DATA_TYPE <> 'xml' THEN ' (MAX)' WHEN  CHARACTER_MAXIMUM_LENGTH IS NOT NULL AND DATA_TYPE not in ('text','xml') THEN ' ('+CAST(CHARACTER_MAXIMUM_LENGTH AS VARCHAR(10))+')' ELSE '' END
+ CASE WHEN COLLATION_NAME <> @DatabaseCollation THEN ISNULL(' COLLATE '+COLLATION_NAME,'') ELSE '' END
+ CASE WHEN IS_NULLABLE = 'YES' THEN ' NULL' ELSE ' NOT NULL' END 

FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_SCHEMA = @TargetSchemaName
AND TABLE_NAME = @TargetTableName
ORDER BY ORDINAL_POSITION;

-- Put it together and add check constraint for customer use only.
SET @SQLScript = @SQLScript + @StagingSchemaName +'.'+@TargetTableName+'_Unpartitioned'+' ('+CHAR(13)+CHAR(10)+CHAR(9)
+@SrcColumnList+')WITH (DATA_COMPRESSION = PAGE);'+CHAR(13)+CHAR(10)+CHAR(13)+CHAR(10)+

-- Only Add check constraint if table will be used for switching into main table.
CASE WHEN @SwitchOut = 0 THEN
'ALTER TABLE '+ @StagingSchemaName +'.'+@TargetTableName+'_Unpartitioned'+CHAR(13)+CHAR(10)+
'ADD CONSTRAINT CK_'+@TargetTableName+'_CustomerPartitionCheck CHECK (OdsCustomerId = '+CAST(@CustomerId AS VARCHAR(5))+');'
ELSE '' END;

BEGIN TRY
EXEC(@SQLScript)
SET @returnstatus = 0
END TRY
BEGIN CATCH
PRINT 'Could not create table...Make sure table doesn''t exists.'
SET @returnstatus = 1
END CATCH

END
GO
