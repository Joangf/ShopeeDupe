-- =========================
-- TEST FOR sp_AddNewUser
-- =========================

DELIMITER //
CREATE PROCEDURE sp_Test_AddNewUser_Success()
BEGIN
    CALL sp_AddNewUser(
        'Test User Success',
        'Male',
        '2001-01-01',
        CONCAT('TESTADDUSER', FLOOR(RAND()*100000)),
        CONCAT('adduser_success', FLOOR(RAND()*100000), '@gmail.com'),
        CONCAT('09000000', FLOOR(RAND()*100000)),
        'Test Address',
        'testpassword'
    );
--     SELECT 'AddNewUser Success' AS TestCase, ROW_COUNT() AS RowsAffected;
END;
//
DELIMITER ;

DELIMITER //
CREATE PROCEDURE sp_Test_AddNewUser_DuplicateEmail()
BEGIN
    DECLARE v_Email VARCHAR(255);
    DECLARE v_Email1 VARCHAR(255);
	SET v_Email = CONCAT('duplicate_email', FLOOR(RAND()*100000), '@gmail.com');
    SET v_Email1 = CONCAT('duplicate_email', FLOOR(RAND()*100000), '@gmail.com');
    -- Insert first user
    CALL sp_AddNewUser(
        'User1',
        'Male',
        '2002-02-02',
        CONCAT('DUPLICATEEMAIL1', FLOOR(RAND()*100000)),
        v_Email,
        CONCAT('09111111', FLOOR(RAND()*100000)),
        'Address1',
        'pw1'
    );
    -- Try insert second user with same email
    BEGIN
        DECLARE CONTINUE HANDLER FOR SQLEXCEPTION
            SELECT 'AddNewUser Duplicate Email' AS TestCase, 'Duplicate Email Error' AS Result;
        CALL sp_AddNewUser(
            'User2',
            'Female',
            '2003-03-03',
            CONCAT('DUPLICATEEMAIL2', FLOOR(RAND()*100000)),
            v_Email,
            CONCAT('09222222', FLOOR(RAND()*100000)),
            'Address2',
            'pw2'
        );
    END;
END;
//
DELIMITER ;

DELIMITER //
CREATE PROCEDURE sp_Test_AddNewUser_InvalidDateOfBirth()
BEGIN
    BEGIN
        DECLARE CONTINUE HANDLER FOR SQLEXCEPTION
            SELECT 'AddNewUser Invalid DateOfBirth' AS TestCase, 'Invalid DateOfBirth Error' AS Result;
        CALL sp_AddNewUser(
            'User Future',
            'Male',
            DATE_ADD(CURRENT_DATE(), INTERVAL 1 DAY),
--             '2000-11-20',
            CONCAT('FUTUREDATE', FLOOR(RAND()*100000)),
            CONCAT('futuredate', FLOOR(RAND()*100000), '@gmail.com'),
            CONCAT('09333333', FLOOR(RAND()*100000)),
            'Future Address',
            'pwfuture'
        );
    END;
END;
//
DELIMITER ;

-- =========================
-- TEST FOR sp_AddNewSeller
-- =========================

DELIMITER //
CREATE PROCEDURE sp_Test_AddNewSeller_Success()
BEGIN
    DECLARE v_UserID INT;
    CALL sp_AddNewUser(
        'Seller User',
        'Female',
        '1999-09-09',
        CONCAT('SELLERUSER', FLOOR(RAND()*100000)),
        CONCAT('selleruser', FLOOR(RAND()*100000), '@gmail.com'),
        CONCAT('09444444', FLOOR(RAND()*100000)),
        'Seller Address',
        'sellerpw'
    );
    SELECT MAX(UserID) INTO v_UserID FROM User;
    CALL sp_AddNewSeller(
        v_UserID,
        'Business Address',
        NULL
    );
    SELECT 'AddNewSeller Success' AS TestCase, ROW_COUNT() AS RowsAffected;
END;
//
DELIMITER ;

DELIMITER //
CREATE PROCEDURE sp_Test_AddNewSeller_UserNotExist()
BEGIN
    BEGIN
        DECLARE CONTINUE HANDLER FOR SQLEXCEPTION
            SELECT 'AddNewSeller User Not Exist' AS TestCase, 'User Not Exist Error' AS Result;
        CALL sp_AddNewSeller(
            -99999,
            'No Address',
            'No Business'
        );
    END;
END;
//
DELIMITER ;

-- =========================
-- TEST FOR sp_ChangeTypeSeller
-- =========================

DELIMITER //
CREATE PROCEDURE sp_Test_ChangeTypeSeller_Success()
BEGIN
    DECLARE v_UserID INT;
    CALL sp_AddNewUser(
        'ChangeType User',
        'Male',
        '1995-05-05',
        CONCAT('CHANGETYPE', FLOOR(RAND()*100000)),
        CONCAT('changetype', FLOOR(RAND()*100000), '@gmail.com'),
        CONCAT('09555555', FLOOR(RAND()*100000)),
        'ChangeType Address',
        'changetypepw'
    );
    SELECT MAX(UserID) INTO v_UserID FROM User;
    CALL sp_AddNewSeller(
        v_UserID,
        'ChangeType Seller Address',
        NULL
    );
    CALL sp_ChangeTypeSeller(
        v_UserID,
        'Business',
        'Changed Business Name'
    );
    SELECT 'ChangeTypeSeller Success' AS TestCase, ROW_COUNT() AS RowsAffected;
END;
//
DELIMITER ;

DELIMITER //
CREATE PROCEDURE sp_Test_ChangeTypeSeller_SellerNotExist()
BEGIN
    CALL sp_ChangeTypeSeller(
        -99999,
        'Business',
        'NonExistent Business'
    );
    SELECT 'ChangeTypeSeller Seller Not Exist' AS TestCase, ROW_COUNT() AS RowsAffected;
END;
//
DELIMITER ;

-- =========================
-- TEST FOR sp_Login
-- =========================

DELIMITER //
CREATE PROCEDURE sp_Test_Login_Success()
BEGIN
    DECLARE v_UserID INT;
    DECLARE v_Success TINYINT;
    DECLARE v_ReturnedUserID INT;
    DECLARE v_Reason VARCHAR(255);
    CALL sp_AddNewUser(
        'Login User',
        'Male',
        '1990-10-10',
        CONCAT('LOGINUSER', FLOOR(RAND()*100000)),
        CONCAT('loginuser', FLOOR(RAND()*100000), '@gmail.com'),
        CONCAT('09666666', FLOOR(RAND()*100000)),
        'Login Address',
        'loginpw'
    );
    SELECT MAX(UserID) INTO v_UserID FROM User;
    CALL sp_Login(
        v_UserID,
        NULL,
        NULL,
        'loginpw',
        v_Success,
        v_ReturnedUserID,
        v_Reason
    );
    SELECT 'Login Success' AS TestCase, v_Success, v_ReturnedUserID, v_Reason;
END;
//
DELIMITER ;

DELIMITER //
CREATE PROCEDURE sp_Test_Login_WrongPassword()
BEGIN
    DECLARE v_UserID INT;
    DECLARE v_Success TINYINT;
    DECLARE v_ReturnedUserID INT;
    DECLARE v_Reason VARCHAR(255);
    CALL sp_AddNewUser(
        'Login WrongPW',
        'Female',
        '1991-11-11',
        CONCAT('LOGINWRONGPW', FLOOR(RAND()*100000)),
        CONCAT('loginwrongpw', FLOOR(RAND()*100000), '@gmail.com'),
        CONCAT('09777777', FLOOR(RAND()*100000)),
        'WrongPW Address',
        'rightpw'
    );
    SELECT MAX(UserID) INTO v_UserID FROM User;
    CALL sp_Login(
        v_UserID,
        NULL,
        NULL,
        'wrongpw',
        v_Success,
        v_ReturnedUserID,
        v_Reason
    );
    SELECT 'Login Wrong Password' AS TestCase, v_Success, v_ReturnedUserID, v_Reason;
END;
//
DELIMITER ;

DELIMITER //
CREATE PROCEDURE sp_Test_Login_UserNotExist()
BEGIN
    DECLARE v_Success TINYINT;
    DECLARE v_ReturnedUserID INT;
    DECLARE v_Reason VARCHAR(255);
    CALL sp_Login(
        -99999,
        NULL,
        NULL,
        'any',
        v_Success,
        v_ReturnedUserID,
        v_Reason
    );
    SELECT 'Login User Not Exist' AS TestCase, v_Success, v_ReturnedUserID, v_Reason;
END;
//
DELIMITER ;

DELIMITER //
CREATE PROCEDURE sp_Test_Login_InvalidEmailFormat()
BEGIN
    DECLARE v_Success TINYINT;
    DECLARE v_ReturnedUserID INT;
    DECLARE v_Reason VARCHAR(255);
    CALL sp_Login(
        NULL,
        'invalid-email-format',
        NULL,
        'any',
        v_Success,
        v_ReturnedUserID,
        v_Reason
    );
    SELECT 'Login Invalid Email Format' AS TestCase, v_Success, v_ReturnedUserID, v_Reason;
END;
//
DELIMITER ;

DELIMITER //
CREATE PROCEDURE sp_Test_Login_InvalidPhoneFormat()
BEGIN
    DECLARE v_Success TINYINT;
    DECLARE v_ReturnedUserID INT;
    DECLARE v_Reason VARCHAR(255);
    CALL sp_Login(
        NULL,
        NULL,
        'invalid-phone',
        'any',
        v_Success,
        v_ReturnedUserID,
        v_Reason
    );
    SELECT 'Login Invalid Phone Format' AS TestCase, v_Success, v_ReturnedUserID, v_Reason;
END;
//
DELIMITER ;

DELIMITER //
CREATE PROCEDURE sp_Test_Login_NoInput()
BEGIN
    DECLARE v_Success TINYINT;
    DECLARE v_ReturnedUserID INT;
    DECLARE v_Reason VARCHAR(255);
    CALL sp_Login(
        NULL,
        NULL,
        NULL,
        'any',
        v_Success,
        v_ReturnedUserID,
        v_Reason
    );
    SELECT 'Login No Input' AS TestCase, v_Success, v_ReturnedUserID, v_Reason;
END;
//
DELIMITER ;

-- =========================
-- TEST FOR sp_ChangeUserPassword
-- =========================

DELIMITER //
CREATE PROCEDURE sp_Test_ChangeUserPassword_Success()
BEGIN
    DECLARE v_UserID INT;
    DECLARE v_Success TINYINT;
    DECLARE v_Reason VARCHAR(255);
    CALL sp_AddNewUser(
        'ChangePW User',
        'Male',
        '1988-08-08',
        CONCAT('CHANGEPWUSER', FLOOR(RAND()*100000)),
        CONCAT('changepwuser', FLOOR(RAND()*100000), '@gmail.com'),
        CONCAT('09888888', FLOOR(RAND()*100000)),
        'ChangePW Address',
        'changepw'
    );
    SELECT MAX(UserID) INTO v_UserID FROM User;
    CALL sp_ChangeUserPassword(
        v_UserID,
        'newchangepw',
        v_Success,
        v_Reason
    );
    SELECT 'ChangeUserPassword Success' AS TestCase, v_Success, v_Reason;
END;
//
DELIMITER ;

DELIMITER //
CREATE PROCEDURE sp_Test_ChangeUserPassword_UserNotExist()
BEGIN
    DECLARE v_Success TINYINT;
    DECLARE v_Reason VARCHAR(255);
    CALL sp_ChangeUserPassword(
        -99999,
        'irrelevant',
        v_Success,
        v_Reason
    );
    SELECT 'ChangeUserPassword User Not Exist' AS TestCase, v_Success, v_Reason;
END;
//
DELIMITER ;