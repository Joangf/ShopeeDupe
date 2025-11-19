-- -- DATABASE (tạo schema)
-- CREATE DATABASE IF NOT EXISTS BTL_HCSDL;
-- USE BTL_HCSDL;
-- SELECT DATABASE();
CREATE TABLE `User` (
  `UserID` int PRIMARY KEY AUTO_INCREMENT,  -- Tự có --
  `FullName` nvarchar(255),
  `Gender` nvarchar(10) CHECK (Gender IN ('Male', 'Female')),
  `DateOfBirth` date,
  `NationalID` varchar(20) UNIQUE,
  `RegistrationDate` datetime DEFAULT (now()), -- Tự có --
  `AccountStatus` varchar(50) DEFAULT 'Active', -- Tự có --
  `LastLogin` datetime, -- Tự có --
  `Email` varchar(255) UNIQUE NOT NULL,
  `PhoneNumber` varchar(20) UNIQUE,
  `Address` nvarchar(255),
  `PasswordHash` varchar(255) COMMENT 'Represents the hashed password for security'
);
CREATE TABLE `Customer` (
  `CustomerID` int PRIMARY KEY, -- Tự có --
  `Type` nvarchar(255), -- COMMENT 'Tự có'--
  `Behaviour` Text -- COMMENT 'Thêm sau' --
);

CREATE TABLE `Seller` (
  `SellerID` int PRIMARY KEY, -- Tự có --
  `Type` nvarchar(50) NOT NULL COMMENT 'e.g., Personal, Business', -- Tự có--
  `BusinessAddress` nvarchar(255),
  `BusinessName` nvarchar(255) -- 'Thêm sau/ Tự có' --
);

CREATE TABLE `Admin` (
  `AdminID` int PRIMARY KEY,  -- Tự có --
  `Role` nvarchar(255),
  `InternalNotes` text  -- 'Thêm sau' --
);

CREATE TABLE `Shipper` (
  `ShipperID` int PRIMARY KEY, -- Tự có --
  `BusinessLicenseNumber` varchar(100) UNIQUE,
  `ProfilePictureURL` varchar(255),
  `ActivityStatus` varchar(50) DEFAULT 'Offline' COMMENT 'e.g., Offline, Available, On Delivery', -- Tự có --
  `InternalNotes` text, -- 'Thêm sau'--
  `CarrierID` int
);

CREATE TABLE `Order` (
  `OrderID` int PRIMARY KEY, -- Tự có --
  `CustomerID` int NOT NULL, -- Tự có --
  `OrderDate` datetime NOT NULL DEFAULT (now()), -- Tự có --
  `Status` varchar(50) NOT NULL DEFAULT 'Pending', -- Tự có --
  `TotalAmount` decimal(10,2) NOT NULL, -- Tự có --
  `ShippingAddress` nvarchar(255) NOT NULL,
  `TrackingNumber` varchar(100),
  `PaymentMethod` nvarchar(50),
  `Complant` text
);

CREATE TABLE `Package` (
  `OrderID` int,  -- Tự có --
  `PackageID` int PRIMARY KEY, -- Tự có --
  `WarehouseID` int, -- Tự có --
  `PackagedAt` datetime, -- Tự có --
  `Status` varchar(50), -- Tự có --
  `Quantity` int
);

CREATE TABLE `PackageShipment` (
  `ShipmentID` int, -- Tự có --
  `PackageID` int -- Tự có --
);

CREATE TABLE `PackageItem` (
  `ProductID` int, -- Tự có --
  `PackageID` int, -- Tự có --
  `PackageItemID` int, -- Tự có --
  `Quantity` int,
  PRIMARY KEY (`PackageItemID`, `ProductID`) -- Tự có --
);

CREATE TABLE `Product` (
  `SellerID` int,
  `ProductID` int PRIMARY KEY AUTO_INCREMENT, -- Tự có --
  `VoucherID` int DEFAULT NULL, -- Thêm sau --
  `Name` nvarchar(255) NOT NULL,
  `Barcode` varchar(100) UNIQUE,
  `BrandName` nvarchar(100),
  `Status` varchar(50) NOT NULL DEFAULT 'Active' COMMENT 'e.g., Active, Inactive, Discontinued', -- Tự có --
  `Description` text,
  `Price` int,
  `DiscountPrice` int DEFAULT NULL, -- COMMENT 'Thêm sau' --,
  `ApprovalInfo` nvarchar(255) DEFAULT NULL, -- COMMENT 'Thêm sau' --,
  `StockQuantity` int
);

CREATE TABLE `Review` (
  `ReviewID` int, -- Tự có --
  `ProductID` int, -- Tự có --
  `ReplyID` int, -- Tự có --
  `CustomerName` nvarchar(255), -- Tự có --
  `Title` nvarchar(255),
  `Content` text,
  `CreatedAt` datetime DEFAULT (now()), -- Tự có --
  `CustomerID` int, -- Tự có --
  PRIMARY KEY (`ReviewID`, `ProductID`) -- Tự có --
);

CREATE TABLE `Warehouse` (
  `WarehouseID` int PRIMARY KEY AUTO_INCREMENT, -- Tự có --
  `Name` nvarchar(255) NOT NULL,
  `Address` nvarchar(255) NOT NULL,
  `Latitude` decimal(9,6),
  `Longitude` decimal(9,6),
  `Area` decimal(10,2) COMMENT 'Area in square meters',
  `MaxCapacity` int NOT NULL,
  `CurrentCapacity` int NOT NULL DEFAULT 0, -- Tự có --
  `OperationalStatus` varchar(50) NOT NULL DEFAULT 'Active', -- Tự có --
  `OperatingHours` varchar(100) -- Tự có --
);

CREATE TABLE `Voucher` (
  `SellerID` int, -- Tự có --
  `AdminID` int, -- Tự có --
  `VoucherID` int PRIMARY KEY, -- Tự có --
  `PromotionName` nvarchar(255),
  `Status` varchar(20) DEFAULT 'Active', -- Tự có --
  `CreatedAt` datetime DEFAULT (now()), -- Tự có --
  `ExpiresAt` datetime, -- Tự có --
  `UsageCount` int DEFAULT 0, -- Tự có --
  `TotalQuantity` int,
  `DiscountValue` int,
  `Description` text,
  `RemainingQuantity` int DEFAULT 0
);

CREATE TABLE `UseVoucher` (
  `VoucherID` int,  -- Tự có --
  `CustomerID` int, -- Tự có --
  `UsedDate` datetime
);

CREATE TABLE `Shipment` (
  `ShipmentID` int PRIMARY KEY, -- Tự có --
  `ShipperID` int, -- Tự có --
  `Status` varchar(50), -- Tự có --
  `CurrentPos` nvarchar(255), -- Tự có --
  `LastUpdatedAt` datetime, -- Tự có --
  `VehicleID` int -- Tự có --
);

CREATE TABLE `StartWarehouse` (
  `ShipmentID` int, -- Tự có --
  `WarehouseID` int,  -- Tự có --
  `ArrivedAt` timestamp -- Tự có --
);

CREATE TABLE `EndWarehouse` (
  `ShipmentID` int, -- Tự có --
  `WarehouseID` int,  -- Tự có --
  `ArrivedAt` timestamp -- Tự có --
);

CREATE TABLE `StatusLog` (
  `ShipmentID` int, -- Tự có --
  `StatusLogID` int, -- Tự có --
  `HistoryStatus` varchar(50), -- Tự có --
  PRIMARY KEY (`ShipmentID`, `StatusLogID`) -- Tự có --
);

CREATE TABLE `Vehicle` (
  `VehicleID` int PRIMARY KEY, -- Tự có --
  `LicensePlate` varchar(20),
  `CurrentPos` nvarchar(255), -- Tự có --
  `LastUpdatedAt` datetime, -- Tự có --
  `RegistrationDate` date, -- Tự có --
  `OperationalStatus` varchar(50), -- Tự có --
  `Manufacturer` nvarchar(100),
  `Model` nvarchar(100)
);

CREATE TABLE `Motorbike` (
  `MotorbikeID` int PRIMARY KEY, -- Tự có --
  `MaxPayload` decimal(8,2) COMMENT 'Maximum payload in kilograms',
  `CargoVolume` decimal(8,2) COMMENT 'Cargo box volume in cubic meters'
);

CREATE TABLE `Truck` (
  `TruckID` int PRIMARY KEY, -- Tự có --
  `PayloadCapacity` decimal(10,2) NOT NULL COMMENT 'Payload capacity in tons',
  `OwnershipType` varchar(50) NOT NULL DEFAULT 'Owned' COMMENT 'e.g., Owned, Leased',
  `LeaseStartDate` date, 
  `LeaseEndDate` date 
);

CREATE TABLE `UseVehicle` (
  `ShipperID` int, -- Tự có --
  `VehicleID` int, -- Tự có --
  PRIMARY KEY (`ShipperID`, `VehicleID`) -- Tự có --
);

CREATE TABLE `CustomerShipment` (
  `ShipmentID` int PRIMARY KEY, -- Tự có --
  `CustomerID` int, -- Tự có --
  `Position` nvarchar(255), -- Tự có --
  `ArrivedAt` timestamp -- Tự có --
);

CREATE TABLE `ShoppingCart` (
  `CartID` int PRIMARY KEY, -- Tự có --
  `CustomerID` int -- Tự có --
);

CREATE TABLE `CartDetail` (
  `CartID` int, -- Tự có --
  `ProductID` int, -- Tự có --
  PRIMARY KEY (`CartID`, `ProductID`) -- Tự có --
);

ALTER TABLE `Customer` ADD FOREIGN KEY (`CustomerID`) REFERENCES `User` (`UserID`);

ALTER TABLE `Seller` ADD FOREIGN KEY (`SellerID`) REFERENCES `User` (`UserID`);

ALTER TABLE `Admin` ADD FOREIGN KEY (`AdminID`) REFERENCES `User` (`UserID`);

ALTER TABLE `Shipper` ADD FOREIGN KEY (`ShipperID`) REFERENCES `User` (`UserID`);

ALTER TABLE `Order` ADD FOREIGN KEY (`CustomerID`) REFERENCES `Customer` (`CustomerID`);

ALTER TABLE `Package` ADD FOREIGN KEY (`OrderID`) REFERENCES `Order` (`OrderID`);

ALTER TABLE `Package` ADD FOREIGN KEY (`WarehouseID`) REFERENCES `Warehouse` (`WarehouseID`);

ALTER TABLE `PackageShipment` ADD FOREIGN KEY (`ShipmentID`) REFERENCES `Shipment` (`ShipmentID`);

ALTER TABLE `PackageShipment` ADD FOREIGN KEY (`PackageID`) REFERENCES `Package` (`PackageID`);

ALTER TABLE `PackageItem` ADD FOREIGN KEY (`ProductID`) REFERENCES `Product` (`ProductID`);

ALTER TABLE `PackageItem` ADD FOREIGN KEY (`PackageID`) REFERENCES `Package` (`PackageID`);

ALTER TABLE `Product` ADD FOREIGN KEY (`SellerID`) REFERENCES `Seller` (`SellerID`);

ALTER TABLE `Product` ADD FOREIGN KEY (`VoucherID`) REFERENCES `Voucher` (`VoucherID`);

ALTER TABLE `Review` ADD FOREIGN KEY (`ProductID`) REFERENCES `Product` (`ProductID`);

ALTER TABLE `Review` ADD FOREIGN KEY (`ReplyID`) REFERENCES `Review` (`ProductID`);

ALTER TABLE `Review` ADD FOREIGN KEY (`CustomerID`) REFERENCES `Customer` (`CustomerID`);

ALTER TABLE `Voucher` ADD FOREIGN KEY (`SellerID`) REFERENCES `Seller` (`SellerID`);

ALTER TABLE `Voucher` ADD FOREIGN KEY (`AdminID`) REFERENCES `Admin` (`AdminID`);

ALTER TABLE `UseVoucher` ADD FOREIGN KEY (`VoucherID`) REFERENCES `Voucher` (`VoucherID`);

ALTER TABLE `UseVoucher` ADD FOREIGN KEY (`CustomerID`) REFERENCES `Customer` (`CustomerID`);

ALTER TABLE `Shipment` ADD FOREIGN KEY (`ShipperID`) REFERENCES `Shipper` (`ShipperID`);

ALTER TABLE `Shipment` ADD FOREIGN KEY (`VehicleID`) REFERENCES `Vehicle` (`VehicleID`);

ALTER TABLE `StartWarehouse` ADD FOREIGN KEY (`ShipmentID`) REFERENCES `Shipment` (`ShipmentID`);

ALTER TABLE `StartWarehouse` ADD FOREIGN KEY (`WarehouseID`) REFERENCES `Warehouse` (`WarehouseID`);

ALTER TABLE `EndWarehouse` ADD FOREIGN KEY (`ShipmentID`) REFERENCES `Shipment` (`ShipmentID`);

ALTER TABLE `EndWarehouse` ADD FOREIGN KEY (`WarehouseID`) REFERENCES `Warehouse` (`WarehouseID`);

ALTER TABLE `StatusLog` ADD FOREIGN KEY (`ShipmentID`) REFERENCES `Shipment` (`ShipmentID`);

ALTER TABLE `Motorbike` ADD FOREIGN KEY (`MotorbikeID`) REFERENCES `Vehicle` (`VehicleID`);

ALTER TABLE `Truck` ADD FOREIGN KEY (`TruckID`) REFERENCES `Vehicle` (`VehicleID`);

ALTER TABLE `UseVehicle` ADD FOREIGN KEY (`ShipperID`) REFERENCES `Shipper` (`ShipperID`);

ALTER TABLE `UseVehicle` ADD FOREIGN KEY (`VehicleID`) REFERENCES `Vehicle` (`VehicleID`);

ALTER TABLE `CustomerShipment` ADD FOREIGN KEY (`ShipmentID`) REFERENCES `Shipment` (`ShipmentID`);

ALTER TABLE `CustomerShipment` ADD FOREIGN KEY (`CustomerID`) REFERENCES `Customer` (`CustomerID`);

ALTER TABLE `ShoppingCart` ADD FOREIGN KEY (`CustomerID`) REFERENCES `Customer` (`CustomerID`);

ALTER TABLE `CartDetail` ADD FOREIGN KEY (`CartID`) REFERENCES `ShoppingCart` (`CartID`);

ALTER TABLE `CartDetail` ADD FOREIGN KEY (`ProductID`) REFERENCES `Product` (`ProductID`);

