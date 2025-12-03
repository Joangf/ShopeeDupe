-- Nếu bắt buộc phải dùng stored procedure để trả về bảng:
DELIMITER //
CREATE PROCEDURE sp_GetOrdersByUser(IN p_UserID INT)
BEGIN
    SELECT *
    FROM `Order`
    WHERE CustomerID = p_UserID
    ORDER BY OrderDate ASC;
END;
//
DELIMITER ;

-- MySQL không hỗ trợ table-valued function (function trả về bảng).

-- 
-- HƯỚNG DẪN SỬ DỤNG sp_GetOrdersByUser TRONG JAVASCRIPT (Node.js)
-- 
-- Ví dụ sử dụng với mysql2:
-- 
-- const mysql = require('mysql2/promise');
-- const connection = await mysql.createConnection({host, user, password, database});
-- const [rows] = await connection.query('CALL sp_GetOrdersByUser(?)', [userId]);
-- // rows[0] là kết quả trả về (danh sách order)
-- 
-- Ví dụ sử dụng với mysql:
-- 
-- const mysql = require('mysql');
-- const connection = mysql.createConnection({host, user, password, database});
-- connection.query('CALL sp_GetOrdersByUser(?)', [userId], (err, results) => {
--   if (err) throw err;
--   // results[0] là danh sách order
-- });

DELIMITER //

DROP PROCEDURE IF EXISTS `sp_CreateOrder` //

CREATE PROCEDURE `sp_CreateOrder`(
    IN p_UserID INT,
    IN p_ShippingAddress NVARCHAR(255)
)
BEGIN
    DECLARE v_CartID INT;
    DECLARE v_TotalAmount DECIMAL(15,2) DEFAULT 0;
    DECLARE v_OrderID INT;
    DECLARE v_PackageID INT;
    DECLARE v_ItemCount INT;

    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        RESIGNAL;
    END;

    START TRANSACTION;

    -- 1. Validate Input
    IF p_ShippingAddress IS NULL OR TRIM(p_ShippingAddress) = '' THEN
         SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Lỗi: Vui lòng nhập địa chỉ giao hàng.';
    END IF;

    -- 2. Kiểm tra giỏ hàng
    SELECT CartID INTO v_CartID FROM ShoppingCart WHERE CustomerID = p_UserID LIMIT 1;
    SELECT COUNT(*) INTO v_ItemCount FROM CartDetail WHERE CartID = v_CartID;
    
    IF v_CartID IS NULL OR v_ItemCount = 0 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Lỗi: Giỏ hàng trống, không thể tạo đơn.';
    END IF;

    -- 3. Check sơ bộ tồn kho (Soft Check)
    IF EXISTS (
        SELECT 1 FROM CartDetail cd
        JOIN Product p ON cd.ProductID = p.ProductID
        WHERE cd.CartID = v_CartID AND cd.Quantity > p.StockQuantity
    ) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Lỗi: Có sản phẩm không đủ số lượng tồn kho.';
    END IF;

    -- 4. Tính tổng tiền
    SELECT SUM(cd.Quantity * COALESCE(NULLIF(p.DiscountPrice, 0), p.Price)) 
    INTO v_TotalAmount
    FROM CartDetail cd
    JOIN Product p ON cd.ProductID = p.ProductID
    WHERE cd.CartID = v_CartID;

    -- 5. Tạo Order (Trạng thái Pending)
    INSERT INTO `Order` (CustomerID, OrderDate, Status, TotalAmount, ShippingAddress, PaymentMethod)
    VALUES (p_UserID, NOW(), 'Pending', v_TotalAmount, p_ShippingAddress, NULL);
    
    SET v_OrderID = LAST_INSERT_ID();

    -- 6. Tạo Package
    INSERT INTO `Package` (OrderID, WarehouseID, PackagedAt, Status, Quantity)
    VALUES (v_OrderID, NULL, NOW(), 'Pending', v_ItemCount);
    
    SET v_PackageID = LAST_INSERT_ID();

    -- 7. Tạo PackageItem (KHẮC PHỤC LỖI DUPLICATE TẠI ĐÂY)
    -- Chiến thuật: Gán PackageItemID bằng chính PackageID.
    -- Vì PackageID là Unique, nên cặp (PackageID, ProductID) sẽ luôn Unique.
    INSERT INTO PackageItem (ProductID, PackageID, PackageItemID, Quantity)
    SELECT 
        cd.ProductID, 
        v_PackageID, 
        v_PackageID, -- Sử dụng PackageID làm ID dòng
        cd.Quantity
    FROM CartDetail cd
    WHERE cd.CartID = v_CartID;

    COMMIT;

    -- 8. Trả về thông tin đơn hàng để khách xem lại
    SELECT v_OrderID AS OrderID, v_TotalAmount AS TotalAmount, 'Order created successfully. Please proceed to payment.' AS Message;

END //
DELIMITER ;

DELIMITER //

DROP PROCEDURE IF EXISTS `sp_ProcessPayment` //

CREATE PROCEDURE `sp_ProcessPayment`(
    IN p_UserID INT,
    IN p_OrderID INT,
    IN p_PaymentMethod NVARCHAR(50)
)
BEGIN
    DECLARE v_CartID INT;
    DECLARE v_CheckOrderID INT;
    
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        RESIGNAL;
    END;

    START TRANSACTION;

    -- 1. Validate Payment
    IF p_PaymentMethod IS NULL OR TRIM(p_PaymentMethod) = '' THEN
         SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Lỗi: Vui lòng chọn phương thức thanh toán.';
    END IF;

    -- 2. Validate Order (Phải là Pending và thuộc về User)
    SELECT OrderID INTO v_CheckOrderID 
    FROM `Order` 
    WHERE OrderID = p_OrderID AND CustomerID = p_UserID AND Status = 'Pending';

    IF v_CheckOrderID IS NULL THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Lỗi: Đơn hàng không hợp lệ hoặc đã thanh toán.';
    END IF;

    -- 3. HARD CHECK TỒN KHO & KHÓA DÒNG (FOR UPDATE)
    -- Join qua bảng PackageItem để kiểm tra
    IF EXISTS (
        SELECT 1
        FROM PackageItem pi
        JOIN `Package` pk ON pi.PackageID = pk.PackageID
        JOIN Product p ON pi.ProductID = p.ProductID
        WHERE pk.OrderID = p_OrderID
        AND pi.Quantity > p.StockQuantity
        FOR UPDATE -- Khóa dòng Product để ngăn người khác mua tranh
    ) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Lỗi: Sản phẩm đã hết hàng ngay trước khi bạn thanh toán.';
    END IF;

    -- 4. TRỪ TỒN KHO (Update Stock)
    UPDATE Product p
    JOIN PackageItem pi ON p.ProductID = pi.ProductID
    JOIN `Package` pk ON pi.PackageID = pk.PackageID
    SET p.StockQuantity = p.StockQuantity - pi.Quantity
    WHERE pk.OrderID = p_OrderID;

    -- 5. HOÀN TẤT ĐƠN HÀNG
    UPDATE `Order`
    SET 
        PaymentMethod = p_PaymentMethod,
        Status = 'Processing',
        OrderDate = NOW()
    WHERE OrderID = p_OrderID;
    
    UPDATE `Package` SET Status = 'Processing' WHERE OrderID = p_OrderID;

    -- 6. XÓA GIỎ HÀNG (Dọn dẹp)
    SELECT CartID INTO v_CartID FROM ShoppingCart WHERE CustomerID = p_UserID LIMIT 1;
    IF v_CartID IS NOT NULL THEN
        DELETE FROM CartDetail WHERE CartID = v_CartID;
    END IF;

    COMMIT;

    SELECT p_OrderID AS OrderID, 'Payment confirmed. Stock deducted.' AS Message;

END //
DELIMITER ;


