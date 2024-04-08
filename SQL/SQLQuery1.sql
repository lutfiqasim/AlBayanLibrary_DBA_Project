USE AlBayan_Library;

-- Populate Branch table
INSERT INTO Branch (Location)
VALUES ('Ramallah'), ('Amman'), ('Dubai');

-- Populate Staff table
INSERT INTO Staff (Name, Position, BranchID)
VALUES ('Mohammad haj', 'Staff Position 1', 1),
       ('Ahmad Ali', 'Staff Position 2', 2),
       ('Mike Mike', 'Staff Position 1', 3);

-- Populate BranchManager table
INSERT INTO BranchManager (StaffID)
VALUES (1), (2), (3);

-- Populate Supervisor table
INSERT INTO Supervisor (StaffID, BranchID)
VALUES (1, 1), (2, 2),(3,3);

-- Populate Book table
SELECt * from Book;
INSERT INTO Book (ISBN, BookNumber, BranchID,Copies,Name)
VALUES ('978-0439064873', 'HP001', 1,100,'Romeo and Joliate'),
       ('978-0545010221', 'TW001', 2,5,'C# programming'),
       ('978-0061120084', 'HG001', 3,1,'JAVA');




-- Populate Rental table with RentalDate as current date and DueDate as 14 days after RentalDate
INSERT INTO Rental (MemberID, BookID, RentalDate, DueDate, ReturnDate, LateFees)
VALUES (1, 1, GETDATE(), DATEADD(DAY, 14, GETDATE()), NULL, NULL),
       (2, 2, GETDATE(), DATEADD(DAY, 14, GETDATE()), NULL, NULL),
       (3, 3, GETDATE(), DATEADD(DAY, 14, GETDATE()), NULL, NULL);

-- Populate Feedback table
INSERT INTO Feedback (MemberID, BookID, Rating, Comment)
VALUES (1, 1, 4, 'Great book!'),
       (2, 2, 3, 'Average book'),
       (3, 3, 5, 'Excellent book');

	   Select * from Staff;

--Populating the staffHistory table
Insert into Staff (Name,Position,BranchID)
VALUES ('Lotfi Qasim','Computer Specialist ',1);
UPDATE Staff set Position = 'Associate Conservator' where Staff.StaffId = 1;
UPDATE Staff set Position = 'Automation Specialist' where Staff.StaffId = 2;
UPDATE Staff set Position = 'Library Aide' where Staff.StaffId = 3;

Select * from dbo.StaffHistory;
Select * from dbo.Staff;