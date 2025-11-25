DELIMITER //
-- Thủ tục thêm một User mới
CREATE PROCEDURE sp_AddNewCustomer (
    IN p_FullName NVARCHAR(255), -- Tên đầy đủ
    IN p_Gender NVARCHAR(10), -- Giới tính (Chỉ là 'Male' hoặc 'Female', không chấp nhận cả 'M' hoặc 'F')
    IN p_DateOfBirth DATE, -- Ngày sinh (không được lớn hơn ngày hiện tại)
    IN p_NationalID VARCHAR(20), -- Số CMND/CCCD (đảm bảo duy nhất)
    IN p_Email VARCHAR(255), -- Email (đảm bảo duy nhất)
    IN p_PhoneNumber VARCHAR(20), -- Số điện thoại (đảm bảo duy nhất)
    IN p_Address NVARCHAR(255), -- Địa chỉ
    IN p_PasswordHash VARCHAR(255) -- Mật khẩu đã được băm
)
BEGIN
    DECLARE newUserID INT;

    INSERT INTO User (FullName, Gender, DateOfBirth, NationalID, LastLogin, Email, PhoneNumber, Address, PasswordHash)
    VALUES (p_FullName, p_Gender, p_DateOfBirth, p_NationalID, NOW(), p_Email, TRIM(p_PhoneNumber), p_Address, p_PasswordHash);

    -- Lấy UserID vừa tạo
    SET newUserID = LAST_INSERT_ID();   -- Phải đảm bảo có AUTO INCREMENT cho UserID

    -- Chèn vào Customer với CustomerID = UserID vừa tạo
    INSERT INTO Customer (CustomerID, `Type`)   
    VALUES (newUserID, 'Regular'); -- Ví dụ Type mặc định là 'Regular'
END;
//
DELIMITER ;


DELIMITER //
-- Trigger kiểm tra ràng buộc trước khi chèn dữ liệu vào bảng User
CREATE TRIGGER trg_User_BeforeInsert
BEFORE INSERT ON User
FOR EACH ROW
BEGIN

    -- Kiểm tra giới tính hợp lệ
    IF NEW.Gender NOT IN ('Male', 'Female') THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Gender must be either ''Male'' or ''Female''';
    END IF;

    -- Kiểm tra ngày sinh không lớn hơn hiện tại
    IF NEW.DateOfBirth IS NOT NULL AND NEW.DateOfBirth > CURRENT_DATE() THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'DateOfBirth cannot be in the future';
    END IF;

    -- -- Kiểm tra cú pháp email
    IF NEW.Email NOT REGEXP '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$' THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Email format is invalid';
    END IF;

    -- Kiểm tra số điện thoại quốc tế hợp lệ
    IF NEW.PhoneNumber IS NOT NULL AND NEW.PhoneNumber NOT REGEXP '^\\+?[0-9]{7,20}$' THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'PhoneNumber must be a valid international format';
    END IF;
END;
//
DELIMITER ;


DELIMITER //
-- Thủ tục đăng nhập vào tài khoản người dùng. Phải tự đảm bảo việc dùng. Tự đảm bảo 1 trong 3 tham số (p_UserIDInput,
-- p_EmailInput, p_PhoneInput) không NULL, hai cái còn lại NULL, PasswordHash không được NULL
CREATE PROCEDURE sp_Login (
    IN  p_UserIDInput INT,          -- Có nghĩa là dùng UserID để login, nếu NULL nghĩa là không dùng
    IN  p_EmailInput VARCHAR(255),  -- Có nghĩa là dùng Email để login, nếu NULL nghĩa là không dùng
    IN  p_PhoneInput VARCHAR(20),  -- Có nghĩa là dùng Phone để login, nếu NULL nghĩa là không dùng
    IN  p_PasswordHash VARCHAR(255),    -- Mật khẩu đã được băm (nhưng thực chất không băm đâu)
    OUT p_Success TINYINT,       -- 1 = success, 0 = fail
    OUT p_ReturnedUserID INT,     -- UserID nếu success, NULL nếu fail
    OUT p_ReasonLoginFail VARCHAR(255)  -- Lý do đăng nhập thất bại (NULL là đăng nhập thành công)
)
BEGIN
    DECLARE v_uid INT;
    DECLARE v_exists INT;
    -- mặc định
    SET p_Success = 0;
    SET p_ReturnedUserID = NULL;
    SET p_ReasonLoginFail = NULL;

    -- Tạm giữ kết quả tìm được
    SET v_uid = NULL;

    -- Chỉ thực hiện login nếu:
    -- 1. Email hợp lệ hoặc NULL
    -- 2. Phone hợp lệ hoặc NULL
    -- 3. Ít nhất một input (UserID, Email, Phone) có giá trị
    -- Kiểm tra định dạng email nếu có
    IF p_EmailInput IS NOT NULL AND NOT p_EmailInput REGEXP '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$' THEN
        SET p_ReasonLoginFail = 'Invalid email format';
    -- Kiểm tra định dạng phone nếu có
    ELSEIF p_PhoneInput IS NOT NULL AND NOT TRIM(p_PhoneInput) REGEXP '^\\+?[0-9]{7,20}$' THEN
        SET p_ReasonLoginFail = 'Invalid phone format';
    -- Kiểm tra ít nhất có 1 input để login
    ELSEIF p_UserIDInput IS NULL AND p_EmailInput IS NULL AND p_PhoneInput IS NULL THEN
        SET p_ReasonLoginFail = 'Not provide UserID, Email, or Phone';
    ELSE
        -- Ưu tiên: UserID -> Email -> Phone
        IF p_UserIDInput IS NOT NULL THEN
            SELECT UserID
            INTO v_uid
            FROM `User`
            WHERE UserID = p_UserIDInput
            AND PasswordHash = p_PasswordHash
            LIMIT 1;    -- Giới hạn 1 kết quả lấy được
        ELSEIF p_EmailInput IS NOT NULL THEN
            SELECT UserID
            INTO v_uid
            FROM `User`
            WHERE Email = p_EmailInput
            AND PasswordHash = p_PasswordHash
            LIMIT 1;   -- Giới hạn 1 kết quả lấy được
        ELSEIF p_PhoneInput IS NOT NULL THEN
            SELECT UserID
            INTO v_uid
            FROM `User`
            WHERE PhoneNumber = TRIM(p_PhoneInput)
            AND PasswordHash = p_PasswordHash
            LIMIT 1;   -- Giới hạn 1 kết quả lấy được
        END IF;

        -- Nếu tìm thấy user hợp lệ
        IF v_uid IS NOT NULL THEN
            SET p_Success = 1;
            SET p_ReturnedUserID = v_uid;

            -- Cập nhật last login / trạng thái
            UPDATE `User`
            SET AccountStatus = 'Active',
                LastLogin = CURRENT_TIMESTAMP
            WHERE UserID = v_uid;
        ELSE 
            -- Nếu không tìm thấy, phân biệt user không tồn tại hay chỉ sai password
            SET v_exists = 0;
            -- Kiểm tra ID người dùng tồn tại hay không hay sai mật khẩu
            IF p_UserIDInput IS NOT NULL THEN
                SELECT COUNT(*) INTO v_exists FROM `User` WHERE UserID = p_UserIDInput;
                IF v_exists = 0 THEN
                    SET p_ReasonLoginFail = 'UserID not found';
                ELSE
                    SET p_ReasonLoginFail = 'Incorrect password';
                END IF;
            -- Kiem tra Email tồn tại hay không hay sai mật khẩu
            ELSEIF p_EmailInput IS NOT NULL THEN
                SELECT COUNT(*) INTO v_exists FROM `User` WHERE Email = p_EmailInput;
                IF v_exists = 0 THEN
                    SET p_ReasonLoginFail = 'Email not found';
                ELSE
                    SET p_ReasonLoginFail = 'Incorrect password';
                END IF;
            -- Kiem tra Phone tồn tại hay không hay sai mật khẩu
            ELSEIF p_PhoneInput IS NOT NULL THEN
                SELECT COUNT(*) INTO v_exists FROM `User` WHERE PhoneNumber = TRIM(p_PhoneInput);
                IF v_exists = 0 THEN
                    SET p_ReasonLoginFail = 'Phone not found';
                ELSE
                    SET p_ReasonLoginFail = 'Incorrect password';
                END IF;
            -- Lý do thất bại mặc định
            ELSE
                SET p_ReasonLoginFail = 'No valid input provided';
            END IF;
        END IF;
	END IF;
END;
//
DELIMITER ;


DELIMITER //
-- Hàm chuyển đổi mật khẩu người dùng
CREATE PROCEDURE sp_ChangeUserPassword (
    IN p_UserID INT, -- ID người dùng
    IN p_NewPasswordHash VARCHAR(255), -- Mật khẩu mới đã được băm
    OUT p_Success TINYINT, -- 1 = success, 0 = fail
    OUT p_ReasonFail VARCHAR(255) -- Lý do thất bại nếu có (NULL là thành công)
)
BEGIN
    DECLARE v_exists INT;
    SET p_Success = 0;  -- Đặt giá trị mặc định cho biến báo thành công
    SET p_ReasonFail = 'Fail'; -- Đặt giá trị mặc định cho lý do thất bại
    -- Kiểm tra UserID tồn tại với mật khẩu cũ
    SELECT COUNT(*) INTO v_exists
    FROM User
    WHERE UserID = p_UserID;

    IF v_exists = 0 THEN
        SET p_Success = 0;
        SET p_ReasonFail = 'UserID not found';
    ELSE
        -- Cập nhật mật khẩu mới
        UPDATE `User`
        SET PasswordHash = p_NewPasswordHash
        WHERE UserID = p_UserID;

        SET p_Success = 1;
        SET p_ReasonFail = NULL;
    END IF;
END;
//
DELIMITER ;


DELIMITER //
-- Thủ tục đăng xuất tài khoản người dùng
-- Cho phép gọi thủ tục đăng xuất nhiều lần liên tiếp thành công
CREATE PROCEDURE sp_Logout (
    IN p_UserID INT, -- ID người dùng cần đăng xuất
    OUT p_Success TINYINT, -- 1 = success, 0 = fail
    OUT p_ReasonFail VARCHAR(255) -- Lý do thất bại nếu có (NULL là thành công)
)
BEGIN
    DECLARE v_exists INT;
    SET p_Success = 0;
    SET p_ReasonFail = 'Fail';
    -- Kiểm tra UserID tồn tại
    SELECT COUNT(*) INTO v_exists
    FROM User
    WHERE UserID = p_UserID;

    IF v_exists = 0 THEN
        SET p_Success = 0;
        SET p_ReasonFail = 'UserID not found';
    ELSE
        -- Cập nhật trạng thái tài khoản thành 'Logged out'
        UPDATE `User`
        SET AccountStatus = 'Logged out'
        WHERE UserID = p_UserID;

        SET p_Success = 1;
        SET p_ReasonFail = NULL;
    END IF;
END;
//
DELIMITER ;


DELIMITER //
-- Hàm trả về trạng thái tài khoản người dùng
CREATE FUNCTION fn_GetUserStatus(p_UserID INT) -- ID người dùng cần lấy trạng thái tài khoản
RETURNS VARCHAR(50)	-- Trả về NULL nếu không tìm thấy ID người dùng tương ứng
DETERMINISTIC
BEGIN
    DECLARE v_AccountStatus VARCHAR(50);
    SET v_AccountStatus = NULL;
    SELECT AccountStatus INTO v_AccountStatus FROM User WHERE UserID = p_UserID;
    RETURN v_AccountStatus;
END;
//
DELIMITER ;

-- --------------------------------------------------------------------------------
-- Function 1: Find Customer using Email or Phone
-- --------------------------------------------------------------------------------
DELIMITER //
CREATE FUNCTION func_FindCustomerByEmail (
    p_Email VARCHAR(255)
)
RETURNS INT READS SQL DATA
BEGIN
    DECLARE v_CustomerID INT;

    SELECT C.CustomerID INTO v_CustomerID
    FROM Customer C
    JOIN `User` U ON C.CustomerID = U.UserID
    WHERE U.Email = p_Email
    LIMIT 1;

    RETURN v_CustomerID;
END;
//
DELIMITER ;

DELIMITER //
CREATE FUNCTION func_FindCustomerByPhone (
    p_Phone VARCHAR(20)
)
RETURNS INT READS SQL DATA
BEGIN
    DECLARE v_CustomerID INT;

    SELECT C.CustomerID INTO v_CustomerID
    FROM Customer C
    JOIN `User` U ON C.CustomerID = U.UserID
    WHERE U.PhoneNumber = TRIM(p_Phone)
    LIMIT 1;

    RETURN v_CustomerID;
END;
//
DELIMITER ;

DELIMITER //
CREATE FUNCTION func_FindCustomerByEmailandPhone (
    p_Phone VARCHAR(20),
    p_Email VARCHAR(255)
)
RETURNS INT READS SQL DATA
BEGIN
    DECLARE v_CustomerID INT;

    SELECT C.CustomerID INTO v_CustomerID
    FROM Customer C
    JOIN `User` U ON C.CustomerID = U.UserID
    WHERE U.PhoneNumber = TRIM(p_Phone)
        AND U.Email = p_Email
    LIMIT 1;

    RETURN v_CustomerID;
END;
//
DELIMITER ;

-- --------------------------------------------------------------------------------
-- Function 2: Find customer using email or password
-- --------------------------------------------------------------------------------
DELIMITER //
CREATE FUNCTION func_AuthenticateCustomer (
    p_Email VARCHAR(255),
    p_PasswordHash VARCHAR(255)
)
RETURNS INT READS SQL DATA
BEGIN
    DECLARE v_CustomerID INT;

    SELECT C.CustomerID INTO v_CustomerID
    FROM Customer C
    JOIN `User` U ON C.CustomerID = U.UserID
    WHERE U.Email = p_Email
        AND U.PasswordHash = p_PasswordHash
    LIMIT 1;

    RETURN v_CustomerID;
END;
//

DELIMITER ;


