# Design

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

## Relationships

- A book can be used in many loans, and a loan is for exactly one book.
- A borrower can have many loans, and a loan is for exactly one borrower.
