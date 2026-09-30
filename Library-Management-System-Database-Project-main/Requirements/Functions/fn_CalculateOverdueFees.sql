CREATE FUNCTION fn_CalculateOverdueFees (
    @LoanID INT
) 
RETURNS DECIMAL(10,3) 
AS
BEGIN
    DECLARE @Fees DECIMAL(10,3), @DaysOverdue INT;

    SELECT @DaysOverdue = DATEDIFF(DAY, DueDate, ISNULL(DateReturned, GETDATE()))
    FROM Loans 
    WHERE LoanID = @LoanID;

    IF @DaysOverdue <= 30
        SET @Fees = @DaysOverdue;
    ELSE
        SET @Fees = @DaysOverdue + (@DaysOverdue - 30) * 2;

    RETURN @Fees;
END;

SELECT Loans.*, dbo.fn_CalculateOverdueFees(LoanID)  AS OverdueFees
FROM Loans;