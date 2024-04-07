-- Shchemas
CREATE SCHEMA UserManagement;
CREATE SCHEMA Catalog;
CREATE SCHEMA Circulation;
CREATE SCHEMA Audit;

CREATE TABLE UserManagement.Borrowers (
    BorrowerID INT IDENTITY(1,1) PRIMARY KEY,
    FirstName NVARCHAR(100) NOT NULL,
    LastName NVARCHAR(100) NOT NULL,
    Email NVARCHAR(255) UNIQUE NOT NULL,
    DateOfBirth DATE NOT NULL,
    MembershipDate DATE NOT NULL
);

CREATE TABLE Catalog.Books (
    BookID INT IDENTITY(1,1) PRIMARY KEY,
    Title NVARCHAR(255) NOT NULL,
    Author NVARCHAR(255) NOT NULL,
    ISBN NVARCHAR(20) UNIQUE NOT NULL,
    PublishedDate DATE NOT NULL,
    ShelfLocation NVARCHAR(100) NOT NULL
);

CREATE TABLE Catalog.Genres (
    GenreID INT IDENTITY(1,1) PRIMARY KEY,
    Name NVARCHAR(100) NOT NULL
);

CREATE TABLE Catalog.BookGenres (
    BookID INT NOT NULL,
    GenreID INT NOT NULL,
    PRIMARY KEY (BookID, GenreID),
    FOREIGN KEY (BookID) REFERENCES Catalog.Books(BookID),
    FOREIGN KEY (GenreID) REFERENCES Catalog.Genres(GenreID)
);

CREATE TABLE Circulation.Loans (
    LoanID INT IDENTITY(1,1) PRIMARY KEY,
    BookID INT NOT NULL,
    BorrowerID INT NOT NULL,
    DateBorrowed DATE NOT NULL,
    DueDate DATE NOT NULL,
    DateReturned DATE, -- NULL if the book is not returned yet
    FOREIGN KEY (BookID) REFERENCES Catalog.Books(BookID),
    FOREIGN KEY (BorrowerID) REFERENCES UserManagement.Borrowers(BorrowerID)
);

CREATE TABLE Audit.AuditLog (
    LogID INT IDENTITY(1,1) PRIMARY KEY,
    BookID INT NOT NULL,
    StatusChange NVARCHAR(255),
    ChangeDate DATETIME DEFAULT GETDATE(),
    FOREIGN KEY (BookID) REFERENCES Catalog.Books(BookID)
);
