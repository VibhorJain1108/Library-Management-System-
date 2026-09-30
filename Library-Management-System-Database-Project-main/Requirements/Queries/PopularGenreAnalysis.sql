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