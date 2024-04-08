USE AlBayan_Library;
Select * from dbo.Staff;
--User 1
EXECUTE sp_addlogin @loginame =  'Lotfi Qasim', @passwd = '@passwd123';
EXECUTE sp_adduser 'Lotfi Qasim', 'lotfi';
execute sp_addrolemember @rolename = 'Administrator',@membername = 'lotfi';
--User 2
EXECUTE sp_addlogin @loginame = 'Mohmamad', @passwd = '@passwd123';
EXECUTE sp_adduser 'Mohmamad', 'Mohmamad';
execute sp_addrolemember @rolename = 'Staff',@membername = 'Mohmamad';
--User 3
EXECUTE sp_addlogin @loginame = 'Ali', @passwd = '@passwd123';
EXECUTE sp_adduser 'Ali', 'Ali';
execute sp_addrolemember @rolename = 'Member',@membername = 'Ali';
--User 4
EXECUTE sp_addlogin @loginame = 'amr', @passwd = '@passwd123';
EXECUTE sp_adduser 'amr', 'amr';
execute sp_addrolemember @rolename = 'Supervisor',@membername = 'amr';
--user 5
EXECUTE sp_addlogin @loginame = 'qusi', @passwd = '@passwd123';
EXECUTE sp_adduser 'qusi', 'qusi';
execute sp_addrolemember @rolename = 'BranchManager',@membername = 'qusi';
