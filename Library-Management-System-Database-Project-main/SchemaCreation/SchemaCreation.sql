CREATE TABLE Books ( 
  BookID int PRIMARY KEY IDENTITY(1,1),
  Title varchar(255) NOT NULL,
  Author varchar(255) NOT NULL,
  ISBN varchar(13) NOT NULL UNIQUE,
  PublishedDate DATE,
  Genre varchar(100),
  ShelfLocation varchar(10),
  CurrentStatus varchar(25) NOT NULL CHECK( CurrentStatus IN ('Available', 'Borrowed'))
);

CREATE TABLE Borrowers(
  BorrowerID int IDENTITY(1,1) PRIMARY KEY,
  FirstName varchar(50) NOT NULL,
  LastName varchar(50) NOT NULL,
  Email varchar(255) NOT NULL UNIQUE,
  DateOfBirth DATE,
  MembershipDate DATE NOT NULL
);

CREATE TABLE Loans(
  LoanID int IDENTITY(1,1) PRIMARY KEY,
  BookID int NOT NULL,
  BorrowerID int NOT NULL,
  DateBorrowed DATE NOT NULL,
  DueDate DATE NOT NULL,
  DateReturned DATE,
  FOREIGN KEY(BookID) REFERENCES Books(BookID),
  FOREIGN KEY(BorrowerID) REFERENCES Borrowers(BorrowerID),
  CONSTRAINT CHK_DueDate CHECK (DueDate >= DateBorrowed),
  CONSTRAINT CHK_DateReturned CHECK (DateReturned IS NULL OR DateReturned >= DateBorrowed)
);


