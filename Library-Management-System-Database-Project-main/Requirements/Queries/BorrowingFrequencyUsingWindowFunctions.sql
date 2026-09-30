WITH BorrowedCounts AS (
    SELECT BorrowerID, COUNT(LoanID) AS BorrowCount
    FROM Loans
    GROUP BY BorrowerID
)
SELECT (Borrowers.FirstName +' '+ Borrowers.LastName) AS FullName , BorrowCount,
       DENSE_RANK() OVER (ORDER BY BorrowCount DESC) AS BorrowingRank
FROM Borrowers 
JOIN BorrowedCounts ON BorrowedCounts.BorrowerID = Borrowers.BorrowerID;

