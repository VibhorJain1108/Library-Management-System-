SELECT Title AS BookTitle, DATEDIFF(DAY, DueDate, ISNULL(DateReturned,GETDATE()) ) AS DaysOverdue , Borrowers.*
FROM Books
JOIN Loans ON Books.BookID = Loans.BookID
JOIN Borrowers ON Borrowers.BorrowerID = Loans.BorrowerID
WHERE DATEDIFF(DAY, DueDate, ISNULL(DateReturned,GETDATE()) ) > 30;