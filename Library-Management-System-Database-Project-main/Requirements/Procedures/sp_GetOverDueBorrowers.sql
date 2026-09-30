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