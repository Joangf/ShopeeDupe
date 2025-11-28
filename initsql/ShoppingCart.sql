DELIMITER //

-- 1. PROCEDURE THÊM SẢN PHẨM VÀO GIỎ (Add/Insert)
CREATE PROCEDURE `sp_AddToCart`(
    IN p_CustomerID INT,
    IN p_ProductID INT,
    IN p_Quantity INT
)
BEGIN
    DECLARE v_CartID INT;
    DECLARE v_Count INT;

    -- Kiểm tra số lượng hợp lệ
    IF p_Quantity <= 0 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Số lượng phải lớn hơn 0';
    END IF;

    -- Kiểm tra xem User này đã có Giỏ hàng chưa
    SELECT CartID INTO v_CartID FROM ShoppingCart WHERE CustomerID = p_CustomerID LIMIT 1;

    -- Nếu chưa có giỏ hàng, tạo mới
    IF v_CartID IS NULL THEN
        INSERT INTO ShoppingCart (CustomerID) VALUES (p_CustomerID);
        SET v_CartID = LAST_INSERT_ID();
    END IF;

    -- Kiểm tra xem sản phẩm đã có trong giỏ hàng này chưa
    SELECT COUNT(*) INTO v_Count FROM CartDetail 
    WHERE CartID = v_CartID AND ProductID = p_ProductID;

    IF v_Count > 0 THEN
        -- Nếu có rồi -> Cộng dồn số lượng
        UPDATE CartDetail 
        SET Quantity = Quantity + p_Quantity
        WHERE CartID = v_CartID AND ProductID = p_ProductID;
    ELSE
        -- Nếu chưa có -> Thêm dòng mới
        INSERT INTO CartDetail (CartID, ProductID, Quantity) 
        VALUES (v_CartID, p_ProductID, p_Quantity);
    END IF;
    
    -- Trả về kết quả xác nhận
    SELECT 'Added successfully' AS Message, v_CartID as CartID;
END //

-- 2. PROCEDURE SỬA SỐ LƯỢNG SẢN PHẨM (Update)
CREATE PROCEDURE `sp_UpdateCartItem`(
    IN p_CustomerID INT,
    IN p_ProductID INT,
    IN p_NewQuantity INT
)
BEGIN
    DECLARE v_CartID INT;

    -- Lấy CartID của khách hàng
    SELECT CartID INTO v_CartID FROM ShoppingCart WHERE CustomerID = p_CustomerID LIMIT 1;

    IF v_CartID IS NULL THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Khách hàng chưa có giỏ hàng';
    END IF;

    IF p_NewQuantity <= 0 THEN
        -- Nếu số lượng <= 0, coi như là lệnh Xóa
        DELETE FROM CartDetail WHERE CartID = v_CartID AND ProductID = p_ProductID;
        SELECT 'Item removed (quantity <= 0)' AS Message;
    ELSE
        -- Cập nhật số lượng mới
        UPDATE CartDetail 
        SET Quantity = p_NewQuantity
        WHERE CartID = v_CartID AND ProductID = p_ProductID;
        
        -- Kiểm tra xem có dòng nào được update không
        IF ROW_COUNT() = 0 THEN
             SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Sản phẩm không tồn tại trong giỏ hàng';
        ELSE
             SELECT 'Updated successfully' AS Message;
        END IF;
    END IF;
END //
DELIMITER ;

DROP PROCEDURE IF EXISTS `sp_RemoveFromCart`;

DELIMITER //

CREATE PROCEDURE `sp_RemoveFromCart`(
    IN p_CustomerID INT,
    IN p_ProductID INT
)
BEGIN
    DECLARE v_CartID INT;
    DECLARE v_RowsAffected INT;

    -- 1. Kiểm tra User này có Giỏ hàng (ShoppingCart) hay chưa?
    SELECT CartID INTO v_CartID 
    FROM ShoppingCart 
    WHERE CustomerID = p_CustomerID 
    LIMIT 1;

    -- CHECK 1: Nếu chưa có giỏ hàng thì báo lỗi ngay
    IF v_CartID IS NULL THEN
        SIGNAL SQLSTATE '45000' 
        SET MESSAGE_TEXT = 'Lỗi: Khách hàng chưa có giỏ hàng nào.';
    END IF;

    -- 2. Thực hiện xóa
    DELETE FROM CartDetail 
    WHERE CartID = v_CartID AND ProductID = p_ProductID;
    
    -- Lấy số dòng vừa bị tác động bởi lệnh DELETE trên
    SET v_RowsAffected = ROW_COUNT();

    -- CHECK 2: Kiểm tra xem có xóa được dòng nào không?
    IF v_RowsAffected > 0 THEN
        -- Trường hợp: Xóa thành công
        SELECT 'Removed successfully' AS Message, p_ProductID AS RemovedProduct;
    ELSE
        -- Trường hợp: Có giỏ hàng, nhưng sản phẩm này KHÔNG nằm trong giỏ
        SIGNAL SQLSTATE '45000' 
        SET MESSAGE_TEXT = 'Lỗi: Sản phẩm này không tồn tại trong giỏ hàng của bạn.';
    END IF;

END //

DELIMITER ;


-- data

-- Thêm sản phẩm (Điền cứng ProductID để không cần sửa Schema)
-- INSERT INTO Product (ProductID, SellerID, Name, Price, StockQuantity, Status)
-- VALUES
-- (1, 3, 'Laptop Gaming Dell', 25000000, 10, 'Active'),
-- (2, 3, 'Chuột không dây', 500000, 50, 'Active'),
-- (3, 4, 'Áo Thun Mùa Hè', 200000, 100, 'Active'),
-- (4, 4, 'Quần Jeans Nam', 500000, 80, 'Active'),
-- (5, 8, 'iPhone 15 Pro Max', 30000000, 20, 'Active');


-- --- BẮT ĐẦU TEST ---

-- 1. Khách A mua Laptop (ID 1)
-- CALL sp_AddToCart(1, 1, 1); 

-- 2. Khách A mua thêm Chuột (ID 2)
-- CALL sp_AddToCart(1, 2, 2); 

-- 3. Khách A mua thêm 1 Laptop nữa
-- CALL sp_AddToCart(1, 1, 1); 

-- 4. Khách N N N (ID 6) mua iPhone (ID 5)
-- CALL sp_AddToCart(6, 5, 1); 

-- 5. Update: Khách A giảm chuột còn 1 cái
-- CALL sp_UpdateCartItem(1, 2, 1);

-- 6. Xóa: Khách N N N xóa iPhone khỏi giỏ
-- CALL sp_RemoveFromCart(6, 5);

-- --- KIỂM TRA KẾT QUẢ ---
-- SELECT 
--     u.FullName,
--     sc.CartID,
--     p.Name AS ProductName,
--     cd.Quantity,
--     FORMAT(p.Price * cd.Quantity, 0) AS SubTotal
-- FROM User u
-- JOIN ShoppingCart sc ON u.UserID = sc.CustomerID
-- JOIN CartDetail cd ON sc.CartID = cd.CartID
-- JOIN Product p ON cd.ProductID = p.ProductID
-- WHERE u.UserID IN (1, 6);


-- SELECT * from CartDetail