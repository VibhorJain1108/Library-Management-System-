SELECT TOP(3) 
    DATENAME(WEEKDAY, DateBorrowed) AS LoanDay,
    COUNT(*) * 100.0 / (SELECT COUNT(*) FROM Loans) AS PercentageOfLoans
FROM Loans
GROUP BY DATENAME(WEEKDAY, DateBorrowed)
ORDER BY COUNT(*) DESC;
