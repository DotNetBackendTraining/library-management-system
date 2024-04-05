-- 5. Stored Procedure - Add New Borrowers:
-- Procedure Name: `sp_AddNewBorrower`
-- Purpose: Streamline the process of adding a new borrower.
-- Parameters: `FirstName`, `LastName`, `Email`, `DateOfBirth`, `MembershipDate`.
-- Implementation: Check if an email exists; if not, add to `Borrowers`. If existing, return an error message.
-- Return: The new `BorrowerID` or an error message.
DROP PROCEDURE IF EXISTS sp_AddNewBorrower;
GO
CREATE PROCEDURE sp_AddNewBorrower
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
DROP PROCEDURE IF EXISTS sp_BorrowedBooksReport;
GO
CREATE PROCEDURE sp_BorrowedBooksReport
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
