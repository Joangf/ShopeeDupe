DELIMITER //

CREATE PROCEDURE sp_DeleteProduct (
    IN p_ProductID INT -- Tham so dau vao: Ma san pham can xu ly
)
BEGIN
    -- Khai bao bien dem so luong don hang/review lien quan
    DECLARE v_OrderCount INT DEFAULT 0; 
    DECLARE v_ReviewCount INT DEFAULT 0;
    -- Khai bao bien luu trang thai hien tai cua san pham
    DECLARE v_CurrentStatus VARCHAR(50);
    -- Lay trang thai hien tai cua san pham de kiem tra ton tai
    SELECT Status INTO v_CurrentStatus FROM Product WHERE ProductID = p_ProductID;
    -- KIEM TRA VALIDATION: Neu San pham khong ton tai (v_CurrentStatus IS NULL)
    IF v_CurrentStatus IS NULL THEN
        -- Xuat tin hieu bao loi cu the cho ung dung
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Loi nhap lieu: Khong tim thay San pham (ProductID) voi ma da cung cap.';
        
    ELSE 
        -- Neu san pham TON TAI, tiep tuc kiem tra rang buoc nghiep vu
        -- Dem so luong dong trong PackageItem (Lich su don hang)
        SELECT COUNT(*) INTO v_OrderCount FROM PackageItem WHERE ProductID = p_ProductID; 
        -- Dem so luong dong trong Review (Lich su danh gia)
        SELECT COUNT(*) INTO v_ReviewCount FROM Review WHERE ProductID = p_ProductID;

        -- KIEM TRA LOGIC XOA: Neu co bat ky lich su nao lien quan
        IF v_OrderCount > 0 OR v_ReviewCount > 0 THEN
            -- TH 1: SOFT DELETE (Xoa Mem)
            UPDATE Product
            SET Status = 'Bi an'
            WHERE ProductID = p_ProductID;
            
            -- Thong bao nghiep vu Soft Delete thanh cong
            SELECT CONCAT('San pham ID ', p_ProductID, ' da duoc chuyen sang trang thai "Bi an" do co lich su don hang hoac danh gia lien quan.') AS Notice;
            
        ELSE
            -- TH2: DELETE VAT LY (Xoa Cung)
            -- Neu KHONG co rang buoc, tien hanh xoa
            DELETE FROM Product
            WHERE ProductID = p_ProductID;
            -- Thong bao thanh cong Delete vat ly
            SELECT CONCAT('San pham ID ', p_ProductID, ' da duoc XOA vat ly thanh cong.') AS Success;
        END IF;
        
    END IF;
    
END //

DELIMITER ;


DELIMITER //

-- Thủ tục thêm một sản phẩm mới
CREATE PROCEDURE sp_AddNewProduct (
    IN p_SellerID INT,  -- Mã nguời bán khi gọi hàm này ở backend
    IN p_Name NVARCHAR(255), -- Tên sản phẩm
    IN p_Barcode VARCHAR(100), -- Mã vạch sản phẩm (chỉ được chứa số)
    IN p_BrandName NVARCHAR(100), -- Tên thương hiệu
    IN p_Description TEXT,  -- Mô tả sản phẩm
    IN p_Price INT, -- Giá sản phẩm (không được giá âm)
    IN p_StockQuantity INT,  -- (Số lượng tồn kho (không được âm hay không có gì))
    IN p_ImageURL VARCHAR(255) -- URL hình ảnh sản phẩm
)
BEGIN
    INSERT INTO Product (SellerID, Name, Barcode, BrandName, Description, Price, StockQuantity, ImageURL)
    VALUES (p_SellerID, p_Name, p_Barcode, p_BrandName, p_Description, p_Price, p_StockQuantity, p_ImageURL);

    SELECT LAST_INSERT_ID() AS ProductID;
END //
DELIMITER //


DELIMITER //

CREATE TRIGGER trg_Product_BeforeInsert
BEFORE INSERT ON Product
FOR EACH ROW
BEGIN
    -- Kiểm tra giá không âm
    IF NEW.Price < 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Price cannot be negative';
    END IF;

    -- Kiểm tra stock > 0
    IF NEW.StockQuantity <= 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'StockQuantity must be greater than 0';
    END IF;

    -- Kiểm tra barcode chỉ chứa số (NULL thì bỏ qua)
    IF NEW.Barcode IS NOT NULL AND NEW.Barcode REGEXP '[^0-9]' THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Barcode must contain only digits';
    END IF;
END;
//

DELIMITER ;


DELIMITER //
-- Thủ tục thêm một PackageItem mới
CREATE PROCEDURE sp_AddPackageItem (
    IN p_ProductID INT, -- Mã sản phẩm (đảm bảo dãng tồn tại trong bảng Product)
    IN p_PackageID INT, -- Mã gói sản phẩm (đảm bảo đã tồn tại trong bảng Package)
    IN p_PackageItemID INT, -- Mã chi tiết gói sản phẩm (tự chọn cách tạo ID này, miễn sao không trùng cho cùng một ProductID)
    IN p_Quantity INT -- Số lượng sản phẩm trong gói (phải > 0)
)
BEGIN

    -- Thêm PackageItem mới 
    INSERT INTO PackageItem (ProductID, PackageID, PackageItemID, Quantity)
    VALUES (p_ProductID, p_PackageID, p_PackageItemID, p_Quantity);
END;
//
DELIMITER ;

DELIMITER //
-- Trigger kiểm tra dữ liệu khi insert vào PackageItem
CREATE TRIGGER trg_PackageItem_BeforeInsert
BEFORE INSERT ON PackageItem
FOR EACH ROW
BEGIN
    -- Kiểm tra số lượng phải > 0
    IF NEW.Quantity <= 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Quantity pf Sold Product must be greater than 0';
    END IF;
END;
//

DELIMITER ;

