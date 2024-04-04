# Design

## ER Diagram

![ER Diagram](Entity%20Relationship%20Diagram.png)

## Relational Schema

![RS Diagram](Relational%20Schema%20Diagram.png)

## Entities

- Books:
  - BookID (PK)
  - Title
  - Author
  - ISBN
  - Published Date
  - Genre
  - Shelf Location
  - Current Status ('Available' or 'Borrowed')

- Borrowers:
  - BorrowerID (PK)
  - First Name
  - Last Name
  - Email
  - Date of Birth
  - Membership Date

- Loans:
  - LoanID (PK)
  - BookID (FK)
  - BorrowerID (FK)
  - Date Borrowed
  - Due Date
  - Date Returned (NULL if not returned yet)

- Genres:
  - GenreID (PK)
  - Name

- BookGenres:
  - BookID (PK,FK)
  - GenreID (PK,FK)

## Relationships

- A book can be used in many loans, and a loan is for exactly one book.
- A borrower can have many loans, and a loan is for exactly one borrower.
- A book can have one or more genres, a genre can be for zero or more books, BookGenres is the linking table.

## Choices

- Current status of book is derived from loans (whether a book is currently borrowed).
- Loan due date is not derived, this allows for more flexibility in the loaning logic.
- Books can have many genres not just one, this makes more sense for real libraries.
