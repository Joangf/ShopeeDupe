-- Tắt kiểm tra khóa ngoại tạm thời để insert dữ liệu dễ dàng hơn
SET FOREIGN_KEY_CHECKS = 0;

-- ==================================================================
-- 1. TẠO 50 USER (30 CUSTOMER, 15 SELLER, 5 ADMIN)
-- ==================================================================

-- --- NHÓM 1: 30 CUSTOMERS (ID 1 -> 30) ---
INSERT INTO `User` (UserID, FullName, Gender, DateOfBirth, NationalID, Email, PhoneNumber, Address, PasswordHash) VALUES
(1, 'Nguyen Van A', 'Male', '1995-01-10', '001095000001', 'cust1@email.com', '0901000001', '123 Le Loi, HCM', 'hash123'),
(2, 'Tran Thi B', 'Female', '1998-05-20', '001098000002', 'cust2@email.com', '0901000002', '456 Nguyen Hue, HCM', 'hash123'),
(3, 'Le Van C', 'Male', '2000-12-12', '001200000003', 'cust3@email.com', '0901000003', '789 Vo Van Kiet, HCM', 'hash123'),
(4, 'Pham Thi D', 'Female', '1992-03-15', '001092000004', 'cust4@email.com', '0901000004', 'Da Nang', 'hash123'),
(5, 'Hoang Van E', 'Male', '1990-07-07', '001090000005', 'cust5@email.com', '0901000005', 'Ha Noi', 'hash123'),
(6, 'Do Thi F', 'Female', '1996-08-08', '001096000006', 'cust6@email.com', '0901000006', 'Can Tho', 'hash123'),
(7, 'Ngo Van G', 'Male', '1993-11-20', '001093000007', 'cust7@email.com', '0901000007', 'Hai Phong', 'hash123'),
(8, 'Vu Thi H', 'Female', '1999-02-14', '001099000008', 'cust8@email.com', '0901000008', 'Hue', 'hash123'),
(9, 'Bui Van I', 'Male', '1985-09-09', '001085000009', 'cust9@email.com', '0901000009', 'Nha Trang', 'hash123'),
(10, 'Dang Thi K', 'Female', '2001-01-01', '001201000010', 'cust10@email.com', '0901000010', 'Vung Tau', 'hash123'),
-- (Insert thêm 20 customer nữa để đủ 30)
(11, 'Customer 11', 'Male', '1990-01-01', '001090000011', 'cust11@email.com', '0901000011', 'HCM', 'hash'),
(12, 'Customer 12', 'Female', '1991-01-01', '001091000012', 'cust12@email.com', '0901000012', 'HN', 'hash'),
(13, 'Customer 13', 'Male', '1992-01-01', '001092000013', 'cust13@email.com', '0901000013', 'DN', 'hash'),
(14, 'Customer 14', 'Female', '1993-01-01', '001093000014', 'cust14@email.com', '0901000014', 'CT', 'hash'),
(15, 'Customer 15', 'Male', '1994-01-01', '001094000015', 'cust15@email.com', '0901000015', 'VT', 'hash'),
(16, 'Customer 16', 'Female', '1995-01-01', '001095000016', 'cust16@email.com', '0901000016', 'HCM', 'hash'),
(17, 'Customer 17', 'Male', '1996-01-01', '001096000017', 'cust17@email.com', '0901000017', 'HN', 'hash'),
(18, 'Customer 18', 'Female', '1997-01-01', '001097000018', 'cust18@email.com', '0901000018', 'DN', 'hash'),
(19, 'Customer 19', 'Male', '1998-01-01', '001098000019', 'cust19@email.com', '0901000019', 'CT', 'hash'),
(20, 'Customer 20', 'Female', '1999-01-01', '001099000020', 'cust20@email.com', '0901000020', 'VT', 'hash'),
(21, 'Customer 21', 'Male', '2000-01-01', '001200000021', 'cust21@email.com', '0901000021', 'HCM', 'hash'),
(22, 'Customer 22', 'Female', '2001-01-01', '001201000022', 'cust22@email.com', '0901000022', 'HN', 'hash'),
(23, 'Customer 23', 'Male', '2002-01-01', '001202000023', 'cust23@email.com', '0901000023', 'DN', 'hash'),
(24, 'Customer 24', 'Female', '2003-01-01', '001203000024', 'cust24@email.com', '0901000024', 'CT', 'hash'),
(25, 'Customer 25', 'Male', '2004-01-01', '001204000025', 'cust25@email.com', '0901000025', 'VT', 'hash'),
(26, 'Customer 26', 'Female', '2005-01-01', '001205000026', 'cust26@email.com', '0901000026', 'HCM', 'hash'),
(27, 'Customer 27', 'Male', '1990-02-01', '001090000027', 'cust27@email.com', '0901000027', 'HN', 'hash'),
(28, 'Customer 28', 'Female', '1991-02-01', '001091000028', 'cust28@email.com', '0901000028', 'DN', 'hash'),
(29, 'Customer 29', 'Male', '1992-02-01', '001092000029', 'cust29@email.com', '0901000029', 'CT', 'hash'),
(30, 'Customer 30', 'Female', '1993-02-01', '001093000030', 'cust30@email.com', '0901000030', 'VT', 'hash');

-- Insert vào bảng Customer
INSERT INTO Customer (CustomerID, Type, Behaviour) 
SELECT UserID, 
       CASE WHEN UserID % 5 = 0 THEN 'VIP' 
            WHEN UserID % 3 = 0 THEN 'Loyal' 
            ELSE 'Regular' END,
       'Normal shopping behavior'
FROM `User` WHERE UserID BETWEEN 1 AND 30;


-- --- NHÓM 2: 15 SELLERS (ID 31 -> 45) ---
INSERT INTO `User` (UserID, FullName, Gender, NationalID, Email, PhoneNumber, Address, PasswordHash) VALUES
(31, 'Nguyen Van Seller', 'Male', '001080000031', 'seller1@email.com', '0902000001', 'District 1, HCM', 'hash'),
(32, 'Tran Thi Seller', 'Female', '001081000032', 'seller2@email.com', '0902000002', 'District 3, HCM', 'hash'),
(33, 'Le Van Seller', 'Male', '001082000033', 'seller3@email.com', '0902000003', 'Cau Giay, HN', 'hash'),
(34, 'Shop Owner 4', 'Female', '001083000034', 'seller4@email.com', '0902000004', 'Da Nang', 'hash'),
(35, 'Tech Boss', 'Male', '001084000035', 'seller5@email.com', '0902000005', 'Can Tho', 'hash'),
(36, 'Fashion Lady', 'Female', '001085000036', 'seller6@email.com', '0902000006', 'HCM', 'hash'),
(37, 'Book Worm', 'Male', '001086000037', 'seller7@email.com', '0902000007', 'HN', 'hash'),
(38, 'Food Master', 'Female', '001087000038', 'seller8@email.com', '0902000008', 'Hue', 'hash'),
(39, 'Auto Part Seller', 'Male', '001088000039', 'seller9@email.com', '0902000009', 'Nha Trang', 'hash'),
(40, 'Cosmetic Queen', 'Female', '001089000040', 'seller10@email.com', '0902000010', 'HCM', 'hash'),
(41, 'Seller 11', 'Male', '001090000041', 'seller11@email.com', '0902000011', 'HN', 'hash'),
(42, 'Seller 12', 'Female', '001091000042', 'seller12@email.com', '0902000012', 'DN', 'hash'),
(43, 'Seller 13', 'Male', '001092000043', 'seller13@email.com', '0902000013', 'CT', 'hash'),
(44, 'Seller 14', 'Female', '001093000044', 'seller14@email.com', '0902000014', 'VT', 'hash'),
(45, 'Seller 15', 'Male', '001094000045', 'seller15@email.com', '0902000015', 'HCM', 'hash');

-- Insert vào bảng Seller
INSERT INTO Seller (SellerID, Type, BusinessAddress, BusinessName) VALUES
(31, 'Business', '123 Tech Street', 'TechZone'),
(32, 'Personal', '456 Fashion Ave', 'Bella Boutique'),
(33, 'Business', '789 Book Rd', 'Knowledge House'),
(34, 'Personal', 'Home Address', 'Handmade by Lan'),
(35, 'Business', 'Cyber Center', 'PC Master'),
(36, 'Business', 'Mall L3', 'Zara Fake'),
(37, 'Personal', 'Old Quarter', 'Antique Books'),
(38, 'Business', 'Food Court', 'Yummy Kitchen'),
(39, 'Business', 'Garage 1', 'Speedy Auto'),
(40, 'Personal', 'Home Spa', 'Natural Beauty'),
(41, 'Business', 'Biz Tower', 'Import Export Co'),
(42, 'Personal', 'Market', 'Local Goods'),
(43, 'Business', 'Mekong Zone', 'Fruit Fresh'),
(44, 'Personal', 'Sea Side', 'Sea Food'),
(45, 'Business', 'High Tech Park', 'Smart Home VN');


-- --- NHÓM 3: 5 ADMINS (ID 46 -> 50) ---
INSERT INTO `User` (UserID, FullName, Gender, NationalID, Email, PhoneNumber, Address, PasswordHash) VALUES
(46, 'Super Admin', 'Male', '001070000046', 'admin1@sys.com', '0909000001', 'HQ', 'hash_admin'),
(47, 'Manager One', 'Female', '001071000047', 'admin2@sys.com', '0909000002', 'HQ', 'hash_admin'),
(48, 'Support Lead', 'Male', '001072000048', 'admin3@sys.com', '0909000003', 'Branch A', 'hash_admin'),
(49, 'Content Mod', 'Female', '001073000049', 'admin4@sys.com', '0909000004', 'Remote', 'hash_admin'),
(50, 'System Op', 'Male', '001074000050', 'admin5@sys.com', '0909000005', 'Server Room', 'hash_admin');

-- Insert vào bảng Admin
INSERT INTO Admin (AdminID, Role, InternalNotes) VALUES
(46, 'SuperAdmin', 'Full Access'),
(47, 'Manager', 'Manage Sellers'),
(48, 'Support', 'Handle Complaints'),
(49, 'Moderator', 'Review Content'),
(50, 'Operator', 'Monitor System');


-- ==================================================================
-- 2. TẠO 30 VOUCHER
-- Logic: Voucher 1-20 do Seller tạo, Voucher 21-30 do Admin tạo
-- ==================================================================

-- Voucher do Seller (ID 31-40) tạo
INSERT INTO Voucher (VoucherID, SellerID, AdminID, PromotionName, TotalQuantity, RemainingQuantity, UsageCount, DiscountValue, ExpiresAt, Description) VALUES
(1, 31, NULL, 'TECH50K', 100, 100, 0, 50000, '2025-12-31', 'Giam 50k cho do dien tu'),
(2, 31, NULL, 'TECH100K', 50, 45, 5, 100000, '2025-12-31', 'Giam 100k mua laptop'),
(3, 32, NULL, 'FASHION10', 200, 150, 50, 20000, '2025-11-30', 'Giam 20k cho quan ao'),
(4, 32, NULL, 'SUMMERSALE', 100, 100, 0, 30000, '2025-06-30', 'Sale mua he'),
(5, 33, NULL, 'BOOKLOVER', 100, 90, 10, 15000, '2025-12-31', 'Giam cho sach'),
(6, 33, NULL, 'READMORE', 50, 50, 0, 25000, '2025-12-31', 'Khuyen khich doc sach'),
(7, 34, NULL, 'HANDMADE5', 20, 20, 0, 10000, '2025-10-20', 'Do thu cong'),
(8, 35, NULL, 'PCBUILD', 10, 8, 2, 500000, '2025-12-31', 'Giam khi build PC'),
(9, 36, NULL, 'ZARA20', 100, 80, 20, 50000, '2025-12-31', 'Giam 50k'),
(10, 37, NULL, 'OLD10', 50, 50, 0, 10000, '2025-12-31', 'Sach cu'),
(11, 38, NULL, 'YUMMY', 500, 400, 100, 5000, '2025-12-31', 'Food voucher'),
(12, 39, NULL, 'AUTOFIX', 20, 20, 0, 100000, '2025-12-31', 'Sua xe'),
(13, 40, NULL, 'BEAUTY', 100, 95, 5, 20000, '2025-03-08', 'Ngay 8/3'),
(14, 41, NULL, 'IMPORT', 50, 50, 0, 200000, '2025-12-31', 'Hang nhap khau'),
(15, 42, NULL, 'LOCAL', 100, 100, 0, 5000, '2025-12-31', 'Hang noi dia'),
(16, 43, NULL, 'FRUIT', 200, 190, 10, 10000, '2025-12-31', 'Trai cay tuoi'),
(17, 44, NULL, 'SEAFOOD', 50, 48, 2, 30000, '2025-12-31', 'Hai san'),
(18, 45, NULL, 'SMART', 30, 30, 0, 150000, '2025-12-31', 'Nha thong minh'),
(19, 31, NULL, 'MOUSE', 100, 100, 0, 20000, '2025-12-31', 'Mua chuot'),
(20, 32, NULL, 'JEANS', 100, 90, 10, 25000, '2025-12-31', 'Mua quan Jeans');

-- Voucher do Admin (ID 46-48) tạo (Voucher sàn)
INSERT INTO Voucher (VoucherID, SellerID, AdminID, PromotionName, TotalQuantity, RemainingQuantity, UsageCount, DiscountValue, ExpiresAt, Description) VALUES
(21, NULL, 46, 'FREESHIP', 1000, 500, 500, 15000, '2025-12-31', 'Mien phi van chuyen'),
(22, NULL, 46, 'WELCOME', 1000, 900, 100, 20000, '2026-01-01', 'Chao mung thanh vien moi'),
(23, NULL, 47, 'BLACKFRIDAY', 500, 500, 0, 50000, '2025-11-28', 'Sieu sale thu 6 den'),
(24, NULL, 47, 'FLASH11', 200, 0, 200, 30000, '2025-11-11', 'Sale 11.11 da het han'),
(25, NULL, 48, 'PAYDAY', 300, 300, 0, 25000, '2025-12-31', 'Sale luong ve'),
(26, NULL, 46, 'TET2026', 1000, 1000, 0, 100000, '2026-02-15', 'Li xi Tet'),
(27, NULL, 47, 'MALLDAY', 500, 450, 50, 40000, '2025-12-31', 'Giam cho Shop Mall'),
(28, NULL, 46, 'SUPERVIP', 100, 100, 0, 200000, '2025-12-31', 'Danh cho VIP'),
(29, NULL, 47, 'WEEKEND', 500, 400, 100, 10000, '2025-12-31', 'Cuoi tuan vui ve'),
(30, NULL, 48, 'SORRY', 50, 40, 10, 20000, '2025-12-31', 'Voucher den bu');


-- ==================================================================
-- 3. TẠO 50 PRODUCT
-- Logic: Liên kết với Seller (ID 31-45)
-- Một số sản phẩm sẽ gắn Voucher (ID 1-20 của Seller)
-- ==================================================================

INSERT INTO Product (Name, SellerID, VoucherID, Barcode, BrandName, Price, StockQuantity, Description) VALUES
('iPhone 15', 31, 1, 'P001', 'Apple', 20000000, 50, 'Dien thoai cao cap'),
('Samsung S24', 31, 1, 'P002', 'Samsung', 18000000, 40, 'Android tot nhat'),
('Macbook Air M2', 31, 2, 'P003', 'Apple', 25000000, 20, 'Laptop mong nhe'),
('Dell XPS 13', 35, 8, 'P004', 'Dell', 24000000, 15, 'Laptop doanh nhan'),
('Ao Thun Basic', 32, 3, 'P005', 'Uniqlo', 200000, 200, 'Chat lieu cotton'),
('Quan Jeans Nam', 32, 20, 'P006', 'Levis', 500000, 100, 'Jean xanh co dien'),
('Vay Da Hoi', 32, NULL, 'P007', 'Zara', 1200000, 30, 'Sang trong'),
('Harry Potter Set', 33, 5, 'P008', 'NXB Tre', 1500000, 50, 'Tron bo 7 cuon'),
('Dac Nhan Tam', 33, 6, 'P009', 'First News', 100000, 100, 'Sach ky nang'),
('Gia Kim Thuat', 33, NULL, 'P010', 'Nha Nam', 80000, 120, 'Tieu thuyet'),
('Tui Xach Handmade', 34, 7, 'P011', 'Handmade', 500000, 10, 'Lam thu cong'),
('Vong Tay Go', 34, NULL, 'P012', 'Handmade', 50000, 50, 'Go tram huong'),
('PC Gaming i9', 35, 8, 'P013', 'Custom', 50000000, 5, 'Cau hinh khung'),
('Man Hinh LG', 35, NULL, 'P014', 'LG', 5000000, 20, '27 inch 4K'),
('Ao So Mi Trang', 36, 9, 'P015', 'Zara', 400000, 80, 'Lich lam'),
('Sach Co 1900', 37, 10, 'P016', 'Unknown', 2000000, 1, 'Sach suu tam'),
('Com Tam Suon', 38, 11, 'P017', 'Bep Me', 50000, 100, 'Ngon re'),
('Bun Bo Hue', 38, 11, 'P018', 'Bep Me', 60000, 100, 'Dam da'),
('Nhot Castrol', 39, 12, 'P019', 'Castrol', 150000, 200, 'Dau nhot xe may'),
('Lop Xe Michelin', 39, NULL, 'P020', 'Michelin', 800000, 50, 'Lop xe cao cap'),
('Son Moi MAC', 40, 13, 'P021', 'MAC', 600000, 40, 'Mau do tuoi'),
('Kem Duong Da', 40, 13, 'P022', 'Innisfree', 300000, 60, 'Cap am'),
('Sua Rua Mat', 40, NULL, 'P023', 'Cerave', 350000, 50, 'Di u nhe'),
('Chocolate My', 41, 14, 'P024', 'Hershey', 100000, 200, 'Socola den'),
('Ruou Vang Phap', 41, 14, 'P025', 'Bordeaux', 1500000, 30, 'Vang do'),
('Non La', 42, 15, 'P026', 'Lang Nghe', 50000, 100, 'Truyen thong'),
('Ao Dai', 42, 15, 'P027', 'Thai Tuan', 800000, 20, 'Lua to tam'),
('Xoai Cat Hoa Loc', 43, 16, 'P028', 'Mien Tay', 60000, 500, 'Trai cay'),
('Sau Rieng Ri6', 43, 16, 'P029', 'Mien Tay', 150000, 100, 'Com vang hat lep'),
('Tom Hum Alaska', 44, 17, 'P030', 'Sea', 1200000, 10, 'Tuoi song'),
('Cua Ca Mau', 44, 17, 'P031', 'Ca Mau', 500000, 30, 'Chac thit'),
('Khoa Cua Thong Minh', 45, 18, 'P032', 'Xiaomi', 3000000, 20, 'Van tay'),
('Camera Wifi', 45, 18, 'P033', 'Ezviz', 800000, 50, 'Xoay 360'),
('Loa Bluetooth', 31, 1, 'P034', 'JBL', 2000000, 30, 'Bass manh'),
('Tai Nghe Sony', 31, NULL, 'P035', 'Sony', 5000000, 15, 'Chong on'),
('Ban Phim Co', 35, NULL, 'P036', 'Keychron', 2500000, 25, 'Red Switch'),
('Chuot Gaming', 35, 19, 'P037', 'Logitech', 1200000, 40, 'Khong day'),
('Vay Mua He', 32, 4, 'P038', 'H&M', 300000, 60, 'Hoa tiet hoa'),
('Quan Short', 32, 4, 'P039', 'Uniqlo', 250000, 80, 'Thoang mat'),
('Kinh Mat', 36, NULL, 'P040', 'Rayban', 3500000, 10, 'Chong UV'),
('Dong Ho Casio', 36, NULL, 'P041', 'Casio', 1000000, 50, 'Dien tu'),
('Nuoc Hoa Chanel', 40, 13, 'P042', 'Chanel', 4000000, 10, 'No.5'),
('Tay Trang Bioderma', 40, NULL, 'P043', 'Bioderma', 400000, 80, 'Cho da nhay cam'),
('Banh Pia', 42, 15, 'P044', 'Soc Trang', 80000, 100, 'Dau xanh sau rieng'),
('Cafe Trung Nguyen', 42, NULL, 'P045', 'G7', 50000, 200, 'Ca phe hoa tan'),
('Nho My', 41, 14, 'P046', 'USA', 200000, 50, 'Khong hat'),
('Tao Envy', 41, 14, 'P047', 'NZ', 180000, 60, 'Gion ngot'),
('Robot Hut Bui', 45, 18, 'P048', 'Roborock', 8000000, 10, 'Tu dong giat re'),
('Den Ban Hoc', 45, NULL, 'P049', 'Xiaomi', 500000, 40, 'Chong can'),
('O Cam Dien', 45, NULL, 'P050', 'Dien Quang', 100000, 100, 'An toan');

-- Bật lại kiểm tra khóa ngoại
SET FOREIGN_KEY_CHECKS = 1;

-- Kiểm tra số lượng
-- SELECT 'User' as TableName, COUNT(*) as Count FROM User
-- UNION ALL
-- SELECT 'Customer', COUNT(*) FROM Customer
-- UNION ALL
-- SELECT 'Seller', COUNT(*) FROM Seller
-- UNION ALL
-- SELECT 'Admin', COUNT(*) FROM Admin
-- UNION ALL
-- SELECT 'Voucher', COUNT(*) FROM Voucher
-- UNION ALL
-- SELECT 'Product', COUNT(*) FROM Product;
