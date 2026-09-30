DECLARE @BorrowerID int=999;

SELECT B.Title, B.Author, L.DateBorrowed, L.DateReturned
FROM Loans L
JOIN Books B ON L.BookID = B.BookID
WHERE L.BorrowerID = @BorrowerID;

