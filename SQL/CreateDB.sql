--Created by Lotfi Qasim
--Student ID: 1202064
--Data base Administration Assginment
--Albayan Lirbrary
Drop DataBase if exists AlBayan_Library;
Create DataBase AlBayan_Library;

USE AlBayan_Library
-- For this database My assumptions were
--    Each staff member can only work in one branch.
--    Each branch has only one Branch Manager.
--    Each supervisor oversees multiple staff members within a branch.
--    Each book copy belongs to a specific branch.
--    Each member can borrow multiple books.
--    Each book can be borrowed by multiple members.
--    Each member can provide feedback for multiple books.
--    Each book can receive feedback from multiple members.

Create table Branch (
	BranchID INT IDENTITY(1,1) PRIMARY KEY,
	Location VARCHAR (50)
);

Create table Staff (
	StaffId INT IDENTITY(1,1) PRIMARY KEY,
	Name VARCHAR (50),
	Position VARCHAR (50),
	BranchID INT,
	CONSTRAINT fk_branch
		FOREIGN KEY (BranchID) REFERENCES Branch (BranchID)
);

Create table BranchManager(
	ManagerID INT IDENTITY(1,1) PRIMARY KEY,
	StaffID INT,
	CONSTRAINT fk_staff 
		FOREIGN KEY (StaffID) REFERENCES Staff (StaffID)
);

Create table Supervisor (
	SupervisorID int IDENTITY(1,1) PRIMARY KEY,
	StaffID INT,
	BranchID INT,
	CONSTRAINT fk_supervisor_staff
		FOREIGN KEY (StaffID) REFERENCES Staff (StaffID),
	CONSTRAINT fk_supervisor_branch
		FOREIGN KEY (BranchID) REFERENCES Branch (BranchID)
);

Create TABLE Book (
    BookID INT IDENTITY(1,1) PRIMARY KEY,
    ISBN VARCHAR(50),
    BookNumber VARCHAR(50),
    BranchID INT,
    CONSTRAINT fk_book_branch FOREIGN KEY (BranchID) REFERENCES Branch (BranchID)
);
ALTER TABLE Book
ADD Copies INT DEFAULT 1;
Select * from BOOK;
Alter TABLE BOOK
ADD Name VARCHAR (50);

Create table Member (
	MemberID INT IDENTITY(1,1) PRIMARY KEY,
	Name VARCHAR(50),
	Address VARCHAR (100),
	ContactNumber VARBINARY(256), -- most numbers are assumed to be at most 20 :)
	Email VARCHAR (50)
);

CREATE TABLE Rental (
    RentalID INT IDENTITY(1,1) PRIMARY KEY,
    MemberID INT,
    BookID INT,
    RentalDate DATE,
    DueDate DATE,
    ReturnDate DATE,
    LateFees DECIMAL(10, 2), --10 digits 2 of them in decimal decimal column to store the late fees charged for returning the book after the due date.
    CONSTRAINT fk_rental_member
        FOREIGN KEY (MemberID) REFERENCES Member (MemberID),
    CONSTRAINT fk_rental_book
        FOREIGN KEY (BookID) REFERENCES Book (BookID)
);


Create table Feedback (
    FeedbackID INT IDENTITY(1,1) PRIMARY KEY,
    MemberID INT,
    BookID INT,
    Rating INT, --  rating given by the member for the book.
    Comment VARCHAR(255), -- store any optional comments provided by the member for the book
    CONSTRAINT fk_feedback_member
        FOREIGN KEY (MemberID) REFERENCES Member (MemberID),
    CONSTRAINT fk_feedback_book
        FOREIGN KEY (BookID) REFERENCES Book (BookID)
);


--Implement a historical model to track all the modification happens in Albayan database. Each group member is required to produce two DML triggers.

--Logs for the track table
CREATE TABLE StaffHistory (
    HistoryID INT IDENTITY(1, 1) PRIMARY KEY,
    StaffID INT,
    Name VARCHAR(50),
    Position VARCHAR(50),
    BranchID INT,
    Operation VARCHAR(10),
    ModifiedDate DATETIME
);

CREATE TABLE BookHistory (
    HistoryID INT IDENTITY(1, 1) PRIMARY KEY,
    TableName VARCHAR(100),
    Operation VARCHAR(10),
    ModifiedDate DATETIME,
    BookID INT,
    ISBN VARCHAR(50),
    BookNumber VARCHAR(50),
    BranchID INT
);



-- Trigger 1: Capture INSERT operations on the Staff table
GO
CREATE TRIGGER Staff_InsertTrigger
ON Staff
AFTER INSERT
AS
BEGIN
    INSERT INTO StaffHistory (StaffID, Name, Position, BranchID, Operation, ModifiedDate)
    SELECT StaffID, Name, Position, BranchID, 'INSERT', GETDATE()
    FROM inserted;
END;

GO
-- Trigger 2: Capture UPDATE operations on the Staff table
CREATE TRIGGER Staff_UpdateTrigger
ON Staff
AFTER UPDATE
AS
BEGIN
    INSERT INTO StaffHistory (StaffID, Name, Position, BranchID, Operation, ModifiedDate)
    SELECT StaffID, Name, Position, BranchID, 'UPDATE', GETDATE()
    FROM deleted;
END;
Select * from dbo.StaffHistory;
-- Trigger 3 :for INSERT operation on the book table
CREATE TRIGGER Book_InsertTrigger
ON Book
AFTER INSERT
AS
BEGIN
    INSERT INTO BookHistory (TableName, Operation, ModifiedDate, BookID, ISBN, BookNumber, BranchID)
    SELECT 'Book', 'INSERT', GETDATE(), BookID, ISBN, BookNumber, BranchID
    FROM inserted;
END;

-- Trigger 4: for UPDATE operation on the book table
CREATE TRIGGER Book_InsertTrigger
ON Book
AFTER UPDATE
AS
BEGIN
    INSERT INTO BookHistory (TableName, Operation, ModifiedDate, BookID, ISBN, BookNumber, BranchID)
    SELECT 'Book', 'UPDATE', GETDATE(), Book.BookID, Book.ISBN, Book.BookNumber, Book.BranchID
    FROM inserted
    INNER JOIN Book ON inserted.BookID = Book.BookID;
END;

--  stored procedure for adding feedback with a check for existing feedback
CREATE PROCEDURE AddFeedback
    @MemberID INT,
    @BookID INT,
    @Rating INT,
    @Comment VARCHAR(255)
AS
BEGIN
    -- Check if feedback already exists for the same member and book
    IF EXISTS (
        SELECT 1
        FROM Feedback
        WHERE MemberID = @MemberID AND BookID = @BookID
    )
    BEGIN
        RAISERROR ('Feedback already exists for the same member and book.', 16, 1);
        RETURN;
    END

    -- Check if the rating is more than 5
    IF @Rating > 5
    BEGIN
        RAISERROR ('Invalid rating. Rating cannot be more than 5.', 16, 1);
        RETURN;
    END

    -- Insert the feedback into the Feedback table
    INSERT INTO Feedback (MemberID, BookID, Rating, Comment)
    VALUES (@MemberID, @BookID, @Rating, @Comment);
END;



--Stored procedure that allows Members to rent a book based on specified requirements
--
--
--
GO
CREATE PROCEDURE BorrowBook
    @MemberID INT,
    @BookID INT,
    @RentalDate DATE
AS
BEGIN
    -- Check if the member has reached the maximum limit of book rentals
    IF (SELECT COUNT(*) FROM Rental WHERE MemberID = @MemberID AND ReturnDate IS NULL) >= 5
    BEGIN
        RAISERROR('You have reached the maximum limit of book rentals.', 16, 1)
        RETURN
    END

    -- Check if the book is available for rental and has copies available
    IF EXISTS (
        SELECT *
        FROM Book
        WHERE BookID = @BookID
            AND BranchID IN (1, 2, 3)
            AND Copies > 0
            AND BookID NOT IN (SELECT BookID FROM Rental WHERE ReturnDate IS NULL)
    )
    BEGIN
        -- Decrement the number of copies for the borrowed book
        UPDATE Book
        SET Copies = Copies - 1
        WHERE BookID = @BookID

        -- Calculate the due date (14 days from the rental date)
        DECLARE @DueDate DATE
        SET @DueDate = DATEADD(DAY, 14, @RentalDate)

        -- Insert the rental record with initial LateFees of 0.0
        INSERT INTO Rental (MemberID, BookID, RentalDate, DueDate, LateFees)
        VALUES (@MemberID, @BookID, @RentalDate, @DueDate, 0.0)

        PRINT 'Book borrowed successfully.'
    END
    ELSE
    BEGIN
        RAISERROR('The requested book is not available for rental or has no copies available.', 16, 1)
        RETURN
    END

    -- Check for any overdue books and calculate late fees
    DECLARE @OverdueBooksCount INT, @LateFees DECIMAL(10, 2), @LateFeePerDay DECIMAL(10, 2)
    SELECT @OverdueBooksCount = COUNT(*)
    FROM Rental
    WHERE MemberID = @MemberID AND ReturnDate IS NULL AND DueDate < GETDATE()

    SET @LateFees = 0.0
    SET @LateFeePerDay = 2.0 -- Assuming a late fee of $2.00 per day for all books

    IF (@OverdueBooksCount > 0)
    BEGIN
        -- Calculate the late fees based on the number of late days and the fixed late fee per day
        SELECT @LateFees = @LateFeePerDay * DATEDIFF(DAY, DueDate, GETDATE())
        FROM Rental
        WHERE MemberID = @MemberID AND ReturnDate IS NULL AND DueDate < GETDATE()

        -- Update the LateFees column for overdue books
        UPDATE Rental
        SET LateFees = @LateFees
        WHERE MemberID = @MemberID AND ReturnDate IS NULL AND DueDate < GETDATE()

        PRINT 'You have ' + CAST(@OverdueBooksCount AS VARCHAR) + ' overdue book(s).'
        PRINT 'Late fees: $' + CAST(@LateFees AS VARCHAR)
    END
END




GO
--Rent a book
DECLARE @MemberID INT, @BookID INT, @RentalDate DATE;

-- Set the parameter values
SET @MemberID = 1; 
SET @BookID = 1; 
SET @RentalDate = GETDATE();

-- Call the stored procedure
EXECUTE BorrowBook @MemberID, @BookID, @RentalDate;

Select * From Rental;


--Return a book 
GO
Create PROCEDURE ReturnBook
    @RentalID INT
AS
BEGIN
    DECLARE @LateFees DECIMAL(10, 2)
    DECLARE @LateDays INT
    DECLARE @BookID INT

    -- Update the ReturnDate to the current date only if it is null
    UPDATE Rental
    SET ReturnDate = GETDATE()
    WHERE RentalID = @RentalID AND ReturnDate IS NULL

    -- Check if the ReturnDate was updated
    IF @@ROWCOUNT = 0
    BEGIN
        PRINT 'The book has already been returned.'
        RETURN
    END

    -- Retrieve the BookID associated with the rental
    SELECT @BookID = BookID
    FROM Rental
    WHERE RentalID = @RentalID

    -- Increment the number of copies for the returned book
    UPDATE Book
    SET Copies = Copies + 1
    WHERE BookID = @BookID

    -- Calculate the late fees
    SELECT @LateDays = DATEDIFF(DAY, DueDate, GETDATE())
    FROM Rental
    WHERE RentalID = @RentalID

    SET @LateFees = @LateDays * 2.0 -- Assuming a late fee of $2.00 per day

    -- Update the LateFees column
    IF (@LateFees > 0)
    BEGIN
        UPDATE Rental
        SET LateFees = @LateFees
        WHERE RentalID = @RentalID
        PRINT 'Late fees: $' + CAST(@LateFees AS VARCHAR)
    END
    ELSE
    BEGIN
        PRINT 'No Late fees'
    END
END

EXECUTE ReturnBook @RentalID = 1;
------------
------------