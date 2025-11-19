-- =========================
-- TEST FOR sp_AddNewUser
-- =========================

-- Test: Thêm user mới thành công
DELIMITER //
CREATE PROCEDURE sp_Test_AddNewUser_Success()
BEGIN
    -- Gọi thủ tục thêm user mới với dữ liệu hợp lệ
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
    -- Có thể kiểm tra kết quả ở đây nếu cần
END;
//
DELIMITER ;

-- Test: Thêm user với email bị trùng, mong đợi lỗi
DELIMITER //
CREATE PROCEDURE sp_Test_AddNewUser_DuplicateEmail()
BEGIN
    -- Khai báo biến email dùng chung cho 2 user
    DECLARE v_Email VARCHAR(255);
    DECLARE v_Email1 VARCHAR(255);
    SET v_Email = CONCAT('duplicate_email', FLOOR(RAND()*100000), '@gmail.com');
    SET v_Email1 = CONCAT('duplicate_email', FLOOR(RAND()*100000), '@gmail.com');
    -- Thêm user đầu tiên với email này
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
    -- Thử thêm user thứ hai với cùng email, mong đợi lỗi
    BEGIN
        DECLARE v_err_code INT;
        DECLARE v_err_msg TEXT;
        DECLARE CONTINUE HANDLER FOR SQLEXCEPTION
        BEGIN
            -- Lấy thông báo lỗi khi bị trùng email
            GET DIAGNOSTICS CONDITION 1 v_err_msg = MESSAGE_TEXT;
            SELECT 'AddNewUser Duplicate Email' AS TestCase, v_err_code AS ErrorCode, v_err_msg AS ErrorMessage;
        END;
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

-- Test: Thêm user với ngày sinh lớn hơn ngày hiện tại, mong đợi lỗi
DELIMITER //
CREATE PROCEDURE sp_Test_AddNewUser_InvalidDateOfBirth()
BEGIN
    DECLARE v_err_code INT;
    DECLARE v_err_msg TEXT;

    -- Thử thêm user với ngày sinh ở tương lai, mong đợi lỗi
    BEGIN
        DECLARE CONTINUE HANDLER FOR SQLEXCEPTION
        BEGIN
            -- Lấy thông báo lỗi khi ngày sinh không hợp lệ
            GET DIAGNOSTICS CONDITION 1 v_err_msg = MESSAGE_TEXT;
            SELECT 'AddNewUser Invalid DateOfBirth' AS TestCase, v_err_code AS ErrorCode, v_err_msg AS ErrorMessage;
        END;
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

-- Test: Thêm seller mới thành công
DELIMITER //
CREATE PROCEDURE sp_Test_AddNewSeller_Success()
BEGIN
    -- Thêm một user mới để làm seller
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
    -- Lấy UserID vừa thêm
    SELECT MAX(UserID) INTO v_UserID FROM User;
    -- Thêm seller với UserID vừa tạo
    CALL sp_AddNewSeller(
        v_UserID,
        'Business Address',
        NULL
    );
    -- Kiểm tra số dòng bị ảnh hưởng
    SELECT 'AddNewSeller Success' AS TestCase, ROW_COUNT() AS RowsAffected;
END;
//
DELIMITER ;

-- Test: Thêm seller với UserID không tồn tại, mong đợi lỗi
DELIMITER //

CREATE PROCEDURE sp_Test_AddNewSeller_UserNotExist()
BEGIN
    -- Khai báo biến để lấy mã lỗi và thông báo lỗi
    DECLARE v_err_code INT;
    DECLARE v_err_msg TEXT;

    -- Bắt mọi lỗi SQL khi gọi thủ tục với UserID không tồn tại
    DECLARE CONTINUE HANDLER FOR SQLEXCEPTION
    BEGIN
        GET DIAGNOSTICS CONDITION 1
            v_err_code = MYSQL_ERRNO,
            v_err_msg = MESSAGE_TEXT;
        -- Xuất thông tin lỗi ra kết quả
        SELECT 
            'AddNewSeller User Not Exist' AS TestCase,
            v_err_code AS ErrorCode,
            v_err_msg AS ErrorMessage;
    END;

    -- Gọi procedure với UserID không tồn tại
    CALL sp_AddNewSeller(
        -99999,
        'No Address',
        'No Business'
    );
END;
//

DELIMITER ;

-- =========================
-- TEST FOR sp_ChangeTypeSeller
-- =========================

-- Test: Đổi type của seller thành công
DELIMITER //
CREATE PROCEDURE sp_Test_ChangeTypeSeller_Success()
BEGIN
    -- Thêm user và seller mới
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
    -- Đổi type seller sang Business
    CALL sp_ChangeTypeSeller(
        v_UserID,
        'Business',
        'Changed Business Name'
    );
    -- Kiểm tra số dòng bị ảnh hưởng
    SELECT 'ChangeTypeSeller Success' AS TestCase, ROW_COUNT() AS RowsAffected;
END;
//
DELIMITER ;

-- Test: Đổi type của seller không tồn tại, mong đợi không ảnh hưởng dòng nào
DELIMITER //
CREATE PROCEDURE sp_Test_ChangeTypeSeller_SellerNotExist()
BEGIN
    -- Gọi thủ tục đổi type cho seller không tồn tại
    CALL sp_ChangeTypeSeller(
        -99999,
        'Business',
        'NonExistent Business'
    );
    -- Kiểm tra số dòng bị ảnh hưởng (mong đợi = 0)
    SELECT 'ChangeTypeSeller Seller Not Exist' AS TestCase, ROW_COUNT() AS RowsAffected;
END;
//
DELIMITER ;

-- =========================
-- TEST FOR sp_Login
-- =========================

-- Test: Đăng nhập thành công với đúng thông tin
DELIMITER //
CREATE PROCEDURE sp_Test_Login_Success()
BEGIN
    -- Thêm user mới để test đăng nhập
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
    -- Gọi thủ tục đăng nhập với thông tin đúng
    CALL sp_Login(
        v_UserID,
        NULL,
        NULL,
        'loginpw',
        v_Success,
        v_ReturnedUserID,
        v_Reason
    );
    -- Xuất kết quả đăng nhập
    SELECT 'Login Success' AS TestCase, v_Success, v_ReturnedUserID, v_Reason;
END;
//
DELIMITER ;

-- Test: Đăng nhập với sai mật khẩu, mong đợi thất bại
DELIMITER //
CREATE PROCEDURE sp_Test_Login_WrongPassword()
BEGIN
    -- Thêm user mới để test đăng nhập sai mật khẩu
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
    -- Gọi thủ tục đăng nhập với mật khẩu sai
    CALL sp_Login(
        v_UserID,
        NULL,
        NULL,
        'wrongpw',
        v_Success,
        v_ReturnedUserID,
        v_Reason
    );
    -- Xuất kết quả đăng nhập
    SELECT 'Login Wrong Password' AS TestCase, v_Success, v_ReturnedUserID, v_Reason;
END;
//
DELIMITER ;

-- Test: Đăng nhập với UserID không tồn tại, mong đợi thất bại
DELIMITER //
CREATE PROCEDURE sp_Test_Login_UserNotExist()
BEGIN
    -- Gọi thủ tục đăng nhập với UserID không tồn tại
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
    -- Xuất kết quả đăng nhập
    SELECT 'Login User Not Exist' AS TestCase, v_Success, v_ReturnedUserID, v_Reason;
END;
//
DELIMITER ;

-- Test: Đăng nhập với email sai định dạng, mong đợi thất bại
DELIMITER //
CREATE PROCEDURE sp_Test_Login_InvalidEmailFormat()
BEGIN
    -- Gọi thủ tục đăng nhập với email sai định dạng
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
    -- Xuất kết quả đăng nhập
    SELECT 'Login Invalid Email Format' AS TestCase, v_Success, v_ReturnedUserID, v_Reason;
END;
//
DELIMITER ;

-- Test: Đăng nhập với số điện thoại sai định dạng, mong đợi thất bại
DELIMITER //
CREATE PROCEDURE sp_Test_Login_InvalidPhoneFormat()
BEGIN
    -- Gọi thủ tục đăng nhập với số điện thoại sai định dạng
    DECLARE v_Success TINYINT;
    DECLARE v_ReturnedUserID INT;
    DECLARE v_Reason VARCHAR(255);
    CALL sp_Login(
        NULL,
        NULL,
        ')_949300',
        'any',
        v_Success,
        v_ReturnedUserID,
        v_Reason
    );
    -- Xuất kết quả đăng nhập
    SELECT 'Login Invalid Phone Format' AS TestCase, v_Success, v_ReturnedUserID, v_Reason;
END;
//
DELIMITER ;

-- Test: Đăng nhập không cung cấp thông tin, mong đợi thất bại
DELIMITER //
CREATE PROCEDURE sp_Test_Login_NoInput()
BEGIN
    -- Gọi thủ tục đăng nhập mà không truyền thông tin nào
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
    -- Xuất kết quả đăng nhập
    SELECT 'Login No Input' AS TestCase, v_Success, v_ReturnedUserID, v_Reason;
END;
//
DELIMITER ;

-- =========================
-- TEST FOR sp_ChangeUserPassword
-- =========================

-- Test: Đổi mật khẩu thành công
DELIMITER //
CREATE PROCEDURE sp_Test_ChangeUserPassword_Success()
BEGIN
    -- Thêm user mới để test đổi mật khẩu
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
    -- Gọi thủ tục đổi mật khẩu
    CALL sp_ChangeUserPassword(
        v_UserID,
        'newchangepw',
        v_Success,
        v_Reason
    );
    -- Xuất kết quả đổi mật khẩu
    SELECT 'ChangeUserPassword Success' AS TestCase, v_Success, v_Reason;
END;
//
DELIMITER ;

-- Test: Đổi mật khẩu cho UserID không tồn tại, mong đợi thất bại
DELIMITER //
CREATE PROCEDURE sp_Test_ChangeUserPassword_UserNotExist()
BEGIN
    -- Gọi thủ tục đổi mật khẩu với UserID không tồn tại
    DECLARE v_Success TINYINT;
    DECLARE v_Reason VARCHAR(255);
    CALL sp_ChangeUserPassword(
        -99999,
        'irrelevant',
        v_Success,
        v_Reason
    );
    -- Xuất kết quả đổi mật khẩu
    SELECT 'ChangeUserPassword User Not Exist' AS TestCase, v_Success, v_Reason;
END;
//
DELIMITER ;