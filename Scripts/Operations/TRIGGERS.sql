-- 12. Trigger Implementation
-- Log an entry into a separate AuditLog table whenever a book's status changes from 'Available' to 'Borrowed' or vice versa.
-- Its triggered on Circulation.Loans table not Catalog.Books because it's where status property is dervied from.
-- Check Catalog.BookDetails view for reference.
CREATE OR ALTER TRIGGER trg_BookStatusChange
ON Circulation.Loans
AFTER INSERT, UPDATE, DELETE
AS BEGIN
    SET NOCOUNT ON;

    -- INSERT operation:
    -- Log only if the book is not returned at the time of loan creation.
    -- Otherwise its available before and after the insertion, no transition.
    IF (SELECT COUNT(*) FROM inserted) > 0 AND (SELECT COUNT(*) FROM deleted) = 0
    BEGIN
        INSERT INTO Audit.AuditLog (BookID, StatusChange)
        SELECT i.BookID, 'Borrowed'
        FROM inserted i
        WHERE i.DateReturned IS NULL;
    END

    -- DELETE operation:
    -- Log only if the book was not returned before deletion.
    -- Otherwise its available before and after the insertion, no transition.
    IF (SELECT COUNT(*) FROM deleted) > 0 AND (SELECT COUNT(*) FROM inserted) = 0
    BEGIN
        INSERT INTO Audit.AuditLog (BookID, StatusChange)
        SELECT d.BookID, 'Loan Record Deleted'
        FROM deleted d
        WHERE d.DateReturned IS NULL;
    END

    -- UPDATE operation:
    -- Log transitions both ways, if the book was returned (from null to not null).
    -- Or if the loan record was updated (from not null to null) for some reason.
    IF (SELECT COUNT(*) FROM inserted) > 0 AND (SELECT COUNT(*) FROM deleted) > 0
    BEGIN
        INSERT INTO Audit.AuditLog (BookID, StatusChange)
        SELECT i.BookID, 'Returned'
        FROM inserted i
        INNER JOIN deleted d ON i.LoanID = d.LoanID
        WHERE i.DateReturned IS NOT NULL AND d.DateReturned IS NULL

        UNION ALL

        SELECT d.BookID, 'Return Date Removed'
        FROM inserted i
        INNER JOIN deleted d ON i.LoanID = d.LoanID
        WHERE i.DateReturned IS NULL AND d.DateReturned IS NOT NULL;
    END
END;
