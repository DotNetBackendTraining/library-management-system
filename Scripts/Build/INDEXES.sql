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

CREATE INDEX idx_Loans_BookID -- Foreign Key
ON Circulation.Loans(BookID);

CREATE INDEX idx_Loans_BorrowerID -- Foreign Key
ON Circulation.Loans(BorrowerID);

CREATE INDEX idx_Loans_DateBorrowed -- Queried Date
ON Circulation.Loans(DateBorrowed);

CREATE INDEX idx_Loans_DueDate -- Queried Date
ON Circulation.Loans(DueDate);

CREATE INDEX idx_Loans_DateReturned -- Queried Date
ON Circulation.Loans(DateReturned);



---- BookGenres ----

CREATE INDEX idx_BookGenres_BookID -- Foreign Key
ON Catalog.BookGenres(BookID);

CREATE INDEX idx_BookGenres_GenreID -- Foreign Key
ON Catalog.BookGenres(GenreID);



---- Borrowers ----

CREATE INDEX idx_Borrowers_DateOfBirth -- Queried Date
ON UserManagement.Borrowers(DateOfBirth);



---- AuditLog -----
-- No indexes for it to optimize write operations
-- Reads will be slow but no queries are implemented yet
