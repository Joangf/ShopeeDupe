DELIMITER $$

-- 1. Trigger chung cho INSERT và UPDATE trên bảng VOUCHER
-- Nhiệm vụ: Tự động tính RemainingQuantity. Nếu < 0 thì BÁO LỖI.
CREATE TRIGGER trg_voucher_protection
BEFORE UPDATE ON Voucher 
FOR EACH ROW
BEGIN
    -- Logic: Luôn lấy Tổng - Đã dùng
    SET NEW.RemainingQuantity = NEW.TotalQuantity - NEW.UsageCount;

    -- CHỐT CHẶN AN TOÀN: Nếu tính ra âm -> Rollback ngay lập tức
    IF NEW.RemainingQuantity < 0 THEN
        SIGNAL SQLSTATE '45000' 
        SET MESSAGE_TEXT = 'Lỗi: Voucher đã hết số lượng (Overuse prevented).';
    END IF;
END$$

-- (Tùy chọn) Trigger cho INSERT Voucher mới (để khởi tạo giá trị ban đầu)
CREATE TRIGGER trg_voucher_init
BEFORE INSERT ON Voucher
FOR EACH ROW
BEGIN
    IF NEW.UsageCount IS NULL THEN SET NEW.UsageCount = 0; END IF;
    IF NEW.TotalQuantity IS NULL THEN SET NEW.TotalQuantity = 0; END IF;
    SET NEW.RemainingQuantity = NEW.TotalQuantity - NEW.UsageCount;
END$$

DELIMITER ;

DELIMITER $$

-- 2. BEFORE INSERT: Kiểm tra hợp lệ cơ bản
CREATE TRIGGER trg_usevoucher_before_insert
BEFORE INSERT ON UseVoucher
FOR EACH ROW
BEGIN
    -- Chỉ cần kiểm tra Voucher có tồn tại hay không
    IF NOT EXISTS (SELECT 1 FROM Voucher WHERE VoucherID = NEW.VoucherID) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Lỗi: Voucher ID không tồn tại trong hệ thống.';
    END IF;
END$$

-- 3. AFTER INSERT: Cộng UsageCount (+1)
CREATE TRIGGER trg_usevoucher_after_insert
AFTER INSERT ON UseVoucher
FOR EACH ROW
BEGIN
    -- Cập nhật bảng cha. 
    -- Nếu cộng xong mà vượt quá TotalQuantity, Trigger ở PHẦN 2 sẽ báo lỗi và hủy lệnh này.
    UPDATE Voucher
    SET UsageCount = UsageCount + 1
    WHERE VoucherID = NEW.VoucherID;
END$$

-- 4. BEFORE DELETE: Kiểm tra điều kiện được phép hủy
DELIMITER $$

DROP TRIGGER IF EXISTS trg_usevoucher_before_delete;
CREATE TRIGGER trg_usevoucher_before_delete
BEFORE DELETE ON UseVoucher
FOR EACH ROW
BEGIN
    -- Khai báo biến
    DECLARE v_UsageCount INT DEFAULT NULL;
    DECLARE v_ExpiresAt DATETIME DEFAULT NULL;
    DECLARE v_Status VARCHAR(50) DEFAULT NULL;

    -- 1. LẤY DỮ LIỆU (Đã bỏ COUNT(*) để tránh lỗi 1140)
    SELECT UsageCount, ExpiresAt, Status 
    INTO v_UsageCount, v_ExpiresAt, v_Status
    FROM Voucher 
    WHERE VoucherID = OLD.VoucherID;

    -- 2. CHECK 1: KIỂM TRA TỒN TẠI
    -- Nếu select không ra dòng nào, các biến trên vẫn sẽ là NULL
    IF v_Status IS NULL THEN
        SIGNAL SQLSTATE '45000' 
        SET MESSAGE_TEXT = 'Lỗi: Voucher gốc không tồn tại (hoặc đã bị xóa), không thể cập nhật lại số lượng.';
    END IF;

    -- 3. CHECK 2: KHÔNG ĐƯỢC XÓA NẾU USAGECOUNT ĐANG LÀ 0
    IF v_UsageCount <= 0 THEN
         SIGNAL SQLSTATE '45000' 
         SET MESSAGE_TEXT = 'Lỗi logic: UsageCount đang bằng 0, không thể hoàn tác.';
    END IF;

    -- 4. CHECK 3: KHÔNG ĐƯỢC XÓA NẾU VOUCHER HẾT HẠN
    IF v_ExpiresAt IS NOT NULL AND v_ExpiresAt < NOW() THEN
        SIGNAL SQLSTATE '45000' 
        SET MESSAGE_TEXT = 'Không thể hủy lượt sử dụng vì Voucher đã hết hạn.';
    END IF;
    
    -- 5. CHECK 4: KHÔNG ĐƯỢC XÓA NẾU VOUCHER BỊ KHÓA
    IF v_Status IN ('Disabled', 'Banned') THEN
        SIGNAL SQLSTATE '45000' 
        SET MESSAGE_TEXT = 'Voucher này đã bị khóa, không thể thay đổi lịch sử.';
    END IF;
END$$

-- 5. AFTER DELETE: Trừ UsageCount (-1)
CREATE TRIGGER trg_usevoucher_after_delete
AFTER DELETE ON UseVoucher
FOR EACH ROW
BEGIN
    UPDATE Voucher
    SET UsageCount = GREATEST(UsageCount - 1, 0) -- Đảm bảo an toàn tuyệt đối
    WHERE VoucherID = OLD.VoucherID;
END$$

DELIMITER ;

DELIMITER //

CREATE PROCEDURE sp_UseVoucher(
    IN p_CustomerID INT,
    IN p_VoucherID INT
)
BEGIN
    -- Procedure này khá đơn giản vì logic kiểm tra tồn kho đã nằm ở Trigger.
    -- Ta chỉ cần Insert, nếu lỗi Trigger sẽ ném ra.
    
    -- Tùy chọn: Kiểm tra Customer có tồn tại không
    IF NOT EXISTS (SELECT 1 FROM Customer WHERE CustomerID = p_CustomerID) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Khách hàng không tồn tại.';
    END IF;

    -- Thực hiện Insert
    INSERT INTO UseVoucher (VoucherID, CustomerID, UsedDate)
    VALUES (p_VoucherID, p_CustomerID, NOW());

    -- Trả về kết quả
    SELECT 'Sử dụng Voucher thành công!' AS Message;
END //

DELIMITER ;

DELIMITER //

CREATE PROCEDURE sp_CancelVoucherUsage(
    IN p_CustomerID INT,
    IN p_VoucherID INT,
    IN p_UsedDate DATETIME -- NULL nếu muốn xóa lần dùng gần nhất (hoặc logic khác tùy bạn)
)
BEGIN
    DECLARE v_Count INT;

    -- BƯỚC 1: KIỂM TRA TỒN TẠI (Logic Raise Error bạn yêu cầu)
    SELECT COUNT(*) INTO v_Count
    FROM UseVoucher
    WHERE CustomerID = p_CustomerID 
      AND VoucherID = p_VoucherID
      AND (p_UsedDate IS NULL OR UsedDate = p_UsedDate);

    IF v_Count = 0 THEN
        SIGNAL SQLSTATE '45000' 
        SET MESSAGE_TEXT = 'Lỗi: Không tìm thấy lịch sử sử dụng Voucher này của khách hàng.';
    END IF;

    -- BƯỚC 2: THỰC HIỆN XÓA
    -- Lúc này Trigger UseVoucher BEFORE/AFTER DELETE sẽ hoạt động
    DELETE FROM UseVoucher 
    WHERE CustomerID = p_CustomerID 
      AND VoucherID = p_VoucherID
      AND (p_UsedDate IS NULL OR UsedDate = p_UsedDate)
    LIMIT 1; -- Chỉ xóa 1 dòng để an toàn

    SELECT 'Đã hủy sử dụng Voucher thành công.' AS Message;
END //

DELIMITER ;

DELIMITER //


CREATE PROCEDURE sp_ReportVoucherUsage(
    IN p_start_date DATE,
    IN p_end_date DATE,
    IN p_min_usage INT
)
BEGIN
    -- Result Set 1: Chi tiết (Có thể bỏ nếu chỉ cần thống kê)
    SELECT 
        uv.CustomerID,
        u.FullName, -- Nên join lấy thêm tên cho dễ nhìn
        v.PromotionName,
        uv.UsedDate
    FROM UseVoucher uv
    JOIN Voucher v ON uv.VoucherID = v.VoucherID
    JOIN `User` u ON uv.CustomerID = u.UserID -- Join vào bảng Customer gốc (User) nếu cần Name
    WHERE uv.UsedDate >= p_start_date AND uv.UsedDate <= p_end_date -- Dùng so sánh tường minh thay vì BETWEEN đôi khi tốt hơn cho index
    ORDER BY uv.UsedDate DESC;

    -- Result Set 2: Thống kê (Quan trọng)
    SELECT 
        u.UserID,
        u.FullName, -- Nếu cần
        COUNT(uv.VoucherID) AS TotalUsed,
        MAX(uv.UsedDate) AS LastUsedDate
    FROM UseVoucher uv
    JOIN `User` u ON uv.CustomerID = u.UserID
    WHERE uv.UsedDate BETWEEN p_start_date AND p_end_date
    GROUP BY u.UserID
    HAVING COUNT(uv.VoucherID) >= p_min_usage
    ORDER BY TotalUsed DESC;
END //

DELIMITER ;



-- ============================================================
-- PHẦN 1: CHUẨN BỊ DỮ LIỆU (SETUP DATA)
-- ============================================================

-- 1. Tạo Customer mẫu
-- INSERT INTO User (UserID, FullName, Email) VALUES (901, 'Tester 1', 't1@test.com') ON DUPLICATE KEY UPDATE FullName='Tester 1';
-- INSERT INTO Customer (CustomerID, Type) VALUES (901, 'VIP') ON DUPLICATE KEY UPDATE Type='VIP';

-- INSERT INTO User (UserID, FullName, Email) VALUES (902, 'Tester 2', 't2@test.com') ON DUPLICATE KEY UPDATE FullName='Tester 2';
-- INSERT INTO Customer (CustomerID, Type) VALUES (902, 'Regular') ON DUPLICATE KEY UPDATE Type='Regular';

-- -- 2. Tạo các loại Voucher khác nhau
-- -- Voucher A: Bình thường (Số lượng 10)
-- INSERT INTO Voucher (VoucherID, PromotionName, TotalQuantity, UsageCount, RemainingQuantity, Status, ExpiresAt)
-- VALUES (100, 'Voucher Normal', 10, 0, 10, 'Active', DATE_ADD(NOW(), INTERVAL 30 DAY))
-- ON DUPLICATE KEY UPDATE TotalQuantity=10, UsageCount=0;

-- -- Voucher B: Sắp hết (Số lượng chỉ có 1) -> Để test Overuse
-- INSERT INTO Voucher (VoucherID, PromotionName, TotalQuantity, UsageCount, RemainingQuantity, Status, ExpiresAt)
-- VALUES (200, 'Voucher Low Stock', 1, 0, 1, 'Active', DATE_ADD(NOW(), INTERVAL 30 DAY))
-- ON DUPLICATE KEY UPDATE TotalQuantity=1, UsageCount=0;

-- -- Voucher C: Đã hết hạn -> Để test chặn Hủy
-- INSERT INTO Voucher (VoucherID, PromotionName, TotalQuantity, UsageCount, RemainingQuantity, Status, ExpiresAt)
-- VALUES (300, 'Voucher Expired', 10, 5, 5, 'Active', DATE_SUB(NOW(), INTERVAL 1 DAY))
-- ON DUPLICATE KEY UPDATE ExpiresAt = DATE_SUB(NOW(), INTERVAL 1 DAY);

-- -- Voucher D: Đã bị khóa -> Để test chặn Hủy
-- INSERT INTO Voucher (VoucherID, PromotionName, TotalQuantity, UsageCount, RemainingQuantity, Status, ExpiresAt)
-- VALUES (400, 'Voucher Banned', 10, 2, 8, 'Banned', DATE_ADD(NOW(), INTERVAL 30 DAY))
-- ON DUPLICATE KEY UPDATE Status = 'Banned';

-- -- Xóa sạch bảng UseVoucher của các user test trước khi chạy
-- DELETE FROM UseVoucher WHERE CustomerID IN (901, 902);

-- -- ============================================================
-- -- PHẦN 2: HAPPY PATH (CÁC TRƯỜNG HỢP THÀNH CÔNG)
-- -- ============================================================

-- -- TEST 1: User 901 Dùng Voucher 100 (Bình thường)
-- -- Kỳ vọng: Thành công. Voucher 100: UsageCount = 1, Remaining = 9
-- CALL sp_UseVoucher(901, 100);

-- -- TEST 2: User 901 Hủy dùng Voucher 100 (Vừa mua ở trên)
-- -- Kỳ vọng: Thành công. Voucher 100: UsageCount quay về 0, Remaining quay về 10
-- CALL sp_CancelVoucherUsage(901, 100, NULL);

-- -- TEST 3: User 901 Mua chiếc cuối cùng của Voucher 200 (Low Stock)
-- -- Kỳ vọng: Thành công. Voucher 200: UsageCount = 1, Remaining = 0
-- CALL sp_UseVoucher(901, 200);

-- SELECT '--- CHECK POINT 1 (Sau Happy Path) ---' AS Msg;
-- SELECT VoucherID, TotalQuantity, UsageCount, RemainingQuantity FROM Voucher WHERE VoucherID IN (100, 200);

-- -- ============================================================
-- -- PHẦN 3: NEGATIVE TEST (CÁC TRƯỜNG HỢP CỐ TÌNH SAI)
-- -- ============================================================

-- -- TEST 4: Overuse (Mua quá số lượng)
-- -- Hiện tại Voucher 200 có Remaining = 0 (do Test 3 đã mua).
-- -- User 902 cố mua tiếp Voucher 200.
-- -- KỲ VỌNG: Lỗi "Lỗi: Voucher đã hết số lượng sử dụng (Overuse prevented)."
-- -- (Nếu chạy trong tool quản lý DB, bạn sẽ thấy báo lỗi đỏ)
-- CALL sp_UseVoucher(902, 200); 

-- -- TEST 5: Hủy khống (Xóa cái chưa từng dùng)
-- -- User 902 chưa từng dùng Voucher 100, nhưng cố tình gọi lệnh hủy.
-- -- KỲ VỌNG: Lỗi "Lỗi: Không tìm thấy lịch sử sử dụng Voucher này của khách hàng."
-- CALL sp_CancelVoucherUsage(902, 100, NULL);

-- -- TEST 6: Hủy Voucher đã hết hạn (Business Logic)
-- -- Setup: Giả sử User 901 đã dùng Voucher 300 từ quá khứ (Insert thủ công để bypass logic insert)
-- INSERT INTO UseVoucher (CustomerID, VoucherID, UsedDate) VALUES (901, 300, NOW());
-- -- Voucher 300 đã được set ExpiresAt là ngày hôm qua.
-- -- User 901 cố gắng hủy.
-- -- KỲ VỌNG: Lỗi "Không thể hủy lượt sử dụng vì Voucher đã hết hạn."
-- CALL sp_CancelVoucherUsage(901, 300, NULL);

-- -- TEST 7: Hủy Voucher bị Khóa (Banned)
-- -- Setup: Insert thủ công User 901 dùng Voucher 400
-- INSERT INTO UseVoucher (CustomerID, VoucherID, UsedDate) VALUES (901, 400, NOW());
-- -- Voucher 400 có Status = 'Banned'.
-- -- User 901 cố gắng hủy.
-- -- KỲ VỌNG: Lỗi "Voucher này đã bị khóa, không thể thay đổi lịch sử."
-- CALL sp_CancelVoucherUsage(901, 400, NULL);

-- -- ============================================================
-- -- PHẦN 4: KIỂM TRA KẾT QUẢ CUỐI CÙNG
-- -- ============================================================

-- SELECT '--- FINAL RESULT ---' AS Status;

-- -- Kiểm tra bảng Voucher xem số liệu có đúng không
-- SELECT 
--     VoucherID, 
--     PromotionName, 
--     TotalQuantity, 
--     UsageCount, 
--     RemainingQuantity, -- Cột này quan trọng nhất
--     Status 
-- FROM Voucher 
-- WHERE VoucherID IN (100, 200, 300, 400);

-- -- Kiểm tra bảng UseVoucher xem còn lại những ai
-- SELECT * FROM UseVoucher WHERE CustomerID IN (901, 902);

-- CALL sp_ReportVoucherUsage('2025-11-10', '2025-12-31', 3);
