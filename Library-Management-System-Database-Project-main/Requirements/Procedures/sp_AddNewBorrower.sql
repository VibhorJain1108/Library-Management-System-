CREATE PROCEDURE sp_AddNewBorrower
    @FirstName NVARCHAR(50),
    @LastName NVARCHAR(50),
    @Email NVARCHAR(100),
    @DateOfBirth DATE,
    @MembershipDate DATE
AS
BEGIN
    IF EXISTS (SELECT Email FROM Borrowers WHERE Email = @Email)
    BEGIN
        RAISERROR ('Email already exists', 16,1);
    END
    ELSE
    BEGIN
        INSERT INTO Borrowers (FirstName, LastName, Email, DateOfBirth, MembershipDate)
        VALUES (@FirstName, @LastName, @Email, @DateOfBirth, @MembershipDate);	
        SELECT SCOPE_IDENTITY() AS NewBorrowerID;
    END
END;

EXEC dbo.sp_AddNewBorrower 'Sami',	'Youthead',	'Samiyouthead0@sohu.com',	'9/13/2024',	'5/12/2024';


