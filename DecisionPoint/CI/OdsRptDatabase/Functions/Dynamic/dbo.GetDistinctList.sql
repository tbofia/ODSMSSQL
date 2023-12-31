IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'dbo.GetDistinctList') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION dbo.GetDistinctList
GO

CREATE FUNCTION dbo.GetDistinctList(
@List VARCHAR(MAX),
@Delim CHAR
)
RETURNS VARCHAR(MAX)
AS
BEGIN
DECLARE @DList VARCHAR(MAX);

SELECT @DList = STUFF((SELECT DISTINCT ', ' + CAST(StringText AS VARCHAR(50))
           FROM dbo.GetTableFromDelimitedString(@List,@Delim) 
           FOR XML PATH('')), 1, 2, '')
FROM dbo.GetTableFromDelimitedString(@List,@Delim)

RETURN @Dlist;
END
GO 
