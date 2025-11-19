DELIMITER //
-- Thủ tục thêm một User mới
CREATE PROCEDURE sp_AddNewUser (
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
    
    INSERT INTO User (FullName, Gender, DateOfBirth, NationalID, Email, PhoneNumber, Address, PasswordHash)
    VALUES (p_FullName, p_Gender, p_DateOfBirth, p_NationalID, p_Email, TRIM(p_PhoneNumber), p_Address, p_PasswordHash);

    -- Lấy UserID vừa tạo
    SET newUserID = LAST_INSERT_ID();   -- Phải đảm bảo có AUTO INCREMENT cho UserID

    -- Chèn vào Customer với CustomerID = UserID vừa tạo
    INSERT INTO Customer (CustomerID, `Type`)   
    VALUES (newUserID, 'Regular'); -- Ví dụ Type mặc định là 'Regular'
END //
DELIMITER ;


DELIMITER //
-- Trigger kiểm tra ràng buộc trước khi chèn dữ liệu vào bảng User
CREATE TRIGGER trg_User_BeforeInsert
BEFORE INSERT ON User
FOR EACH ROW
BEGIN
    -- Kiểm tra ngày sinh không lớn hơn hiện tại
    IF NEW.DateOfBirth IS NOT NULL AND NEW.DateOfBirth > CURRENT_DATE() THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'DateOfBirth cannot be in the future';
    END IF;

    -- -- Kiểm tra cú pháp email
    -- IF NEW.Email NOT REGEXP '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$' THEN
    --     SIGNAL SQLSTATE '45000'
    --     SET MESSAGE_TEXT = 'Email format is invalid';
    -- END IF;

    -- Kiểm tra số điện thoại quốc tế hợp lệ
    IF NEW.PhoneNumber IS NOT NULL AND NEW.PhoneNumber NOT REGEXP '^(\+?[0-9]{7,15})$' THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'PhoneNumber must be a valid international format';
    END IF;
END;
//
DELIMITER ;


DELIMITER //
-- Thủ tục thêm một Seller mới
CREATE PROCEDURE sp_AddNewSeller (
    IN p_SellerID INT,                 -- ID người dùng (UserID) đã có
    IN p_BusinessAddress NVARCHAR(255), -- Địa chỉ kinh doanh
    IN p_BusinessName NVARCHAR(255) -- Tên doanh nghiệp (không muốn có thì cho NULL, cho khác NULL nếu Type là Business)
)
BEGIN
    -- Chèn thông tin người bán --
    IF p_BusinessName IS NOT NULL THEN
        INSERT INTO Seller (SellerID, Type, BusinessAddress, BusinessName)
        VALUES (p_SellerID, 'Business', p_BusinessAddress, p_BusinessName);
    ELSE
        INSERT INTO Seller (SellerID, Type, BusinessAddress, BusinessName)
        VALUES (p_SellerID, 'Personal', p_BusinessAddress, p_BusinessName);
    END IF;
END;
//
DELIMITER ;


DELIMITER //
-- Trigger kiểm tra ràng buộc trước khi chèn dữ liệu vào bảng Seller
CREATE TRIGGER trg_Seller_BeforeInsert
BEFORE INSERT ON Seller
FOR EACH ROW
BEGIN
    -- Kiểm tra SellerID tồn tại trong bảng User
    IF NOT EXISTS (SELECT 1 FROM User WHERE UserID = NEW.SellerID) THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'SellerID does not exist in User table';
    END IF;
END;
//
DELIMITER ;


DELIMITER //
-- Thủ tục sửa Type của Seller
CREATE PROCEDURE sp_ChangeTypeSeller (
    IN p_SellerID INT,                 -- ID người bán đã có
    IN p_Type nvarchar(50), -- Địa chỉ kinh doanh
    IN p_BusinessName NVARCHAR(255) -- Tên doanh nghiệp (cho khác NULL nếu Type là Business)
)
BEGIN
    UPDATE Seller
    SET Type = p_Type,
        BusinessName = p_BusinessName
    WHERE SellerID = p_SellerID;
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
    OUT p_ReasonLoginFail VARCHAR(255)  -- Lý do đăng nhập thất bại
)
BEGIN
    DECLARE v_uid INT;
    DECLARE v_exists INT;
    -- mặc định
    SET p_Success = 0;
    SET p_ReturnedUserID = NULL;
    SET p_ReasonLoginFail = 'User may not found';

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
    ELSEIF p_PhoneInput IS NOT NULL AND NOT TRIM(p_PhoneInput) REGEXP '^(\+)?[0-9]+$' THEN
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
    OUT p_ReasonFail VARCHAR(255) -- Lý do thất bại nếu có
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
        SET p_ReasonFail = 'UserID not found or old password incorrect';
    ELSE
        -- Cập nhật mật khẩu mới
        UPDATE `User`
        SET PasswordHash = p_NewPasswordHash
        WHERE UserID = p_UserID;

        SET p_Success = 1;
        SET p_ReasonFail = '';
    END IF;
END;
//
DELIMITER ;