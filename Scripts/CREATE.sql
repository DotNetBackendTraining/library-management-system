CREATE TABLE [Borrowers] (
	[BorrowerID] INT IDENTITY(1,1) PRIMARY KEY,
	[FirstName] NVARCHAR(100) NOT NULL,
	[LastName] NVARCHAR(100) NOT NULL,
	[Email] NVARCHAR(255) UNIQUE NOT NULL,
	[DateOfBirth] DATE NOT NULL,
	[MembershipDate] DATE NOT NULL
);

CREATE TABLE [Books] (
	[BookID] INT IDENTITY(1,1) PRIMARY KEY,
	[Title] NVARCHAR(255) NOT NULL,
	[Author] NVARCHAR(255) NOT NULL,
	[ISBN] NVARCHAR(20) UNIQUE NOT NULL,
	[PublishedDate] DATE NOT NULL,
	[ShelfLocation] NVARCHAR(100) NOT NULL
);

CREATE TABLE [loans] (
	[LoanID] INT IDENTITY(1,1) PRIMARY KEY,
	[BookID] INT NOT NULL,
	[BorrowerID] INT NOT NULL,
	[DateBorrowed] DATE NOT NULL,
	[DueDate] DATE NOT NULL,
	[DateReturned] DATE, -- null if book is not returned yet
    FOREIGN KEY (BookID) REFERENCES Books(BookID),
    FOREIGN KEY (BorrowerID) REFERENCES Borrowers(BorrowerID)
);

CREATE TABLE [Genres] (
    [GenreID] INT IDENTITY(1,1) PRIMARY KEY,
    [Name] NVARCHAR(100) NOT NULL
);

CREATE TABLE [BookGenres] (
    [BookID] INT NOT NULL,
    [GenreID] INT NOT NULL,
    PRIMARY KEY (BookID, GenreID),
    FOREIGN KEY (BookID) REFERENCES Books(BookID),
    FOREIGN KEY (GenreID) REFERENCES Genres(GenreID)
);
