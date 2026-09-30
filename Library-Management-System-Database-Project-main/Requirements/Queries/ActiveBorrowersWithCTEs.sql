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
