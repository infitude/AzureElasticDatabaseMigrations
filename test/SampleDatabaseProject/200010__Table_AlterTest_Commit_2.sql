IF NOT EXISTS (SELECT columns.name FROM sys.columns INNER JOIN sys.tables on columns.object_id = tables.object_id WHERE tables.name = 'TestTable' AND columns.name = 'AdditionalInformation')
BEGIN
	ALTER TABLE TestTable
	ADD AdditionalInformation NVARCHAR(400);
END
GO