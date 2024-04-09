-- 5. Stored Procedure - Add New Borrowers:
-- Procedure Name: `sp_AddNewBorrower`
-- Purpose: Streamline the process of adding a new borrower.
-- Parameters: `FirstName`, `LastName`, `Email`, `DateOfBirth`, `MembershipDate`.
-- Implementation: Check if an email exists; if not, add to `Borrowers`. If existing, return an error message.
-- Return: The new `BorrowerID` or an error message.
CREATE OR ALTER PROCEDURE sp_AddNewBorrower
    @FirstName NVARCHAR(100), 
    @LastName NVARCHAR(100), 
    @Email NVARCHAR(255), 
    @DateOfBirth DATE, 
    @MembershipDate DATE,
    @NewBorrowerID INT OUT
AS BEGIN
    SET NOCOUNT ON;

    IF EXISTS(SELECT 1 FROM UserManagement.Borrowers WHERE Email = @Email)
    BEGIN
        THROW 50000, 'Email already exists.', 1;
    END
    ELSE
    BEGIN
        INSERT INTO UserManagement.Borrowers (FirstName, LastName, Email, DateOfBirth, MembershipDate)
        VALUES (@FirstName, @LastName, @Email, @DateOfBirth, @MembershipDate);

        SET @NewBorrowerID = SCOPE_IDENTITY();
    END
END;

-- Example:
DECLARE @BorrowerID INT;
DECLARE @CurrentDate DATE = GETDATE();

EXEC sp_AddNewBorrower 
    @FirstName = 'John',
    @LastName = 'Doe',
    @Email = 'john.doe@example.com',
    @DateOfBirth = '1990-01-01',
    @MembershipDate = @CurrentDate,
    @NewBorrowerID = @BorrowerID OUTPUT;

SELECT @BorrowerID AS NewBorrowerID;



-- 11. Stored Procedure - Borrowed Books Report:
-- Procedure Name: `sp_BorrowedBooksReport`
-- Purpose: Generate a report of books borrowed within a specified date range.
-- Parameters: `StartDate`, `EndDate`
-- Implementation: Retrieve all books borrowed within the given range, with details like borrower name and borrowing date.
-- Return: Tabulated report of borrowed books.
CREATE OR ALTER PROCEDURE sp_BorrowedBooksReport
    @StartDate DATE,
    @EndDate DATE
AS BEGIN
    SELECT
        k.Title AS BookTitle,
        k.Author AS BookAuthor,
        w.FirstName + ' ' + w.LastName AS BorrowerName,
        l.DateBorrowed,
        l.DueDate
    FROM Circulation.Loans l
    JOIN Catalog.Books k ON k.BookID = l.BookID
    JOIN UserManagement.Borrowers w ON w.BorrowerID = l.BorrowerID
    WHERE l.DateBorrowed BETWEEN @StartDate AND @EndDate;
END

-- Example
EXEC sp_BorrowedBooksReport @StartDate = '2024-02-01', @EndDate = '2024-03-01';



-- 13. SQL Stored Procedure with Temp Table:
-- Retrieves all borrowers who have overdue books. Stores these borrowers in a temporary table,
-- then joins this temp table with the Loans table to list out the specific overdue books for each borrower.
CREATE OR ALTER PROCEDURE sp_ListOverdueBooksByBorrower
AS BEGIN
    SET NOCOUNT ON;

    IF OBJECT_ID('tempdb..#OverdueBorrowers') IS NOT NULL
        DROP TABLE #OverdueBorrowers;

    SELECT DISTINCT
        br.BorrowerID,
        br.FirstName,
        br.LastName
    INTO #OverdueBorrowers
    FROM UserManagement.Borrowers br
    JOIN Circulation.Loans l ON br.BorrowerID = l.BorrowerID
    WHERE l.DueDate < GETDATE() AND (l.DateReturned IS NULL OR l.DateReturned > l.DueDate);

    SELECT
        ob.BorrowerID,
        ob.FirstName,
        ob.LastName,
        b.Title AS BookTitle,
        l.DateBorrowed,
        l.DueDate,
		l.DateReturned
    FROM #OverdueBorrowers ob
    JOIN Circulation.Loans l ON ob.BorrowerID = l.BorrowerID
    JOIN Catalog.Books b ON l.BookID = b.BookID
    WHERE l.DueDate < GETDATE() AND (l.DateReturned IS NULL OR l.DateReturned > l.DueDate)
    ORDER BY ob.BorrowerID, l.DueDate;
END;

-- Example
EXEC sp_ListOverdueBooksByBorrower;
