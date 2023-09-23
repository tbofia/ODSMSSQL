IF OBJECT_ID('rpt.StatusCode', 'U') IS NULL
BEGIN
    CREATE TABLE rpt.StatusCode
        (
            Status VARCHAR(2) NOT NULL ,
            ShortDescription VARCHAR(100) NOT NULL ,
            LongDescription VARCHAR(MAX) NOT NULL 
			        );

    ALTER TABLE rpt.StatusCode ADD 
    CONSTRAINT PK_StatusCode PRIMARY KEY CLUSTERED (Status);
END
GO
