-- Các trigger để tính thuộc tính dẫn xuất "Số lượng còn lại" của Voucher
-- 1. BEFORE INSERT trên Voucher: khởi tạo RemainingQuantity theo giá trị vừa chèn
DELIMITER $$
CREATE TRIGGER trg_voucher_before_insert
BEFORE INSERT ON Voucher
FOR EACH ROW
BEGIN
    IF NEW.UsageCount IS NULL THEN
        SET NEW.UsageCount = 0;
    END IF;
    IF NEW.TotalQuantity IS NULL THEN
        SET NEW.TotalQuantity = 0;
    END IF;
    SET NEW.RemainingQuantity = NEW.TotalQuantity - NEW.UsageCount;
END$$
DELIMITER ;

-- 2. BEFORE UPDATE trên Voucher: tái tính RemainingQuantity khi TotalQuantity hoặc UsageCount thay đổi
DELIMITER $$
CREATE TRIGGER trg_voucher_before_update
BEFORE UPDATE ON Voucher
FOR EACH ROW
BEGIN
    -- đảm bảo không để Remaining bị NULL
    IF NEW.UsageCount IS NULL THEN
        SET NEW.UsageCount = 0;
    END IF;
    IF NEW.TotalQuantity IS NULL THEN
        SET NEW.TotalQuantity = 0;
    END IF;
    SET NEW.RemainingQuantity = NEW.TotalQuantity - NEW.UsageCount;
END$$
DELIMITER ;


-- (A) BEFORE INSERT: kiểm tra tồn kho voucher (ngăn overuse) và báo lỗi có ý nghĩa
DELIMITER $$
CREATE TRIGGER trg_usevoucher_before_insert
BEFORE INSERT ON UseVoucher
FOR EACH ROW
BEGIN
    DECLARE remain INT;
    SELECT TotalQuantity - UsageCount INTO remain
    FROM Voucher
    WHERE VoucherID = NEW.VoucherID
    FOR UPDATE; -- chú ý: FOR UPDATE trong trigger yêu cầu transaction context, nếu không được phép thì bỏ FOR UPDATE

    IF remain IS NULL THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Voucher không tồn tại';
    END IF;

    IF remain <= 0 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Voucher đã hết lượt sử dụng';
    END IF;
END$$
DELIMITER ;

-- (B) AFTER INSERT: cập nhật UsageCount và RemainingQuantity (atomic update)
DELIMITER $$
CREATE TRIGGER trg_usevoucher_after_insert
AFTER INSERT ON UseVoucher
FOR EACH ROW
BEGIN
    -- cập nhật atomically; dùng expression dựa trên CURRENT value
    UPDATE Voucher
    SET 
        UsageCount = UsageCount + 1,
        RemainingQuantity = TotalQuantity - (UsageCount + 1)
    WHERE VoucherID = NEW.VoucherID;
END$$
DELIMITER ;

-- (C) BEFORE DELETE: kiểm tra và cập nhật trước khi xóa
DELIMITER $$
CREATE TRIGGER trg_usevoucher_before_delete
BEFORE DELETE ON UseVoucher
FOR EACH ROW
BEGIN
    DECLARE used INT;
    SELECT UsageCount INTO used FROM Voucher WHERE VoucherID = OLD.VoucherID;
    IF used IS NULL THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Voucher không tồn tại';
    END IF;
    IF used <= 0 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Không thể hoàn voucher khi chưa có lượt sử dụng!';
    END IF;
    -- NOTE: ta chỉ kiểm tra ở đây, thực hiện cập nhật ở AFTER DELETE để tránh sửa Voucher nếu DELETE sau đó rollback
END$$
DELIMITER ;

-- (D) AFTER DELETE: giảm UsageCount và tăng RemainingQuantity
DELIMITER $$
CREATE TRIGGER trg_usevoucher_after_delete
AFTER DELETE ON UseVoucher
FOR EACH ROW
BEGIN
    UPDATE Voucher
    SET 
        UsageCount = GREATEST(UsageCount - 1, 0),
        RemainingQuantity = TotalQuantity - GREATEST(UsageCount - 1, 0)
    WHERE VoucherID = OLD.VoucherID;
END$$
DELIMITER ;

DELIMITER //


-- List CustomerID 
-- Số lượng voucher đã dùng (>= p_min_usage) trong thời gian (p_start_date <= date <= p_end_date)
-- Ngày cuối cùng sử dụng Voucher
CREATE PROCEDURE sp_ReportVoucherUsage(
    IN p_start_date DATE,        -- tham số dùng cho WHERE
    IN p_end_date DATE,          -- tham số dùng cho WHERE
    IN p_min_usage INT           -- tham số dùng cho HAVING
)
BEGIN
    -- 1️. Câu truy vấn cơ bản: từ 2 bảng trở lên, có WHERE, ORDER BY
    SELECT 
        c.CustomerID,
        v.VoucherID,
        uv.UsedDate
    FROM UseVoucher uv
    JOIN Voucher v ON uv.VoucherID = v.VoucherID
    JOIN Customer c ON uv.CustomerID = c.CustomerID
    WHERE uv.UsedDate BETWEEN p_start_date AND p_end_date
    ORDER BY uv.UsedDate DESC;

    -- 2️. Câu truy vấn tổng hợp: có Aggregate, Group By, Having, Where, Order By
    SELECT 
        c.CustomerID,
        COUNT(uv.VoucherID) AS TotalUsed,
        MAX(uv.UsedDate) AS LastUsedDate
    FROM UseVoucher uv
    JOIN Customer c ON uv.CustomerID = c.CustomerID
    WHERE uv.UsedDate BETWEEN p_start_date AND p_end_date
    GROUP BY c.CustomerID
    HAVING COUNT(uv.VoucherID) >= p_min_usage
    ORDER BY TotalUsed DESC;
END //

DELIMITER ;


-- CALL sp_ReportVoucherUsage('2025-11-10', '2025-12-31', 3);