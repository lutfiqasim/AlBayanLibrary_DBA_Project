USE AlBayan_Library;

-- Lotfi,
--I decided to use column encryption in the Member table for the ContactNumber column.
-- I chose the common approach of DMK -> certificate -> symmetric key -> column data.
-- Reasons for using this encryption:
/*
1. Ease of implementation: The common approach is easier to implement compared to asymmetric key encryption as it uses a single encryption key for both encryption and decryption.
2. Performance: Symmetric encryption algorithms are typically faster than asymmetric keys encryption. As I have decided to encrypt the ContactNumber column, which will be accessed frequently in the database, we need a fast decryption method.
*/

-- Step 1: Create Data Master Key (DMK)
CREATE MASTER KEY ENCRYPTION BY PASSWORD = '1111'; 

-- Step 2: Create a certificate protected with DMK
CREATE CERTIFICATE contactNumberCertificate WITH SUBJECT = 'Contact Number'; 

-- Step 3: Create a symmetric key protected by the certificate
-- Note: The symmetric key is protected by the certificate 'contactNumberCertificate'
--       The algorithm AES_256 is the default
CREATE SYMMETRIC KEY contactNumberSymmetricKey
WITH ALGORITHM = AES_256
ENCRYPTION BY CERTIFICATE contactNumberCertificate;

-- Step 4: Open the symmetric key before encrypting or decrypting
OPEN SYMMETRIC KEY contactNumberSymmetricKey
    DECRYPTION BY CERTIFICATE contactNumberCertificate;

-- Update already entered data into Member
UPDATE Member
SET ContactNumber = ENCRYPTBYKEY(KEY_GUID('contactNumberSymmetricKey'), CONVERT(VARBINARY(256), ContactNumber));

-- Close the symmetric key
CLOSE SYMMETRIC KEY contactNumberSymmetricKey;

-- For decryption
OPEN SYMMETRIC KEY contactNumberSymmetricKey
    DECRYPTION BY CERTIFICATE contactNumberCertificate;

SELECT *,
       CAST(DECRYPTBYKEY(ContactNumber) AS VARCHAR(20)) AS ContactNumber
FROM Member;

CLOSE SYMMETRIC KEY contactNumberSymmetricKey;

-- Instead of trigger for inserting data into Member to encrypt it
GO
CREATE TRIGGER insertEncryptedMember
ON Member
INSTEAD OF INSERT 
AS
BEGIN
    OPEN SYMMETRIC KEY contactNumberSymmetricKey
        DECRYPTION BY CERTIFICATE contactNumberCertificate; 
    
    INSERT INTO Member (Name, Address, ContactNumber, Email)
    SELECT Name, Address, ENCRYPTBYKEY(KEY_GUID('contactNumberSymmetricKey'), CONVERT(VARBINARY(256), ContactNumber)), Email
    FROM inserted;
    
    CLOSE SYMMETRIC KEY contactNumberSymmetricKey;
END;


INSERT INTO Member (Name, Address, ContactNumber, Email)
VALUES ('ahmads', 'Birzeit', CONVERT(VARBINARY(256), '0569999889'), 'ahmad@gmail.com');

SELECT * FROM Member;

--DROP Trigger insertEncryptedMember;
--Seeing values of contact number
OPEN SYMMETRIC KEY contactNumberSymmetricKey
    DECRYPTION BY CERTIFICATE contactNumberCertificate;
--Note running with closed key returns value null

SELECT *,
       CAST(DECRYPTBYKEY(ContactNumber) AS VARCHAR(20)) AS DecryptedContactNumber
FROM Member;

CLOSE SYMMETRIC KEY contactNumberSymmetricKey;

-- Populate Member table
INSERT INTO Member (Name, Address, ContactNumber, Email)
VALUES ('John Doe', '123 Main Street', CONVERT(VARBINARY(256),'555-1234'), 'johndoe@example.com'),
       ('Jane Smith', '456 Elm Avenue', CONVERT(VARBINARY(256),'555-5678'), 'janesmith@example.com'),
       ('Michael Johnson', '789 Oak Drive',CONVERT(VARBINARY(256), '555-9012'), 'michaeljohnson@example.com');