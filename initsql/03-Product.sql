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
