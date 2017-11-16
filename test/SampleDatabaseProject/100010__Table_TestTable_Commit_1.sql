IF NOT EXISTS (SELECT name FROM sys.tables WHERE name = 'TestTable')
BEGIN
    CREATE TABLE TestTable(
        TestTableId INT PRIMARY KEY IDENTITY,
        InsertionTime DATETIME2
    );
END
GO