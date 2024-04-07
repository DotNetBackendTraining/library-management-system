-- Concatenate all genre names in one string for each BookID
CREATE OR ALTER VIEW Catalog.CompactBookGenres AS
SELECT 
    bg.BookID,
    Genres = STUFF((
        SELECT ', ' + g.Name 
        FROM Catalog.Genres g 
        INNER JOIN Catalog.BookGenres bg2 ON g.GenreID = bg2.GenreID 
        WHERE bg2.BookID = bg.BookID 
        FOR XML PATH(''), TYPE
    ).value('.', 'NVARCHAR(MAX)'), 1, 2, '')
FROM Catalog.BookGenres bg
GROUP BY bg.BookID;

-- Inludes the Book table and its derived properties
-- The CurrentStatus of each book (whether it is 'Available' or 'Borrowed') 
-- And a concatenated string of all the Genres associated with each book.
CREATE OR ALTER VIEW Catalog.BookDetails AS
WITH ActiveLoans AS (
    -- Books currently borrowed
    SELECT DISTINCT BookID 
    FROM Circulation.Loans 
    WHERE DateReturned IS NULL
)
SELECT 
    b.BookID,
    b.Title,
    b.Author,
    b.PublishedDate,
    b.ShelfLocation,
    CurrentStatus = CASE 
                        WHEN al.BookID IS NOT NULL THEN 'Borrowed'
                        ELSE 'Available'
                    END,
    cbg.Genres
FROM Catalog.Books b
LEFT JOIN ActiveLoans al ON b.BookID = al.BookID
LEFT JOIN Catalog.CompactBookGenres cbg ON b.BookID = cbg.BookID;
