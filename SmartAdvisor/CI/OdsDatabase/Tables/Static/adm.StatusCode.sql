IF OBJECT_ID('adm.StatusCode', 'U') IS NULL
BEGIN
    CREATE TABLE adm.StatusCode
        (
            Status VARCHAR(2) NOT NULL ,
            ShortDescription VARCHAR(100) NOT NULL ,
            LongDescription VARCHAR(MAX) NOT NULL 
			        );

    ALTER TABLE adm.StatusCode ADD 
    CONSTRAINT PK_StatusCode PRIMARY KEY CLUSTERED (Status);
END
GO
