-- [Problem 1]
-- drop table just in case
DROP TABLE IF EXISTS user_info;

-- create a table to store the user information
CREATE TABLE user_info (
    -- username string that is 20 characters or less
    username VARCHAR(20),
    -- salt string added to password, I chose 10 characters
    salt CHAR(10),
    -- hash of password: 16^x = 2^256 -> length of 64
    password_hash CHAR(64)
);

-- [Problem 2]
-- drop just in case
DROP PROCEDURE IF EXISTS sp_add_user;

DELIMITER !
-- procedure takes in a username and password
-- adds tuple to user_info table
CREATE PROCEDURE sp_add_user(IN new_username VARCHAR(20),
 password VARCHAR(20))  
BEGIN
    DECLARE salted CHAR(10);
    DECLARE slt_psd VARCHAR(30);
    DECLARE hashed CHAR(64);
    -- creates new salt
    SET salted = make_salt(10);
    -- combines with password
    SET slt_psd = CONCAT(salted, password);
    -- hashes salted password
    SET hashed = SHA2(slt_psd, 256);
    -- adds to table
    INSERT INTO user_info 
    VALUES (new_username, salted, hashed);
    
END !
DELIMITER ;

-- [Problem 3]
-- drop just in case
DROP PROCEDURE IF EXISTS sp_change_password;

DELIMITER !
-- procedure takes in a username and password
-- updates table with new password
CREATE PROCEDURE sp_change_password(IN username VARCHAR(20),
new_password VARCHAR(20))
BEGIN
    DECLARE salted CHAR(10);
    DECLARE slt_psd VARCHAR(30);
    DECLARE hashed CHAR(64);
    -- creates new salt
    SET salted = make_salt(10);
    -- combines with password
    SET slt_psd = CONCAT(salted, new_password);
    -- hashes salted password
    SET hashed = SHA2(slt_psd, 256);
    -- updates table
    UPDATE user_info SET salt = salted, password_hash = hashed
    WHERE user_info.username = username;

END !
DELIMITER ;

-- [Problem 4]
-- drop just in case
DROP FUNCTION IF EXISTS authenticate;

DELIMITER !
-- checks to see if valid username and password combo
CREATE FUNCTION authenticate(username VARCHAR(20), 
password VARCHAR(20)) RETURNS BOOLEAN
BEGIN
    DECLARE slt_psd VARCHAR(30);
    DECLARE hashed CHAR(64);
    -- checks to see if username exits in database
    -- creates hashed/salted password if so
    IF username IN (SELECT username FROM user_info) THEN
        SET slt_psd = CONCAT((SELECT salt FROM user_info
        WHERE user_info.username = username), password);
    ELSE RETURN FALSE;
    END IF;
    SET hashed = SHA2(slt_psd, 256);
    -- if passwords are same, return true. Else return false
    IF hashed = (SELECT password_hash FROM user_info
        WHERE user_info.username = username) THEN RETURN TRUE;
    ELSE RETURN FALSE;
    END IF;
   
END !
DELIMITER ;
