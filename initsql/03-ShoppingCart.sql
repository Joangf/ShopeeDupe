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
    -- Kiểm tra số lượng sản phẩm có đủ yêu cầu thêm vào giỏ hàng 
	IF EXISTS (
		SELECT 1
        FROM Product p WHERE p_ProductID = p.ProductID
        AND p_Quantity > p.StockQuantity
    ) THEN SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Lỗi: Số lượng sản phẩm không đủ để thêm vào giỏ.';
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

-- 2. PROCEDURE SỬA SỐ LƯỢNG SẢN PHẨM (Update Nâng Cao)
CREATE PROCEDURE `sp_UpdateCartItem`(
    IN p_CustomerID INT,
    IN p_ProductID INT,
    IN p_NewQuantity INT
)
BEGIN
    DECLARE v_CartID INT;
    DECLARE v_CurrentQty INT;
    DECLARE v_FinalQty INT;

    -- 1. VALIDATION (Kiểm tra dữ liệu đầu vào)
    IF NOT EXISTS (SELECT 1 FROM Customer WHERE CustomerID = p_CustomerID) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Lỗi: Khách hàng không tồn tại.';
    END IF;

    IF NOT EXISTS (SELECT 1 FROM Product WHERE ProductID = p_ProductID) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Lỗi: Sản phẩm không tồn tại.';
    END IF;

    -- 2. Lấy CartID
    SELECT CartID INTO v_CartID FROM ShoppingCart WHERE CustomerID = p_CustomerID LIMIT 1;

    IF v_CartID IS NULL THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Lỗi: Khách hàng chưa có giỏ hàng.';
    END IF;

    -- 3. Lấy số lượng hiện tại trong giỏ
    SELECT Quantity INTO v_CurrentQty 
    FROM CartDetail 
    WHERE CartID = v_CartID AND ProductID = p_ProductID;

    -- Nếu sản phẩm không có trong giỏ thì báo lỗi luôn
    IF v_CurrentQty IS NULL THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Lỗi: Sản phẩm này chưa có trong giỏ hàng để cập nhật.';
    END IF;

    -- 4. XỬ LÝ LOGIC SỐ LƯỢNG
    IF p_NewQuantity = 0 THEN
        -- Trường hợp A: Nhập 0 -> Xóa
        DELETE FROM CartDetail WHERE CartID = v_CartID AND ProductID = p_ProductID;
        SELECT 'Item removed (quantity set to 0)' AS Message;

    ELSEIF p_NewQuantity > 0 THEN
        -- Trường hợp B: Số dương -> Gán trực tiếp (Set Quantity)
        UPDATE CartDetail 
        SET Quantity = p_NewQuantity
        WHERE CartID = v_CartID AND ProductID = p_ProductID;
        SELECT 'Updated successfully' AS Message;

    ELSE 
        -- Trường hợp C: Số âm (p_NewQuantity < 0) -> Thực hiện trừ
        -- Ví dụ: Đang có 5, truyền vào -2 -> Còn 3.
        SET v_FinalQty = v_CurrentQty + p_NewQuantity; 

        IF v_FinalQty > 0 THEN
            -- C1: Đủ để trừ -> Update số còn lại
            UPDATE CartDetail 
            SET Quantity = v_FinalQty
            WHERE CartID = v_CartID AND ProductID = p_ProductID;
            SELECT 'Quantity subtracted successfully' AS Message, v_FinalQty AS NewQuantity;
        ELSE
            -- C2: Không đủ để trừ (về 0 hoặc âm) -> Xóa luôn
            DELETE FROM CartDetail WHERE CartID = v_CartID AND ProductID = p_ProductID;
            -- Trả về message tiếng Anh đúng yêu cầu
            SELECT 'Current quantity is insufficient for update (item removed from cart)' AS Message;
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



-- -- ============================================================
-- -- PHẦN 0: CHUẨN BỊ DỮ LIỆU (SETUP)
-- -- Xóa sạch giỏ hàng của User 10, 11, 12, 13 để test từ đầu
-- -- ============================================================
-- DELETE FROM CartDetail WHERE CartID IN (SELECT CartID FROM ShoppingCart WHERE CustomerID IN (10, 11, 12, 13));
-- DELETE FROM ShoppingCart WHERE CustomerID IN (10, 11, 12, 13);

-- -- Reset lại kho của một số sản phẩm quan trọng để test
-- -- Product 1: Stock 50 (Nhiều)
-- -- Product 16: Stock 1 (Ít - Để test hết hàng)
-- UPDATE Product SET StockQuantity = 50 WHERE ProductID = 1;
-- UPDATE Product SET StockQuantity = 1 WHERE ProductID = 16;
-- SELECT ProductID, StockQuantity FROM Product WHERE ProductID = 1 OR ProductID = 16;
-- SELECT '--- SETUP COMPLETE ---' AS Status;

-- -- ============================================================
-- -- PHẦN 1: TEST GIỎ HÀNG (ADD - UPDATE - REMOVE)
-- -- User Test: 10
-- -- ============================================================

-- -- TEST 1: Thêm mới vào giỏ (Khách hàng chưa có giỏ)
-- -- Hành động: User 10 mua 2 cái Product 1.
-- -- Kỳ vọng: Tự động tạo ShoppingCart, Insert vào CartDetail.
-- CALL sp_AddToCart(10, 1, 2);

-- -- TEST 2: Cộng dồn số lượng (Merge Logic)
-- -- Hành động: User 10 mua tiếp 3 cái Product 1 nữa.
-- -- Kỳ vọng: Quantity của Product 1 tăng lên 5 (2 + 3).
-- CALL sp_AddToCart(10, 1, 3);

-- -- TEST 3: Thêm số lượng âm (Validate)
-- -- Hành động: User 10 thêm -5 sản phẩm.
-- -- Kỳ vọng: LỖI "Số lượng phải lớn hơn 0".
-- CALL sp_AddToCart(10, 1, -5);

-- -- TEST 4: Sửa số lượng (Update)
-- -- Hành động: User 10 đổi ý, chỉ muốn mua 1 cái Product 1 thôi.
-- -- Kỳ vọng: Quantity cập nhật thành 1.
-- CALL sp_UpdateCartItem(10, 1, 1);

-- -- TEST 5: Sửa số lượng về 0 (Logic Xóa ngầm)
-- -- Hành động: User 10 update Product 1 thành 0.
-- -- Kỳ vọng: Sản phẩm bị xóa khỏi CartDetail. Message: "Item removed...".
-- CALL sp_UpdateCartItem(10, 1, 0);

-- -- TEST 6: Xóa sản phẩm không tồn tại (Error Handling)
-- -- Hành động: User 10 cố xóa Product 999.
-- -- Kỳ vọng: LỖI "Sản phẩm này không tồn tại trong giỏ hàng...".
-- CALL sp_RemoveFromCart(10, 999);

-- -- TEST 7: Xóa sản phẩm thành công (Happy Path)
-- -- Setup: Thêm lại Product 1 cho User 10 để xóa.
-- CALL sp_AddToCart(10, 1, 5); 
-- -- Hành động: Xóa Product 1.
-- -- Kỳ vọng: Thành công. Message "Removed successfully".
-- CALL sp_RemoveFromCart(10, 1);
-- -- TEST 8: User 11 mua Product 16 (Kho chỉ còn 1), cố mua 5 cái.
-- CALL sp_AddToCart(11, 16, 5); 

-- -- ============================================================
-- -- PHẦN 2: TEST THANH TOÁN (CHECKOUT)
-- -- User Test: 11 (Test Lỗi), 12 (Test Thành công)
-- -- ============================================================

-- -- TEST 9: Thanh toán giỏ hàng rỗng
-- -- Hành động: User 11 chưa mua gì, bấm CreateOrder.
-- -- Kỳ vọng: LỖI "Lỗi: Giỏ hàng trống, không thể tạo đơn."
-- CALL sp_CreateOrder(11, 'Dia chi A');

-- -- TEST 10: Thanh toán Thành công (Happy Path)
-- -- Setup: User 12 mua Product 1 (Giá 20tr, Kho 50) và Product 16 (Giá 2tr, Kho 1).
-- -- Hành động: Mua 2 cái Prod 1 và 1 cái Prod 16 (Vét sạch kho Prod 16).
-- CALL sp_AddToCart(12, 1, 2);
-- CALL sp_AddToCart(12, 16, 1);

-- -- Thực hiện CreateOrder
-- -- Kỳ vọng: 
-- CALL sp_CreateOrder(12, '123 Wall Street');
-- CALL sp_ProcessPayment(12, 4, 'COD');
-- -- ============================================================
-- -- PHẦN 3: TEST GIÁ & KHUYẾN MÃI (DISCOUNT LOGIC)
-- -- User Test: 13
-- -- ============================================================

-- -- TEST 11: Kiểm tra tính tiền ưu tiên giá giảm
-- -- Setup: Product 2 (Samsung S24) có Price=18tr.
-- -- Giả sử ta set DiscountPrice = 15tr cho Product 2.
-- UPDATE Product SET DiscountPrice = 15000000 WHERE ProductID = 2;

-- -- Hành động: User 13 mua 2 cái Product 2.
-- CALL sp_AddToCart(13, 2, 2);

-- -- Thực hiện Checkout
-- -- Kỳ vọng: TotalAmount của Order phải là 30.000.000 (15tr * 2) CHỨ KHÔNG PHẢI 36tr.
-- CALL sp_CreateOrder(13, 'Hanoi');
-- CALL sp_ProcessPayment(13, 5, 'Banking');

-- -- ============================================================
-- -- PHẦN 4: KIỂM TRA KẾT QUẢ CUỐI CÙNG
-- -- ============================================================

-- SELECT '--- KẾT QUẢ KHO (STOCK) ---' AS Title;
-- -- Prod 1: Ban đầu 50 -> User 12 mua 2 -> Còn 48
-- -- Prod 2: Ban đầu 40 -> User 13 mua 2 -> Còn 38
-- -- Prod 16: Ban đầu 1 -> User 12 mua 1 -> Còn 0
-- SELECT ProductID, Name, Price, DiscountPrice, StockQuantity 
-- FROM Product WHERE ProductID IN (1, 16, 2);

-- SELECT '--- ĐƠN HÀNG VỪA TẠO (ORDER) ---' AS Title;
-- -- Kiểm tra Order của User 12 và 13
-- SELECT OrderID, CustomerID, TotalAmount, Status, OrderDate 
-- FROM `Order` WHERE CustomerID IN (12, 13)
-- ORDER BY OrderID DESC;

-- SELECT '--- GÓI HÀNG (PACKAGE & ITEMS) ---' AS Title;
-- -- Kiểm tra chi tiết gói hàng
-- SELECT 
--     p.PackageID, 
--     p.OrderID, 
--     pi.ProductID, 
--     pi.Quantity 
-- FROM `Package` p
-- JOIN PackageItem pi ON p.PackageID = pi.PackageID
-- JOIN `Order` o ON p.OrderID = o.OrderID
-- WHERE o.CustomerID IN (12, 13);

-- SELECT '--- GIỎ HÀNG (PHẢI TRỐNG RỖNG) ---' AS Title;
-- -- User 12 và 13 đã thanh toán xong -> Giỏ phải rỗng
-- SELECT * FROM CartDetail WHERE CartID IN (SELECT CartID FROM ShoppingCart WHERE CustomerID IN (12, 13));



-- -- --- CHUẨN BỊ DỮ LIỆU TEST ---
-- -- Xóa giỏ hàng cũ của User 10
-- DELETE FROM CartDetail WHERE CartID = (SELECT CartID FROM ShoppingCart WHERE CustomerID = 10);
-- -- Thêm vào 10 sản phẩm (Product 1) để bắt đầu test
-- CALL sp_AddToCart(10, 1, 10); 
-- -- Kiểm tra: Lúc này Quantity = 10.
-- SELECT * FROM CartDetail WHERE CartID = (SELECT CartID FROM ShoppingCart WHERE CustomerID = 10);


-- -- --- NHÓM A: TEST VALIDATION (Kiểm tra ID) ---

-- -- TEST 1: Update cho Customer không tồn tại
-- -- Kỳ vọng: Lỗi "Lỗi: Khách hàng không tồn tại."
-- CALL sp_UpdateCartItem(9999, 1, 5);

-- -- TEST 2: Remove sản phẩm không tồn tại
-- -- Kỳ vọng: Lỗi "Lỗi: Sản phẩm không tồn tại."
-- CALL sp_RemoveFromCart(10, 9999);


-- -- --- NHÓM B: TEST LOGIC UPDATE SỐ ÂM (< 0) ---

-- -- TEST 3: Trừ thành công (Đủ số lượng)
-- -- Đang có 10, trừ đi 3 (truyền -3).
-- -- Kỳ vọng: Còn 7. Message: "Quantity subtracted successfully".
-- CALL sp_UpdateCartItem(10, 1, -3);

-- -- TEST 4: Trừ thất bại (Không đủ số lượng - Xóa luôn)
-- -- Đang có 7 (sau Test 3), trừ đi 10 (truyền -10).
-- -- Kỳ vọng: Xóa khỏi giỏ. Message: "Current quantity is insufficient for update (item removed from cart)".
-- CALL sp_UpdateCartItem(10, 1, -10);


-- -- --- NHÓM C: TEST LOGIC KHÁC ---

-- -- Chuẩn bị lại: Thêm 5 cái Product 1
-- CALL sp_AddToCart(10, 1, 5);

-- -- TEST 5: Update số dương (Gán giá trị)
-- -- Truyền vào 20.
-- -- Kỳ vọng: Quantity thành 20. Message: "Updated successfully".
-- CALL sp_UpdateCartItem(10, 1, 20);

-- -- TEST 6: Update số 0 (Xóa)
-- -- Truyền vào 0.
-- -- Kỳ vọng: Xóa khỏi giỏ. Message: "Item removed (quantity set to 0)".
-- CALL sp_UpdateCartItem(10, 1, 0);

-- -- --- KIỂM TRA KẾT QUẢ CUỐI CÙNG ---
-- SELECT * FROM CartDetail WHERE CartID = (SELECT CartID FROM ShoppingCart WHERE CustomerID = 10);
-- SELECT * from Product;
