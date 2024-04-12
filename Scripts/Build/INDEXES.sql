----- Drop All ----

DECLARE @DropAllIndexesQuery NVARCHAR(max);
SELECT @DropAllIndexesQuery = (
    SELECT 'DROP INDEX ' 
        + quotename(ix.name) + ' ON ' 
        + quotename(object_schema_name(object_id)) + '.' 
        + quotename(OBJECT_NAME(object_id)) + '; '
    FROM sys.indexes ix
    WHERE ix.Name IS NOT NULL AND (
        -- Customize which indexes to drop...
        ix.Name LIKE '%idx_Loans%' OR
        ix.Name LIKE '%idx_BookGenres%' OR
        ix.Name LIKE '%idx_Borrowers%'
    )
    FOR XML PATH('')
);
EXEC sp_executesql @DropAllIndexesQuery



---- Loans ----

CREATE NONCLUSTERED INDEX idx_Loans_BookID_DateBorrowed -- Foreign Key, Sort Column
ON Circulation.Loans(BookID, DateBorrowed);

CREATE NONCLUSTERED INDEX idx_Loans_BorrowerID_DateBorrowed -- Foreign Key, Sort Column
ON Circulation.Loans(BorrowerID, DateBorrowed);

CREATE NONCLUSTERED INDEX idx_Loans_ActiveLoans -- Common Condition
ON Circulation.Loans (BorrowerID, DateReturned) -- Sort Column
INCLUDE (BookID) -- Typical selection
WHERE DateReturned IS NULL; -- Loan is active

CREATE NONCLUSTERED INDEX idx_Loans_DateBorrowed -- Queried Date
ON Circulation.Loans(DateBorrowed);

CREATE NONCLUSTERED INDEX idx_Loans_DueDate_DateReturned -- Queried Date, Typical Selection
ON Circulation.Loans(DueDate, DateReturned)
INCLUDE (BookID, BorrowerID, DateBorrowed);



---- BookGenres ----

CREATE NONCLUSTERED INDEX idx_BookGenres_BookID -- Foreign Key
ON Catalog.BookGenres(BookID);

CREATE NONCLUSTERED INDEX idx_BookGenres_GenreID -- Foreign Key
ON Catalog.BookGenres(GenreID);



---- Borrowers ----

CREATE NONCLUSTERED INDEX idx_Borrowers_DateOfBirth -- Queried Date
ON UserManagement.Borrowers(DateOfBirth);

CREATE NONCLUSTERED INDEX idx_Borrowers_Covering -- Covering Index
ON UserManagement.Borrowers(BorrowerID)
INCLUDE (FirstName, LastName, Email); -- Typical selections



------ Books ------

CREATE NONCLUSTERED INDEX idx_Books_Covering -- Covering Index
ON Catalog.Books(BookID, Author) -- Typical sorts
INCLUDE (Title); -- Typical selections



---- AuditLog -----
-- No indexes for it to optimize write operations
-- Reads will be slow but no queries are implemented yet
