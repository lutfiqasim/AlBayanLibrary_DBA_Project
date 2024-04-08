USE AlBayan_Library;
EXECUTE sp_addrole @rolename = 'BranchManager';
EXECUTE sp_addrole @rolename = 'Supervisor';
EXECUTE sp_addrole @rolename = 'Staff';
EXECUTE sp_addrole @rolename = 'Administrator';
EXECUTE sp_addrole @rolename = 'Member';

SELECT *
FROM sys.database_principals
WHERE type = 'R' AND is_fixed_role = 0;

/--Permissions to give still not excecuted need to be revisited and checked
-- Grant permissions to Branch Manager role
GRANT SELECT, INSERT, UPDATE, DELETE ON dbo.Branch TO BranchManager;
--GRANT EXECUTE ON dbo.StoredProc TO BranchManager;

-- Grant permissions to Supervisor role
GRANT SELECT, UPDATE ON dbo.Staff TO Supervisor;

-- Grant permissions to Staff role
GRANT SELECT, INSERT, UPDATE ON dbo.Member TO Staff;
-- Add more permissions as needed

-- Grant permissions to Member role
GRANT SELECT, INSERT, UPDATE ON dbo.Rental TO Member;
Revoke Select,Insert,Update On dbo.Rental from Member;
GRANT execute on dbo.BorrowBook TO Member;
GRANT execute on dbo.ReturnBook TO Member;

-- Grant permissions to Administrator role
-- Grant all privileges on the Branch table
GRANT ALL PRIVILEGES ON Branch TO Administrator with Grant Option;

-- Grant all privileges on the Staff table
GRANT ALL PRIVILEGES ON Staff TO Administrator with Grant Option;

-- Grant all privileges on the BranchManager table
GRANT ALL PRIVILEGES ON BranchManager TO Administrator with Grant Option;

-- Grant all privileges on the Supervisor table
GRANT ALL PRIVILEGES ON Supervisor TO Administrator with Grant Option;

-- Grant all privileges on the Book table
GRANT ALL PRIVILEGES ON Book TO Administrator with Grant Option;

-- Grant all privileges on the Member table
GRANT ALL PRIVILEGES ON Member TO Administrator with Grant Option;

-- Grant all privileges on the Rental table
GRANT ALL PRIVILEGES ON Rental TO Administrator with Grant Option;

-- Grant all privileges on the Feedback table
GRANT ALL PRIVILEGES ON Feedback TO Administrator with Grant Option;

-- Grant all privileges on the StaffHistory table
GRANT ALL PRIVILEGES ON StaffHistory TO Administrator;
--Grant execute privliges on all stored procedure to Administrator
GRANT EXECUTE TO Administrator with Grant Option;