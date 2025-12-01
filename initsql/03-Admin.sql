-- admin
-- procedure update status don hang 
DROP PROCEDURE IF EXISTS sp_AdminUpdateOrderStatus;
DELIMITER //
CREATE PROCEDURE sp_AdminUpdateOrderStatus (
    IN p_OrderID INT,
    IN p_NewStatus VARCHAR(50)
)
BEGIN
    DECLARE v_CurrentStatus VARCHAR(50);
    SELECT Status INTO v_CurrentStatus FROM `Order` WHERE OrderID = p_OrderID;
    -- Kiem tra OrderID ton tai
    IF v_CurrentStatus IS NULL THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Loi: Khong tim thay don hang (OrderID).';
    -- Khong cho chuyen tu Completed sang cac trang thai truoc (tru Canceled)
    ELSEIF v_CurrentStatus = 'Completed' AND p_NewStatus <> 'Completed' AND p_NewStatus <> 'Canceled' THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Loi: Khong the chuyen trang thai tu Completed sang Pending.';
    ELSE
        -- Thuc hien update
        UPDATE `Order` SET Status = p_NewStatus WHERE OrderID = p_OrderID;
        SELECT CONCAT('Da cap nhat OrderID ', p_OrderID, ' tu [', v_CurrentStatus, '] sang [', p_NewStatus, '].') AS Notice;
    END IF;
END //
DELIMITER ;

-- procedure update status product
DROP PROCEDURE IF EXISTS sp_AdminUpdateProductStatus;
DELIMITER //
CREATE PROCEDURE sp_AdminUpdateProductStatus (
    IN p_ProductID INT,
    IN p_NewStatus VARCHAR(50) -- Trang thai moi (Active,Rejected,Approved)
)
BEGIN
    -- Kiem tra ProductID co ton tai khong
    IF (SELECT ProductID FROM Product WHERE ProductID = p_ProductID) IS NULL THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Loi: Khong tim thay san pham (ProductID).';
    ELSE
        -- Thuc hien cap nhat Status cua san pham
        UPDATE Product SET Status = p_NewStatus WHERE ProductID = p_ProductID;
        -- Thong bao cap nhat thanh cong
        SELECT CONCAT('Da cap nhat Status cua ProductID ', p_ProductID, ' thanh [', p_NewStatus, '].') AS Notice;
    END IF;
END //
DELIMITER ;

-- PROCEDURE ADMIN: TOP SELLING PRODUCTS ***
DROP PROCEDURE IF EXISTS sp_GetTopSellingProducts;
DELIMITER //
-- Procedure lấy danh sach san pham ban chay nhat
CREATE PROCEDURE sp_GetTopSellingProducts (
    IN p_Limit INT -- Tham so gioi han so luong
)
BEGIN
    SELECT 
        T1.ProductID,
        T2.Name, -- Ten san pham
        SUM(T1.Quantity) AS TotalQuantitySold -- Tinh tong so luong ban
    FROM PackageItem AS T1 -- Bang chua so luong ban
    JOIN Product AS T2 ON T1.ProductID = T2.ProductID
    GROUP BY T1.ProductID, T2.Name
    ORDER BY TotalQuantitySold DESC
    LIMIT p_Limit;
END //
DELIMITER ;