DELIMITER //

CREATE PROCEDURE sp_AddNewSeller (
    -- User info
    IN p_FullName NVARCHAR(100),
    IN p_Gender VARCHAR(10),
    IN p_DateOfBirth DATE,
    IN p_NationalID VARCHAR(50),
    IN p_Email VARCHAR(255),
    IN p_PhoneNumber VARCHAR(20),
    IN p_Address NVARCHAR(255),
    IN p_Password VARCHAR(255),

    IN p_BusinessAddress NVARCHAR(255),
    IN p_BusinessName NVARCHAR(255)
)
BEGIN
    DECLARE newUserId INT;

    INSERT INTO User (
        FullName, Gender, DateOfBirth,
        NationalID, Email, PhoneNumber, Address, PasswordHash
    ) VALUES (
        p_FullName, p_Gender, p_DateOfBirth,
        p_NationalID, p_Email, p_PhoneNumber, p_Address, p_Password
    );

    SET newUserId = LAST_INSERT_ID();

    IF p_BusinessName IS NOT NULL THEN
        INSERT INTO Seller(SellerID, Type, BusinessAddress, BusinessName)
        VALUES (newUserId, 'Business', p_BusinessAddress, p_BusinessName);
    ELSE
        INSERT INTO Seller(SellerID, Type, BusinessAddress, BusinessName)
        VALUES (newUserId, 'Personal', p_BusinessAddress, NULL);
    END IF;

    SELECT newUserId AS UserID;
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

-- function authenticate seller
DELIMITER //
CREATE FUNCTION func_AuthenticateSeller (
    p_Email VARCHAR(255),
    p_PasswordHash VARCHAR(255)
)
RETURNS INT READS SQL DATA
BEGIN
    DECLARE v_Seller INT;

    SELECT S.SellerID INTO v_Seller
    FROM Seller S
    JOIN `User` U ON S.SellerID = U.UserID
    WHERE U.Email = p_Email
        AND U.PasswordHash = p_PasswordHash
    LIMIT 1;

    RETURN v_Seller;
END;
//

DELIMITER ;