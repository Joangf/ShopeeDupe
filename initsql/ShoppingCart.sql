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


DELIMITER //

-- tạo order từ cart và chọn thanh toán
CREATE PROCEDURE sp_Checkout(
    IN p_UserID INT,
    IN p_ShippingAddress NVARCHAR(255),
    IN p_PaymentMethod NVARCHAR(50)
)
BEGIN
    DECLARE v_CartID INT;
    DECLARE v_TotalAmount DECIMAL(15,2) DEFAULT 0;
    DECLARE v_OrderID INT;
    DECLARE v_PackageID INT;
    DECLARE v_ItemCount INT;
    
    -- Xử lý lỗi: Nếu có lỗi SQL bất kỳ, Rollback toàn bộ
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        RESIGNAL; -- Báo lại lỗi ra ngoài
    END;

    -- BẮT ĐẦU TRANSACTION
    START TRANSACTION;

    -- 1. Lấy CartID
    SELECT CartID INTO v_CartID FROM ShoppingCart WHERE CustomerID = p_UserID LIMIT 1;

    -- Check: Có giỏ hàng không?
    IF v_CartID IS NULL THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Lỗi: Khách hàng chưa có giỏ hàng.';
    END IF;

    -- Check: Giỏ hàng có rỗng không?
    SELECT COUNT(*) INTO v_ItemCount FROM CartDetail WHERE CartID = v_CartID;
    IF v_ItemCount = 0 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Lỗi: Giỏ hàng đang trống, không thể thanh toán.';
    END IF;

    -- 2. Kiểm tra tồn kho (Stock Check)
    -- Nếu có bất kỳ sản phẩm nào mua nhiều hơn tồn kho -> Báo lỗi ngay
    IF EXISTS (
        SELECT 1
        FROM CartDetail cd
        JOIN Product p ON cd.ProductID = p.ProductID
        WHERE cd.CartID = v_CartID
        AND cd.Quantity > p.StockQuantity
    ) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Lỗi: Một số sản phẩm trong giỏ đã hết hàng hoặc không đủ số lượng.';
    END IF;

    -- 3. Tính tổng tiền (Ưu tiên dùng DiscountPrice nếu có)
    -- Logic: Nếu DiscountPrice > 0 thì lấy, ngược lại lấy Price
    SELECT SUM(cd.Quantity * COALESCE(NULLIF(p.DiscountPrice, 0), p.Price)) 
    INTO v_TotalAmount
    FROM CartDetail cd
    JOIN Product p ON cd.ProductID = p.ProductID
    WHERE cd.CartID = v_CartID;

    -- 4. Tạo Đơn Hàng (Order)
    INSERT INTO `Order` (CustomerID, OrderDate, Status, TotalAmount, ShippingAddress, PaymentMethod)
    VALUES (p_UserID, NOW(), 'Pending', v_TotalAmount, p_ShippingAddress, p_PaymentMethod);
    
    SET v_OrderID = LAST_INSERT_ID(); -- Lấy ID vừa tạo

    -- 5. Tạo Gói Hàng (Package)
    -- Mặc định tạo 1 gói hàng cho đơn này, Status là 'Processing'
    INSERT INTO `Package` (OrderID, WarehouseID, PackagedAt, Status, Quantity)
    VALUES (v_OrderID, NULL, NOW(), 'Processing', v_ItemCount); -- WarehouseID để NULL, Thủ kho sẽ set sau
    
    SET v_PackageID = LAST_INSERT_ID();

    -- 6. Chuyển dữ liệu từ CartDetail -> PackageItem
    INSERT INTO PackageItem (ProductID, PackageID, PackageItemID, Quantity)
    SELECT 
        cd.ProductID, 
        v_PackageID, 
        ROW_NUMBER() OVER (ORDER BY cd.ProductID), -- Tự sinh ID dòng item (1, 2, 3...)
        cd.Quantity
    FROM CartDetail cd
    WHERE cd.CartID = v_CartID;

    -- 7. Trừ tồn kho (Update Stock)
    UPDATE Product p
    JOIN CartDetail cd ON p.ProductID = cd.ProductID
    SET p.StockQuantity = p.StockQuantity - cd.Quantity
    WHERE cd.CartID = v_CartID;

    -- 8. Xóa sạch giỏ hàng (Chỉ xóa detail, giữ lại vỏ Cart hoặc xóa cả tùy logic, ở đây xóa detail)
    DELETE FROM CartDetail WHERE CartID = v_CartID;

    -- COMMIT TRANSACTION
    COMMIT;

    -- Trả về thông tin đơn hàng vừa tạo
    SELECT v_OrderID AS OrderID, v_TotalAmount AS Total, 'Order created successfully' AS Message;

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

-- ===================================
-- Test for checkout
-- ===================================
-- --- BƯỚC 1: CHUẨN BỊ DỮ LIỆU ---

-- 1. Tạo User & Customer
-- INSERT INTO `User` (FullName, Email) VALUES ('Khach Mua Hang', 'buyer@test.com');
-- SET @UID = LAST_INSERT_ID();
-- INSERT INTO `Customer` (CustomerID, Type) VALUES (@UID, 'VIP');

-- -- 2. Tạo Sản phẩm (SellerID = 3 giả định đã có)
-- -- Laptop: Giá 10tr, Tồn kho 5 cái
-- INSERT INTO Product (SellerID, Name, Price, DiscountPrice, StockQuantity) 
-- VALUES (3, 'Laptop Gaming', 10000000, NULL, 5);
-- SET @PID1 = LAST_INSERT_ID();

-- -- Chuột: Giá 200k, Giảm còn 150k, Tồn kho 10 cái
-- INSERT INTO Product (SellerID, Name, Price, DiscountPrice, StockQuantity) 
-- VALUES (3, 'Mouse RGB', 200000, 150000, 10);
-- SET @PID2 = LAST_INSERT_ID();

-- -- 3. Thêm vào giỏ hàng (Dùng Procedure sp_AddToCart đã viết trước đó)
-- CALL sp_AddToCart(@UID, @PID1, 1); -- Mua 1 Laptop
-- CALL sp_AddToCart(@UID, @PID2, 2); -- Mua 2 Chuột

-- -- Kiểm tra giỏ hàng trước khi thanh toán
-- SELECT * FROM CartDetail WHERE CartID = (SELECT CartID FROM ShoppingCart WHERE CustomerID = @UID);


-- --- BƯỚC 2: CHẠY THANH TOÁN (CHECKOUT) ---

-- Gọi lệnh tạo đơn hàng
-- Địa chỉ: '123 Đường ABC', Thanh toán: 'COD'
-- CALL sp_Checkout(@UID, '123 Đường ABC', 'COD');


-- --- BƯỚC 3: KIỂM TRA KẾT QUẢ SAU KHI CHẠY ---

-- 1. Kiểm tra bảng Order (Phải có 1 dòng mới, TotalAmount = 1*10tr + 2*150k = 10.300.000)
-- SELECT * FROM `Order` WHERE CustomerID = @UID;

-- 2. Kiểm tra bảng Package & PackageItem (Hàng đã vào gói chưa?)
-- SELECT p.PackageID, p.Status, pi.ProductID, pi.Quantity 
-- FROM `Package` p
-- JOIN PackageItem pi ON p.PackageID = pi.PackageID
-- JOIN `Order` o ON p.OrderID = o.OrderID
-- WHERE o.CustomerID = @UID;

-- -- 3. Kiểm tra Tồn kho (Laptop phải còn 4, Chuột phải còn 8)
-- SELECT Name, StockQuantity FROM Product WHERE ProductID IN (@PID1, @PID2);

-- -- 4. Kiểm tra Giỏ hàng (Phải trống rỗng)
-- SELECT * FROM CartDetail WHERE CartID = (SELECT CartID FROM ShoppingCart WHERE CustomerID = @UID);

