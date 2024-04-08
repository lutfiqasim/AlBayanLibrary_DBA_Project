USE AlBayan_Library;

-- amr,
--I decided to use columns encryption in the feedback table for the Rating column and comment column.
-- I chose the common approach of DMK -> certificate -> symmetric key -> column data.
-- Reasons for using this encryption:
/*
This can enhance trust and confidence among customers, knowing that their feedback is handled with care and their personal information remains secure.
*/
CREATE CERTIFICATE feedbackCertificate WITH SUBJECT = 'Feedback Encryption'; 

CREATE SYMMETRIC KEY feedbackSymmetricKey
WITH ALGORITHM = AES_256
ENCRYPTION BY CERTIFICATE feedbackCertificate;

OPEN SYMMETRIC KEY feedbackSymmetricKey
    DECRYPTION BY CERTIFICATE feedbackCertificate;

UPDATE Feedback
SET Rating = ENCRYPTBYKEY(KEY_GUID('feedbackSymmetricKey'), CONVERT(VARBINARY(256), Rating)),
    Comment = ENCRYPTBYKEY(KEY_GUID('feedbackSymmetricKey'), CONVERT(VARBINARY(256), Comment));

CLOSE SYMMETRIC KEY feedbackSymmetricKey;


OPEN SYMMETRIC KEY feedbackSymmetricKey
    DECRYPTION BY CERTIFICATE feedbackCertificate;

SELECT FeedbackID,
       MemberID,
       BookID,
       CAST(DECRYPTBYKEY(Rating) AS INT) AS Rating,
       CAST(DECRYPTBYKEY(Comment) AS VARCHAR(255)) AS Comment
FROM Feedback;

CLOSE SYMMETRIC KEY feedbackSymmetricKey;

GO
CREATE TRIGGER insertEncryptedFeedback
ON Feedback
INSTEAD OF INSERT
AS
BEGIN
    OPEN SYMMETRIC KEY feedbackSymmetricKey
        DECRYPTION BY CERTIFICATE feedbackCertificate;

    INSERT INTO Feedback (MemberID, BookID, Rating, Comment)
    SELECT MemberID,
           BookID,
           ENCRYPTBYKEY(KEY_GUID('feedbackSymmetricKey'), CONVERT(VARBINARY(256), Rating)),
           ENCRYPTBYKEY(KEY_GUID('feedbackSymmetricKey'), CONVERT(VARBINARY(256), Comment))
    FROM inserted;

    CLOSE SYMMETRIC KEY feedbackSymmetricKey;
END;