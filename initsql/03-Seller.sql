DELIMITER //
-- Thủ tục thêm một Seller mới
CREATE PROCEDURE sp_AddNewSeller (
    IN p_SellerID INT,                 -- ID người dùng (UserID) đã có
    IN p_BusinessAddress NVARCHAR(255), -- Địa chỉ kinh doanh
    IN p_BusinessName NVARCHAR(255) -- Tên doanh nghiệp (không muốn là doanh nghiệp thì cho NULL, cho khác NULL nếu Type là Business)
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