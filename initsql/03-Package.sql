DELIMITER //
CREATE PROCEDURE CreatePackage(
    IN p_OrderID INT,   -- Mã đơn hàng (đảm bảo đã tồn tại))
    IN p_Status VARCHAR(50),    -- Trạng thái gói hàng
    IN p_Quantity INT -- Số lượng sản phẩm trong gói (phải > 0)
)
BEGIN
    INSERT INTO `Package` (OrderID, WarehouseID, PackagedAt, Status, Quantity)
    VALUES (p_OrderID, NULL, NOW(), p_Status, p_Quantity);
END;
//
DELIMITER ;

-- Trigger kiểm tra Quantity > 0 khi insert vào Package
DELIMITER //
CREATE TRIGGER trg_Package_Quantity_Positive
BEFORE INSERT ON `Package`
FOR EACH ROW
BEGIN
    IF NEW.Quantity <= 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Quantity in Package must be greater than 0';
    END IF;
END;
//
DELIMITER ;

-- Thủ tục cập nhật Status của Package
DELIMITER //
CREATE PROCEDURE UpdatePackageStatus(
    IN p_PackageID INT,
    IN p_Status VARCHAR(50)
)
BEGIN
    UPDATE `Package`
    SET Status = p_Status
    WHERE PackageID = p_PackageID;
END;
DELIMITER ;

-- Thủ tục cập nhật Quantity của Package (Quantity phải > 0)
DELIMITER //
CREATE PROCEDURE UpdatePackageQuantity(
    IN p_PackageID INT,
    IN p_Quantity INT
)
BEGIN
    IF p_Quantity <= 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Quantity in Package must be greater than 0';
    END IF;
    UPDATE `Package`
    SET Quantity = p_Quantity
    WHERE PackageID = p_PackageID;
END;
//
DELIMITER ;