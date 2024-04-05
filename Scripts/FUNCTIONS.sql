-- 6. Database Function - Calculate Overdue Fees:
-- Function Name: `fn_CalculateOverdueFees`
-- Purpose: Compute overdue fees for a given loan.
-- Parameter: `LoanID`
-- Implementation: Charge fees based on overdue days: $1/day for up to   30 days, $2/day after.
-- Return: Overdue fee for the `LoanID`.
DROP FUNCTION IF EXISTS fn_CalculateOverdueFees
GO
CREATE FUNCTION fn_CalculateOverdueFees
(
    @LoanID INT
)
RETURNS DECIMAL(10, 2)
AS BEGIN
    DECLARE @DueDate DATE;
    DECLARE @DateReturned DATE;
    DECLARE @OverdueDays INT;
    DECLARE @OverdueFee DECIMAL(10, 2);

    SELECT @DueDate = DueDate, @DateReturned = DateReturned
    FROM Circulation.Loans
    WHERE LoanID = @LoanID;

    SET @OverdueDays = DATEDIFF(DAY, @DueDate, COALESCE(@DateReturned, GETDATE()));

    IF @OverdueDays > 0
    BEGIN
        IF @OverdueDays <= 30
        BEGIN
            SET @OverdueFee = @OverdueDays * 1.00; -- $1/day for up to 30 days
        END
        ELSE
        BEGIN
            SET @OverdueFee = (30 * 1.00) + ((@OverdueDays - 30) * 2.00); -- $2/day after 30 days
        END
    END
    ELSE
    BEGIN
        SET @OverdueFee = 0.00; -- No overdue fee if returned on time or before due date
    END

    RETURN @OverdueFee;
END

-- Example
SELECT dbo.fn_CalculateOverdueFees(128) AS OverdueFee;



-- 7. Database Function - Book Borrowing Frequency:
-- Function Name: `fn_BookBorrowingFrequency`
-- Purpose: Gauge the borrowing frequency of a book.
-- Parameter: `BookID`
-- Implementation: Count the number of times the book has been issued.
-- Return: Borrowing count of the book.
DROP FUNCTION IF EXISTS fn_BookBorrowingFrequency
GO
CREATE FUNCTION fn_BookBorrowingFrequency
(
    @BookID INT
)
RETURNS INT
AS BEGIN
    DECLARE @BorrowingCount INT;

    SELECT @BorrowingCount = COUNT(*)
    FROM Circulation.Loans
    WHERE BookID = @BookID;

    RETURN @BorrowingCount;
END

-- Example
SELECT dbo.fn_BookBorrowingFrequency(5) AS BorrowingFrequency;
