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



-- 8. Overdue Analysis:
-- List all books overdue by more than 30 days with their associated borrowers.
DECLARE @OverdueDays INT = 10;
WITH OverdueBooks AS (
    SELECT
        BookID,
        BorrowerID,
		DateBorrowed,
        DueDate,
        DateReturned,
        OverdueDays = DATEDIFF(DAY, DueDate, COALESCE(DateReturned, GETDATE()))
    FROM Circulation.Loans
    WHERE DATEDIFF(DAY, DueDate, COALESCE(DateReturned, GETDATE())) > @OverdueDays
)
SELECT
    k.BookID,
    k.Title,
    k.Author,
    w.BorrowerID,
    w.FirstName,
    w.LastName,
    w.Email,
	o.DateBorrowed,
    o.DueDate,
    o.DateReturned,
    o.OverdueDays
FROM OverdueBooks o
JOIN Catalog.Books k ON o.BookID = k.BookID
JOIN UserManagement.Borrowers w ON o.BorrowerID = w.BorrowerID
ORDER BY OverdueDays DESC, w.FirstName;



-- 9. Author Popularity using Aggregation:
-- Rank authors by the borrowing frequency of their books.
WITH AuthorFrequency AS (
    SELECT
        b.Author,
        BorrowingCount = COUNT(l.LoanID)
    FROM Catalog.Books b
    LEFT JOIN Circulation.Loans l ON b.BookID = l.BookID
	GROUP BY b.Author
)
SELECT
    Author,
    BorrowingCount,
    Popularity = DENSE_RANK() OVER (ORDER BY BorrowingCount DESC)
FROM AuthorFrequency
ORDER BY BorrowingCount DESC, Author;



-- 10. Genre Preference by Age using Group By and Having:
-- Determine the preferred genre of different age groups of borrowers.
-- (Groups are (0,10), (11,20), (21,30)…)
DECLARE @GroupSize INT = 10;
WITH BorrowerGenreFrequency AS (
    SELECT
        l.BorrowerID,
        bg.GenreID,
        BorrowingFrequency = COUNT(l.LoanID)
    FROM Circulation.Loans l
    JOIN Catalog.BookGenres bg ON l.BookID = bg.BookID
    GROUP BY l.BorrowerID, bg.GenreID
),
BorrowerGroups AS (
    SELECT
        BorrowerID,
        GroupNumber = DATEDIFF(YEAR, DateOfBirth, GETDATE()) / @GroupSize
    FROM UserManagement.Borrowers
),
BorrowerGroupsGenreFrequency AS (
    SELECT
        bgf.GenreID,
        bg.GroupNumber,
        BorrowingFrequency = SUM(bgf.BorrowingFrequency)
    FROM BorrowerGenreFrequency bgf
    JOIN BorrowerGroups bg ON bgf.BorrowerID = bg.BorrowerID
	GROUP BY bgf.GenreID, bg.GroupNumber
)
SELECT
    g.GenreID,
    g.Name,
    BorrowingFrequency = ISNULL(bggf.BorrowingFrequency, 0),
    GroupAge = CONCAT(bggf.GroupNumber * @GroupSize, ' - ', (bggf.GroupNumber + 1) * @GroupSize - 1),
    Popularity = DENSE_RANK() OVER (PARTITION BY bggf.GroupNumber ORDER BY ISNULL(bggf.BorrowingFrequency, 0) DESC)
FROM Catalog.Genres g
LEFT JOIN BorrowerGroupsGenreFrequency bggf ON g.GenreID = bggf.GenreID
ORDER BY bggf.GroupNumber, ISNULL(bggf.BorrowingFrequency, 0) DESC;



-- [BONUS] Weekly peak days:
-- Determine the most 3 days in the week that have the most share of the loans.
-- Display the result of each day as a percentage of all loans.
-- Sort the results from the highest percentage to the lowest percentage.
-- (eg. 25.18% of the loans happen on Monday...)
DECLARE @TotalCount FLOAT;
SELECT @TotalCount = COUNT(*) FROM Circulation.Loans;
WITH LoanDays AS (
    SELECT
        DATENAME(WEEKDAY, DateBorrowed) AS DayOfWeek,
        COUNT(*) AS LoanCount
    From Circulation.Loans
    GROUP BY DATENAME(WEEKDAY, DateBorrowed)
),
LoanDayPercentages AS (
    SELECT
        DayOfWeek,
        Percentage = (LoanCount / @TotalCount) * 100
    FROM LoanDays
)
SELECT TOP 3
    DayOfWeek,
    Percentage = ROUND(Percentage, 2)
FROM LoanDayPercentages
ORDER BY ROUND(Percentage, 2) DESC;
