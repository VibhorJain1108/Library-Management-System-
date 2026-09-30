CREATE FUNCTION fn_GetAgeGroup (
 @DateOfBirth Date
) RETURNS VARCHAR(10) AS
BEGIN
  DECLARE @Age INT;
  DECLARE @AgeGroup VARCHAR(10);

  SET @Age = DATEDIFF(YEAR, @DateOfBirth, GETDATE());
  SET @AgeGroup = CASE 
                    WHEN @Age >=0 AND @Age <=10 THEN '[0, 10]'
                    WHEN @Age >=11 AND @Age <=20 THEN '[11, 20]'
                    WHEN @Age >=21 AND @Age <=30 THEN '[21, 30]'
                    WHEN @Age >=31 AND @Age <=40 THEN '[31, 40]'
                    WHEN @Age >=41 AND @Age <=50 THEN '[41, 50]'
                    WHEN @Age >=51 AND @Age <=60 THEN '[51, 60]'
					ELSE '60+'
				  END;
  
  RETURN @AgeGroup;
END;


WITH AgeGroupGenre AS (
 SELECT Genre, dbo.fn_GetAgeGroup(DateOfBirth) AS AgeGroup
 FROM Borrowers
 JOIN Loans ON Borrowers.BorrowerID = Loans.BorrowerID
 JOIN Books ON Loans.BookID = Books.BookID
)
SELECT AgeGroup ,Genre 
FROM AgeGroupGenre
GROUP BY AgeGroup ,Genre
HAVING COUNT(Genre) = (
    SELECT MAX(GenreCount)
    FROM (
        SELECT Genre,COUNT(Genre) AS GenreCount
        FROM AgeGroupGenre ag
        WHERE ag.AgeGroup = AgeGroupGenre.AgeGroup
        GROUP BY Genre
    ) AS GenreCounts
)
ORDER BY AgeGroup;

