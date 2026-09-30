CREATE TABLE AuditLog (
    AuditID int IDENTITY(1,1) PRIMARY KEY,
    BookID int NOT NULL,
    StatusChange varchar(100) NOT NULL,
    ChangeDate DATETIME NOT NULL DEFAULT GETDATE()
);

CREATE TRIGGER trg_BookStatusChange
ON Books AFTER UPDATE
AS
BEGIN
    IF EXISTS (
        SELECT * 
        FROM inserted i
        JOIN deleted d ON i.BookID = d.BookID
        WHERE i.CurrentStatus <> d.CurrentStatus
    )
    BEGIN
        INSERT INTO AuditLog (BookID, StatusChange)
        SELECT i.BookID, CONCAT('Changed from ', d.CurrentStatus, ' to ', i.CurrentStatus)
        FROM inserted i
        JOIN deleted d ON i.BookID = d.BookID
        WHERE i.CurrentStatus <> d.CurrentStatus;
    END
END;


UPDATE BOOKS
SET CurrentStatus = 'Borrowed'
WHERE BookID=1;

