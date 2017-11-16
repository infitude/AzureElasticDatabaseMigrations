IF NOT EXISTS (SELECT name FROM sys.tables WHERE name = 'Product')
BEGIN
CREATE TABLE [dbo].[Product]
(
	[Id] INT NOT NULL PRIMARY KEY, 
    [ProductName] NCHAR(10) NULL
)
END
GO