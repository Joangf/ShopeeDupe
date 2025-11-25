DELIMITER //
-- --------------------------------------------------------------------------------
-- Ham 1: TINH TONG CHI TIEU KHACH HANG (DUNG CON TRO & LOOP)
-- --------------------------------------------------------------------------------
CREATE FUNCTION func_CalculateCustomerSpending (
    p_CustomerID INT,
    p_TargetYear INT
)
RETURNS DECIMAL(10, 2) READS SQL DATA
BEGIN
    -- Khai bao bien luu tong tien
    DECLARE v_TotalAmount DECIMAL(10, 2) DEFAULT 0.00;
    -- Khai bao bien luu gia tri tung don hang
    DECLARE v_OrderAmount DECIMAL(10, 2);
    -- Bien co chi trang thai con tro
    DECLARE v_Finished INT DEFAULT 0;
    -- Khai bao Con tro (CURSOR) de lay gia tri TotalAmount cua cac don hang
    DECLARE cur_orders CURSOR FOR 
        SELECT TotalAmount FROM `Order` 
        -- Loc theo CustomerID, TargetYear, va Status la 'Completed'
        WHERE CustomerID = p_CustomerID AND YEAR(OrderDate) = p_TargetYear AND Status = 'Completed'; 
    -- Khai bao CONTINUE HANDLER: Xu ly khi con tro khong tim thay du lieu
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET v_Finished = 1;

    -- KIEM TRA INPUT VALIDATION: Kiem tra CustomerID ton tai
    IF (SELECT COUNT(*) FROM Customer WHERE CustomerID = p_CustomerID) = 0 THEN
        RETURN -1.00; -- Tra ve gia tri loi neu ID khong hop le
    END IF;
    -- Mo con tro
    OPEN cur_orders;
    -- VONG LAP (LOOP): Bat dau duyet qua cac don hang
    order_loop: LOOP
        -- Lay du lieu tu con tro vao bien v_OrderAmount
        FETCH cur_orders INTO v_OrderAmount;
        -- IF: Dieu kien thoat vong lap
        IF v_Finished = 1 THEN
            LEAVE order_loop; -- Thoat vong lap khi het don hang
        END IF;
        -- Tinh tong (Calculation)
        SET v_TotalAmount = v_TotalAmount + v_OrderAmount;
    END LOOP;
    -- Dong con tro
    CLOSE cur_orders;
    RETURN v_TotalAmount;
END //
DELIMITER ;

-- --------------------------------------------------------------------------------
-- Ham 2: PHAN LOAI HANG KHACH HANG (DUNG IF/ELSE IF & GOI HAM 1)
-- --------------------------------------------------------------------------------
DELIMITER //
CREATE FUNCTION func_GetCustomerTier (
    p_CustomerID INT,
    p_TargetYear INT
)
RETURNS VARCHAR(50) READS SQL DATA
BEGIN
    DECLARE v_Spending DECIMAL(10, 2);
    DECLARE v_Tier VARCHAR(50) DEFAULT 'Standard';
    
    -- KIEM TRA INPUT VALIDATION: Kiem tra CustomerID ton tai
    IF (SELECT COUNT(*) FROM Customer WHERE CustomerID = p_CustomerID) = 0 THEN
        RETURN 'Invalid Customer ID';
    END IF;

    -- Goi Ham 1 de lay tong chi tieu (Chi tieu duoc tinh bang con tro)
    SET v_Spending = func_CalculateCustomerSpending(p_CustomerID, p_TargetYear);
    
    -- Logic IF/ELSE IF de phan loai hang
    IF v_Spending = -1.00 THEN
        RETURN 'Error Calculating Spending'; -- Xu ly truong hop Ham 1 bao loi
    ELSEIF v_Spending >= 5000000.00 THEN 
        SET v_Tier = 'Gold';
    ELSEIF v_Spending >= 1000000.00 THEN 
        SET v_Tier = 'Silver';
    ELSE
        SET v_Tier = 'Standard'; -- Truong hop con lai
    END IF;

    RETURN v_Tier;
END //
DELIMITER ;