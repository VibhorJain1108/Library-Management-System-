CREATE PROCEDURE sp_BorrowedBooksReport (
 @StartDate Date,
 @EndDate Date
) AS
BEGIN 
 SELECT Books.Title , Loans.*,Borrowers.FirstName +' ' + Borrowers.LastName AS FullName
 FROM Books
 JOIN Loans ON Books.BookID = Loans.BookID
 JOIN Borrowers ON Borrowers.BorrowerID = Loans.BorrowerID
 WHERE DateBorrowed >= @StartDate AND DateBorrowed <= @EndDate
 ORDER BY DateBorrowed;
END;


EXEC sp_BorrowedBooksReport '2024-1-1','2024-1-31'