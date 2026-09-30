# **Library Management System: Database Project**

## **Background**
A local library is moving from manual book-keeping to a more efficient digital system. The aim is to design a database that supports day-to-day library operations, such as tracking books, borrowers, loans, and providing insights into borrowing trends to make informed decisions.

## **Objective**
The objective is to design and implement a relational database using **MS SQL** that manages the library's data and offers the ability to query various aspects of operations, such as borrowing trends, overdue loans, and book availability.

## **Project Structure**
The project is organized as follows:
1. **Database Design**: Entity Relationship Model (ERM) Diagram.
2. **Schema Creation**: MS SQL scripts to define tables and relationships.
3. **Data Population**: Scripts to seed the database with sample data.
4. **Advanced Queries and Procedures**: Complex SQL queries, stored procedures, triggers, and functions to manage and analyze the library’s data.

## **Database Schema**

### **1. Entity-Relationship Model (ERM)**
The library database is modeled using three main entities: **Books**, **Borrowers**, and **Loans**. An ER diagram visually represents the relationships between them:

- **Books**: Contains information about each book.
- **Borrowers**: Stores borrower details.
- **Loans**: Tracks borrowing activities.

The **Books** and **Borrowers** entities have a **many-to-many relationship** through the **Loans** entity, as a book can be borrowed by multiple borrowers, and each borrower can borrow multiple books.

### **2. Relational Schema**

### **Books Table**
```sql
CREATE TABLE Books ( 
  BookID int PRIMARY KEY IDENTITY(1,1),
  Title varchar(255) NOT NULL,
  Author varchar(255) NOT NULL,
  ISBN varchar(13) NOT NULL UNIQUE,
  PublishedDate DATE,
  Genre varchar(100),
  ShelfLocation varchar(10),
  CurrentStatus varchar(25) NOT NULL CHECK (CurrentStatus IN ('Available', 'Borrowed'))
);
```

### **Rationale**:
- **BookID**: A primary key, generated automatically via `IDENTITY`, ensures that each book is uniquely identified.
- **Title & Author**: These fields store the book's title and author and are mandatory as they are essential for cataloging and searching the library's collection.
- **ISBN**: This field stores the book’s International Standard Book Number (ISBN), which is unique across all books. A `UNIQUE` constraint ensures no duplicates exist, which is critical for accurate identification of specific editions.
- **PublishedDate**: Tracks the date when the book was first published, useful for sorting and querying based on release periods.
- **Genre**: An optional field that categorizes the book based on its genre (e.g., Fiction, Non-fiction), enabling easier filtering based on reading preferences.
- **ShelfLocation**: Indicates where the book is physically located within the library, aiding staff in finding the books.
- **CurrentStatus**: This field indicates whether the book is 'Available' or 'Borrowed'. The `CHECK` constraint ensures that only valid statuses can be stored, preventing invalid entries. This status is vital for tracking availability without needing to query loan records constantly.

---

### **Borrowers Table**
```sql
CREATE TABLE Borrowers(
  BorrowerID int IDENTITY(1,1) PRIMARY KEY,
  FirstName varchar(50) NOT NULL,
  LastName varchar(50) NOT NULL,
  Email varchar(255) NOT NULL UNIQUE,
  DateOfBirth DATE,
  MembershipDate DATE NOT NULL
);
```

### **Rationale**:
- **BorrowerID**: The primary key generated automatically via `IDENTITY`, uniquely identifies each borrower in the system.
- **FirstName & LastName**: These are mandatory fields, storing the borrower’s first and last name, which are essential for identification and communication purposes.
- **Email**: A `UNIQUE` constraint on the email ensures that no two borrowers can share the same email address, allowing it to serve as a secondary identifier for borrowers and preventing duplicate accounts.
- **DateOfBirth**: This optional field records the borrower’s date of birth, enabling the library to categorize borrowers by age group and offer insights into borrower demographics. It can also assist with implementing age-based rules or promotions.
- **MembershipDate**: This is a mandatory field, marking when the borrower became a library member. It allows the system to track the length of membership, which can be useful for generating reports or rewarding long-term members.

---

### **Loans Table**
```sql
CREATE TABLE Loans(
  LoanID INT IDENTITY(1,1) PRIMARY KEY,
  BookID INT NOT NULL,
  BorrowerID INT NOT NULL,
  DateBorrowed DATE NOT NULL,
  DueDate DATE NOT NULL,
  DateReturned DATE,
  FOREIGN KEY(BookID) REFERENCES Books(BookID),
  FOREIGN KEY(BorrowerID) REFERENCES Borrowers(BorrowerID),
  CONSTRAINT CHK_DueDate CHECK (DueDate >= DateBorrowed),
  CONSTRAINT CHK_DateReturned CHECK (DateReturned IS NULL OR DateReturned >= DateBorrowed)
);
```

### **Rationale**:
- **LoanID**: This is an auto-incrementing primary key, ensuring each loan record is unique.
- **BookID & BorrowerID**: These columns store foreign keys that reference the **Books** and **Borrowers** tables respectively, enforcing referential integrity. This ensures that only valid books and borrowers can be involved in loans.
- **DateBorrowed**: This is the date when the book was borrowed, which is mandatory for each loan record.
- **DueDate**: This field stores the date when the book should be returned. The `CHECK` constraint ensures that the **DueDate** is always greater than or equal to **DateBorrowed**, preventing invalid data entries where a book's due date would be before its borrowing date.
- **DateReturned**: This column records the actual return date of the book. The constraint `CHK_DateReturned` ensures that the return date is either **NULL** (if the book hasn't been returned) or later than the borrowing date, avoiding logical inconsistencies where a book is returned before it was borrowed.
- **Constraints**: The `CHECK` constraints ensure data integrity by maintaining logical consistency in the date relationships. This helps avoid mistakes where a book is returned before it was borrowed or due, keeping the loan record accurate.

---

### **3. Data Seeding**
To populate the tables with meaningful data, we generated:
- **1000 Books**, each with a unique ISBN, author, genre, and publication date.
- **1000 Borrowers**, complete with names, email addresses, and membership dates.
- **1000 Loan records**, detailing borrower-book relationships, loan dates, and return statuses.

The sample data script is located in the repository under `SeedingDMLs`.

---

## **Advanced Queries and Procedures**

### **1. List of Borrowed Books**
```sql
SELECT Books.Title, Books.Author, Loans.DateBorrowed, Loans.DateReturned
FROM Loans
JOIN Books ON Loans.BookID = Books.BookID
WHERE Loans.BorrowerID = @BorrowerID AND Loans.DateReturned IS NULL;
```
- **Rationale**: This query retrieves all books borrowed by a specific borrower that have not yet been returned.

---

### **2. Active Borrowers Report**
```sql
WITH ActiveBorrowers AS (
    SELECT BorrowerID, COUNT(LoanID) AS BorrowCount
    FROM Loans
    WHERE DateReturned IS NULL
    GROUP BY BorrowerID
)
SELECT Borrowers.*, BorrowCount
FROM Borrowers 
JOIN ActiveBorrowers ON ActiveBorrowers.BorrowerID = Borrowers.BorrowerID
WHERE BorrowCount >= 2;
```
- **Rationale**: This query lists all borrowers who currently have two or more books that have not yet been returned.

---

### **3. Book Borrowing Frequency Using Window Functions**
```sql
WITH BorrowedCounts AS (
    SELECT BorrowerID, COUNT(LoanID) AS BorrowCount
    FROM Loans
    GROUP BY BorrowerID
)
SELECT (Borrowers.FirstName +' '+ Borrowers.LastName) AS FullName , BorrowCount,
       DENSE_RANK() OVER (ORDER BY BorrowCount DESC) AS BorrowingRank
FROM Borrowers 
JOIN BorrowedCounts ON BorrowedCounts.BorrowerID = Borrowers.BorrowerID;
```
- **Rationale**: This query Rank borrowers based on borrowing frequency.

---

### **4. Popular Genre Analysis Using Joins**
```sql
DECLARE @DateBorrowed int= 1;
WITH MonthlyGenreCount AS(
 SELECT Genre , COUNT(LoanID) AS GenreCount
 FROM Loans
 JOIN Books ON (Books.BookID = Loans.BookID)
 WHERE MONTH(DateBorrowed) = @DateBorrowed and Genre <> '(no genres listed)'
 GROUP BY Genre
)
 SELECT Genre , GenreCount ,
 DENSE_RANK() OVER (ORDER BY GenreCount DESC) AS GenreRank
 FROM MonthlyGenreCount;
```
- **Rationale**: The query analyzes which genre was most borrowed in a specific month.

---

### **5. Stored Procedure - Add New Borrowers**
```sql
CREATE PROCEDURE sp_AddNewBorrower
    @FirstName NVARCHAR(50),
    @LastName NVARCHAR(50),
    @Email NVARCHAR(100),
    @DateOfBirth DATE,
    @MembershipDate DATE
AS
BEGIN
    IF EXISTS (SELECT Email FROM Borrowers WHERE Email = @Email)
    BEGIN
        RAISERROR ('Email already exists', 16,1);
    END
    ELSE
    BEGIN
        INSERT INTO Borrowers (FirstName, LastName, Email, DateOfBirth, MembershipDate)
        VALUES (@FirstName, @LastName, @Email, @DateOfBirth, @MembershipDate);	
        SELECT SCOPE_IDENTITY() AS NewBorrowerID;
    END
END;

EXEC dbo.sp_AddNewBorrower 'Sami',	'Youthead',	'Samiyouthead0@sohu.com',	'9/13/2024',	'5/12/2024';
```
- **Rationale**: This procedure ensures a new borrower can only be added if their email doesn't already exist, returning their `BorrowerID` if successful.

---

### **6. Database Function - Calculate Overdue Fees**
```sql
CREATE FUNCTION fn_CalculateOverdueFees (
    @LoanID INT
) 
RETURNS DECIMAL(10,3) 
AS
BEGIN
    DECLARE @Fees DECIMAL(10,3), @DaysOverdue INT;

    SELECT @DaysOverdue = DATEDIFF(DAY, DueDate, ISNULL(DateReturned, GETDATE()))
    FROM Loans 
    WHERE LoanID = @LoanID;

    IF @DaysOverdue <= 30
        SET @Fees = @DaysOverdue;
    ELSE
        SET @Fees = @DaysOverdue + (@DaysOverdue - 30) * 2;

    RETURN @Fees;
END;

SELECT Loans.*, dbo.fn_CalculateOverdueFees(LoanID)  AS OverdueFees
FROM Loans;
```
- **Rationale**: This function calculates overdue fees based on the number of days a book is overdue. If overdue for more than 30 days, the fine rate doubles.

---

### **7. Book Borrowing Frequency Function**
```sql
CREATE FUNCTION fn_BookBorrowingFrequency (
  @BookID INT
) RETURNS INT AS
BEGIN
 DECLARE @BookBorrowingFrequency INT;
 SELECT @BookBorrowingFrequency = COUNT(BookID) 
 FROM Loans 
 WHERE BookID = @BookID
 GROUP BY BookID;
 RETURN @BookBorrowingFrequency;
END;

-- Example Query
SELECT Title, ISNULL(dbo.fn_BookBorrowingFrequency(BookID), 0) AS BookBorrowingFrequency
FROM Books
ORDER BY BookBorrowingFrequency DESC;
```
- **Rationale**: This function calculates how many times a specific book has been borrowed.

---

### **8. Overdue Books Report**
```sql
SELECT Title AS BookTitle, DATEDIFF(DAY, DueDate, ISNULL(DateReturned, GETDATE())) AS DaysOverdue, Borrowers.*
FROM Books
JOIN Loans ON Books.BookID = Loans.BookID
JOIN Borrowers ON Borrowers.BorrowerID = Loans.BorrowerID
WHERE DATEDIFF(DAY, DueDate, ISNULL(DateReturned, GETDATE())) > 30;
```
- **Rationale**: This query lists all books that are overdue by more than 30 days along with borrower details.

---

### **9. Author Popularity Report**
```sql
WITH AuthorBooksBorrowings AS (
 SELECT Author, SUM(ISNULL(dbo.fn_BookBorrowingFrequency(BookID), 0)) AS TotalAuthorBooksBorrowings
 FROM Books
 GROUP BY Author
)
SELECT Author, TotalAuthorBooksBorrowings,
 DENSE_RANK() OVER (ORDER BY TotalAuthorBooksBorrowings DESC) AS AuthorRank
FROM AuthorBooksBorrowings;
```
- **Rationale**: This query ranks authors based on the total number of their books borrowed.

---

### **10. Age Group Classification Function**
```sql
CREATE FUNCTION fn_GetAgeGroup (
 @DateOfBirth DATE
) RETURNS VARCHAR(10) AS
BEGIN
  DECLARE @Age INT;
  DECLARE @AgeGroup VARCHAR(10);

  SET @Age = DATEDIFF(YEAR, @DateOfBirth, GETDATE());
  SET @AgeGroup = CASE 
                    WHEN @Age BETWEEN 0 AND 10 THEN '[0, 10]'
                    WHEN @Age BETWEEN 11 AND 20 THEN '[11, 20]'
                    WHEN @Age BETWEEN 21 AND 30 THEN '[21, 30]'
                    WHEN @Age BETWEEN 31 AND 40 THEN '[31, 40]'
                    WHEN @Age BETWEEN 41 AND 50 THEN '[41, 50]'
                    WHEN @Age BETWEEN 51 AND 60 THEN '[51, 60]'
                    ELSE '60+'
                  END;
  
  RETURN @AgeGroup;
END;
```
- **Rationale**: This function categorizes borrowers into age groups based on their date of birth.

---

### **11. Popular Genre by Age Group Query**
```sql
WITH AgeGroupGenre AS (
 SELECT Genre, dbo.fn_GetAgeGroup(DateOfBirth) AS AgeGroup
 FROM Borrowers
 JOIN Loans ON Borrowers.BorrowerID = Loans.BorrowerID
 JOIN Books ON Loans.BookID = Books.BookID
)
SELECT AgeGroup, Genre
FROM AgeGroupGenre
GROUP BY AgeGroup, Genre
HAVING COUNT(Genre) = (
    SELECT MAX(GenreCount)
    FROM (
        SELECT Genre, COUNT(Genre) AS GenreCount
        FROM AgeGroupGenre ag
        WHERE ag.AgeGroup = AgeGroupGenre.AgeGroup
        GROUP BY Genre
    ) AS GenreCounts
)
ORDER BY AgeGroup;
```
- **Rationale**: This query finds the most popular book genre for each age group based on borrowing trends.

---

### **12. Borrowed Books Report Procedure**
```sql
CREATE PROCEDURE sp_BorrowedBooksReport (
 @StartDate DATE,
 @EndDate DATE
) AS
BEGIN 
 SELECT Books.Title, Loans.*, Borrowers.FirstName + ' ' + Borrowers.LastName AS FullName
 FROM Books
 JOIN Loans ON Books.BookID = Loans.BookID
 JOIN Borrowers ON Borrowers.BorrowerID = Loans.BorrowerID
 WHERE DateBorrowed >= @StartDate AND DateBorrowed <= @EndDate
 ORDER BY DateBorrowed;
END;

EXEC sp_BorrowedBooksReport '2024-01-01', '2024-01-31';
```
- **Rationale**: This procedure allows the library to generate a report of all books borrowed within a specified date range, displaying relevant borrower and loan details.

---

### **13. Trigger Implementation**
```sql
CREATE TABLE AuditLog (
    AuditID int IDENTITY(1,1) PRIMARY KEY,
    BookID int NOT NULL,
    StatusChange varchar(100) NOT NULL,
    ChangeDate DATETIME NOT NULL DEFAULT GETDATE()
);

CREATE TRIGGER trg_BookStatusChange
ON Books AFTER UPDATE
AS
BEGIN
    IF EXISTS (
        SELECT * 
        FROM inserted i
        JOIN deleted d ON i.BookID = d.BookID
        WHERE i.CurrentStatus <> d.CurrentStatus
    )
    BEGIN
        INSERT INTO AuditLog (BookID, StatusChange)
        SELECT i.BookID, CONCAT('Changed from ', d.CurrentStatus, ' to ', i.CurrentStatus)
        FROM inserted i
        JOIN deleted d ON i.BookID = d.BookID
        WHERE i.CurrentStatus <> d.CurrentStatus;
    END
END;


UPDATE BOOKS
SET CurrentStatus = 'Borrowed'
WHERE BookID=1;
```
- **Rationale**: This trigger logs any status change in the `Books` table (e.g., from "Available" to "Borrowed").

---

### **14. SQL Stored Procedure with Temp Table**
```sql
CREATE PROCEDURE sp_GetOverdueBorrowers
AS
BEGIN
    CREATE TABLE #TempOverdueBorrowers (
        BorrowerID int,
		BookID int,
		LoanID int,
        FirstName varchar(50),
        LastName varchar(50)
    );

    INSERT INTO #TempOverdueBorrowers (BorrowerID ,BookID, LoanID, FirstName, LastName)
    SELECT b.BorrowerID, L.BookID, L.LoanID, b.FirstName , b.LastName 
    FROM Borrowers b
    JOIN Loans l ON b.BorrowerID = l.BorrowerID
    WHERE l.DueDate < GETDATE() AND l.DateReturned IS NULL;

    SELECT tob.BorrowerID, tob.FirstName+ ' '+ tob.LastName AS FullName, tob.BookID, bo.Title, l.DueDate
    FROM #TempOverdueBorrowers tob
    JOIN Loans l ON tob.LoanID = l.LoanID
    JOIN Books bo ON l.BookID = bo.BookID
	ORDER BY BorrowerID

    DROP TABLE #TempOverdueBorrowers;
END;

EXEC sp_GetOverdueBorrowers;
```
- **Rationale**: This stored procedure retrieves borrowers with overdue books, temporarily storing them in a temp table before joining with other data to generate a report.

---

### **15. Borrowing Trends by Day of the Week**
```sql
SELECT TOP 3 
    DATENAME(WEEKDAY, DateBorrowed) AS LoanDay,
    COUNT(*) * 100.0 / (SELECT COUNT(*) FROM Loans) AS PercentageOfLoans
FROM Loans
GROUP BY DATENAME(WEEKDAY, DateBorrowed)
ORDER BY COUNT(*) DESC;
```
- **Rationale**: This query returns the top 3 days of the week when most books were borrowed, along with their percentage of total loans.
