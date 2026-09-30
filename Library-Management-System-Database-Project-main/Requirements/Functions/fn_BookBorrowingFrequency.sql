CREATE FUNCTION fn_BookBorrowingFrequency (
  @BookID int
) RETURNS INT AS
BEGIN
 DECLARE @BookBorrowingFrequency INT;
 SELECT @BookBorrowingFrequency = COUNT(BookID) 
                                  FROM Loans 
				  WHERE BookID = @BookID
				  Group By BookID;
 RETURN @BookBorrowingFrequency;
END;

SELECT Title, ISNULL(dbo.fn_BookBorrowingFrequency(BookId),0) AS BookBorrowingFrequency
FROM Books
ORDER BY BookBorrowingFrequency DESC;
