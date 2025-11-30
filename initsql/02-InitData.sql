INSERT INTO User (UserID, FullName, Gender, DateOfBirth, NationalID, Email, PhoneNumber, Address, PasswordHash)
VALUES
(1, 'Nguyen Van A', 'Male', '1990-01-01', 'ID001', 'a@gmail.com', '0900000001', 'HCM', 'hash1'),
(2, 'Tran Thi B', 'Female', '1995-05-05', 'ID002', 'b@gmail.com', '0900000002', 'HN', 'hash2'),
(3, 'Le Van C', 'Male', '1985-03-03', 'ID003', 'c@gmail.com', '0900000003', 'DN', 'hash3'),
(4, 'Pham Thi D', 'Female', '1992-02-02', 'ID004', 'd@gmail.com', '0900000004', 'CT', 'hash4'),
(5, 'Hoang Van E', 'Male', '1998-04-04', 'ID005', 'e@gmail.com', '0900000005', 'HCM', 'hash5'),
(6, 'N N N', 'Male', '2005-04-27', 'ID006', 'nnn@gmail.com', '0900000006', 'HCM', 'hash6'),
(7, 'Ngoc Ngu', 'Male', '2005-07-27', 'ID007', 'nnn27@gmail.com', '0900000007', 'HCM', 'hash7'),
(8, 'Nhat Ha', 'Female', '2005-08-01', 'ID008', 'nnh@gmail.com', '0900000008', 'HCM', 'hash8');

INSERT INTO Customer (CustomerID, Type, Behaviour)
VALUES
(1, 'Regular', 'Good buyer'),
(2, 'VIP', 'Frequent buyer'),
(5, 'New', 'Just joined'),
(6, 'Normal', '8m'),
(7, 'Eco', 'Just joined');

INSERT INTO Seller (SellerID, Type, BusinessAddress, BusinessName)
VALUES
(3, 'Business', '123 HCM', 'TechZone'),
(4, 'Personal', '456 HN', 'FashionHome'),
(8, 'Personal', '789 BD', 'FPT');

INSERT INTO Admin (AdminID, Role, InternalNotes)
VALUES
(2, 'Manager', 'Handles promotions');

INSERT INTO Voucher (SellerID, AdminID, VoucherID, PromotionName, Status, ExpiresAt, UsageCount, TotalQuantity, DiscountValue, Description)
VALUES
(3, 2, 1, 'SUMMER2025', 'Active', '2025-12-22', 0, 5, 100000, 'Summer Sale 2025'),
(3, 2, 2, 'WINTER2025', 'Active', '2025-12-27', 0, 8, 50000, 'Winter Discount'),
(4, 2, 3, 'AUTUMN2025', 'Active', '2025-11-11', 0, 10, 200000, 'Autumn Super Sale'),
(4, 2, 4, 'SPRING2026', 'Active', '2026-12-01', 0, 15, 300000, 'Spring Clearance'),
(8, 2, 5, 'FLASHSALE', 'Active', '2025-12-31', 0, 20, 150000, 'Flash sale all categories'),
(8, 2, 6, 'NNNN1', 'Active', '2025-12-31', 0, 17, 150000, 'Flash sale all categories'),
(4, 2, 7, 'NNNN2', 'Active', '2025-11-30', 0, 17, 150000, 'Flash sale all categories'),
(4, 2, 8, 'NNNN3', 'Active', '2025-11-22', 0, 16, 123123, 'Flash sale all categories'),
(3, 2, 9, 'NNNN4', 'Active', '2025-11-30', 0, 16, 123344, 'Flash sale all categories'),
(4, 2, 10, 'NNNN5', 'Active', '2025-11-27', 0, 15, 3234, 'Flash sale all categories');

INSERT INTO UseVoucher (VoucherID, CustomerID, UsedDate)
VALUES
(1, 1, '2025-12-23'),
(1, 1, '2025-12-24'),
(1, 1, '2025-12-25'),
(1, 1, '2025-12-26'),
(1, 2, '2025-12-28'),
(2, 5, '2025-12-28'),
(2, 6, '2025-12-31'),
(3, 7, '2025-12-29'),
(3, 1, '2025-12-30'),
(3, 1, '2025-12-29'),
(4, 2, '2025-12-30'),
(4, 5, '2025-12-29'),
(4, 5, '2025-12-30'),
(4, 5, '2025-12-31'),
(4, 5, '2025-12-29'),
(4, 5, '2025-12-30'),
(4, 6, '2025-12-29'),
(5, 2, '2025-12-31'),
(5, 2, '2025-12-29');