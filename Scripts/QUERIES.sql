-- 1. List of Borrowed Books:
-- Retrieve all books borrowed by a specific borrower, including those currently unreturned.
DECLARE @BorrowerID INT = 10;
WITH BorrowedBooks AS (
    SELECT 
        l.LoanID,
        l.BookID,
        l.DateBorrowed,
        l.DueDate,
        l.DateReturned
    FROM Circulation.Loans l
    WHERE l.BorrowerID = @BorrowerID
)
SELECT 
    b.BookID,
    b.Title,
    b.Author,
    b.PublishedDate,
    b.ShelfLocation,
    bb.DateBorrowed,
    bb.DueDate,
    bb.DateReturned
FROM Catalog.Books b
JOIN BorrowedBooks bb ON b.BookID = bb.BookID
ORDER BY bb.DateBorrowed DESC;



-- 2. Active Borrowers with CTEs:
-- Identify borrowers who've borrowed 2 or more books but haven't returned any using CTEs.
WITH ActiveLoans AS (
    SELECT 
        LoanID,
        BorrowerID,
        BookID
    FROM Circulation.Loans
    WHERE DateReturned IS NULL
),
ActiveBorrowers AS (
    SELECT 
        BorrowerID, 
        COUNT(BookID) as BooksBorrowed
    FROM ActiveLoans
    GROUP BY BorrowerID
    HAVING COUNT(BookID) >= 2
)
SELECT
    ab.BorrowerID,
    b.FirstName,
    b.LastName,
    b.Email,
    ab.BooksBorrowed
FROM UserManagement.Borrowers b
JOIN ActiveBorrowers ab ON b.BorrowerID = ab.BorrowerID
ORDER BY ab.BooksBorrowed DESC;



-- 3. Borrowing Frequency using Window Functions:
-- Rank borrowers based on borrowing frequency.
WITH BorrowingFrequency AS (
    SELECT 
        BorrowerID, 
        COUNT(LoanID) as LoanCount
    FROM Circulation.Loans
	GROUP BY BorrowerID
)
SELECT
    b.BorrowerID,
    b.FirstName,
    b.LastName,
    b.Email,
    LoanCount = ISNULL(bf.LoanCount, 0),
    BorrowingRank = RANK() OVER (ORDER BY ISNULL(bf.LoanCount, 0) DESC)
FROM UserManagement.Borrowers b
LEFT JOIN BorrowingFrequency bf ON b.BorrowerID = bf.BorrowerID
ORDER BY bf.LoanCount DESC;



-- 4. Popular Genre Analysis using Joins and Window Functions:
-- Identify the most popular genre for a given month.
DECLARE @Year INT = 2023;
DECLARE @Month INT = 4;
WITH GenreBorrows AS (
    SELECT
        bg.GenreID,
        COUNT(l.LoanID) AS LoanCount
    FROM Catalog.BookGenres bg
    LEFT JOIN Catalog.Books b ON bg.BookID = b.BookID
    LEFT JOIN Circulation.Loans l ON b.BookID = l.BookID 
        AND YEAR(l.DateBorrowed) = @Year 
        AND MONTH(l.DateBorrowed) = @Month
    GROUP BY bg.GenreID
)
SELECT
    g.GenreID,
    g.Name,
    LoanCount = ISNULL(gb.LoanCount, 0),
    PopularityRank = DENSE_RANK() OVER (ORDER BY ISNULL(gb.LoanCount, 0) DESC)
FROM Catalog.Genres g
LEFT JOIN GenreBorrows gb ON g.GenreID = gb.GenreID
ORDER BY PopularityRank;
