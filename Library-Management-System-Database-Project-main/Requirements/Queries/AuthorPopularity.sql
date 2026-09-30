WITH AuthorBooksBorrowengs AS(
 SELECT Author, SUM(ISNULL(dbo.fn_BookBorrowingFrequency(BookID),0)) AS TotalAuthorBooksBorrowengs
 FROM Books
 GROUP BY Author
)
SELECT Author ,TotalAuthorBooksBorrowengs,
 DENSE_RANK() OVER (ORDER BY TotalAuthorBooksBorrowengs DESC) AuthorRank
FROM AuthorBooksBorrowengs;