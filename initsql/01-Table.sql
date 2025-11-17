CREATE TABLE `User` (
  `UserID` int PRIMARY KEY AUTO_INCREMENT,
  `FullName` nvarchar(255),
  `Gender` nvarchar(10),
  `DateOfBirth` date,
  `NationalID` varchar(20) UNIQUE,
  `RegistrationDate` datetime DEFAULT (now()),
  `AccountStatus` varchar(50),
  `LastLogin` datetime,
  `Email` varchar(255) UNIQUE NOT NULL,
  `PhoneNumber` varchar(20) UNIQUE,
  `Address` nvarchar(255),
  `PasswordHash` varchar(255) COMMENT 'Represents the hashed password for security'
);

CREATE TABLE `Customer` (
  `CustomerID` int PRIMARY KEY,
  `Type` nvarchar(255),
  `Behaviour` Text
);

CREATE TABLE `Seller` (
  `SellerID` int PRIMARY KEY,
  `Type` nvarchar(50) NOT NULL COMMENT 'e.g., Personal, Business',
  `BusinessAddress` nvarchar(255),
  `BusinessName` nvarchar(255)
);

CREATE TABLE `Admin` (
  `AdminID` int PRIMARY KEY,
  `Role` nvarchar(255),
  `InternalNotes` text
);

CREATE TABLE `Shipper` (
  `ShipperID` int PRIMARY KEY,
  `BusinessLicenseNumber` varchar(100) UNIQUE,
  `ProfilePictureURL` varchar(255),
  `ActivityStatus` varchar(50) DEFAULT 'Offline' COMMENT 'e.g., Offline, Available, On Delivery',
  `InternalNotes` text,
  `CarrierID` int
);

CREATE TABLE `Order` (
  `OrderID` int PRIMARY KEY,
  `CustomerID` int NOT NULL,
  `OrderDate` datetime NOT NULL DEFAULT (now()),
  `Status` varchar(50) NOT NULL DEFAULT 'Pending',
  `TotalAmount` decimal(10,2) NOT NULL,
  `ShippingAddress` nvarchar(255) NOT NULL,
  `TrackingNumber` varchar(100),
  `PaymentMethod` nvarchar(50),
  `Complant` text
);

CREATE TABLE `Package` (
  `OrderID` int,
  `PackageID` int PRIMARY KEY,
  `WarehouseID` int,
  `PackagedAt` datetime,
  `Status` varchar(50),
  `Quantity` int
);

CREATE TABLE `PackageShipment` (
  `ShipmentID` int,
  `PackageID` int
);

CREATE TABLE `PackageItem` (
  `ProductID` int,
  `PackageID` int,
  `PackageItemID` int,
  `Quantity` int,
  PRIMARY KEY (`PackageItemID`, `ProductID`)
);

CREATE TABLE `Product` (
  `SellerID` int,
  `ProductID` int PRIMARY KEY,
  `VoucherID` int,
  `Name` nvarchar(255) NOT NULL,
  `Barcode` varchar(100) UNIQUE,
  `BrandName` nvarchar(100),
  `Status` varchar(50) NOT NULL DEFAULT 'Active' COMMENT 'e.g., Active, Inactive, Discontinued',
  `Description` text,
  `Price` int,
  `DiscountPrice` int,
  `ApprovalInfo` nvarchar(255),
  `StockQuantity` int
);

CREATE TABLE `Review` (
  `ReviewID` int,
  `ProductID` int,
  `ReplyID` int,
  `CustomerName` nvarchar(255),
  `Title` nvarchar(255),
  `Content` text,
  `CreatedAt` datetime DEFAULT (now()),
  `CustomerID` int,
  PRIMARY KEY (`ReviewID`, `ProductID`)
);

CREATE TABLE `Warehouse` (
  `WarehouseID` int PRIMARY KEY AUTO_INCREMENT,
  `Name` nvarchar(255) NOT NULL,
  `Address` nvarchar(255) NOT NULL,
  `Latitude` decimal(9,6),
  `Longitude` decimal(9,6),
  `Area` decimal(10,2) COMMENT 'Area in square meters',
  `MaxCapacity` int NOT NULL,
  `CurrentCapacity` int NOT NULL DEFAULT 0,
  `OperationalStatus` varchar(50) NOT NULL DEFAULT 'Active',
  `OperatingHours` varchar(100)
);

CREATE TABLE `Voucher` (
  `SellerID` int,
  `AdminID` int,
  `VoucherID` int PRIMARY KEY,
  `PromotionName` nvarchar(255),
  `Status` varchar(20) DEFAULT 'Active',
  `CreatedAt` datetime DEFAULT (now()),
  `ExpiresAt` datetime,
  `UsageCount` int DEFAULT 0,
  `TotalQuantity` int,
  `DiscountValue` int,
  `Description` text,
  `RemainingQuantity` int DEFAULT 0
);

CREATE TABLE `UseVoucher` (
  `VoucherID` int,
  `CustomerID` int,
  `UsedDate` datetime
);

CREATE TABLE `Shipment` (
  `ShipmentID` int PRIMARY KEY,
  `ShipperID` int,
  `Status` varchar(50),
  `CurrentPos` nvarchar(255),
  `LastUpdatedAt` datetime,
  `VehicleID` int
);

CREATE TABLE `StartWarehouse` (
  `ShipmentID` int,
  `WarehouseID` int,
  `ArrivedAt` timestamp
);

CREATE TABLE `EndWarehouse` (
  `ShipmentID` int,
  `WarehouseID` int,
  `ArrivedAt` timestamp
);

CREATE TABLE `StatusLog` (
  `ShipmentID` int,
  `StatusLogID` int,
  `HistoryStatus` varchar(50),
  PRIMARY KEY (`ShipmentID`, `StatusLogID`)
);

CREATE TABLE `Vehicle` (
  `VehicleID` int PRIMARY KEY,
  `LicensePlate` varchar(20),
  `CurrentPos` nvarchar(255),
  `LastUpdatedAt` datetime,
  `RegistrationDate` date,
  `OperationalStatus` varchar(50),
  `Manufacturer` nvarchar(100),
  `Model` nvarchar(100)
);

CREATE TABLE `Motorbike` (
  `MotorbikeID` int PRIMARY KEY,
  `MaxPayload` decimal(8,2) COMMENT 'Maximum payload in kilograms',
  `CargoVolume` decimal(8,2) COMMENT 'Cargo box volume in cubic meters'
);

CREATE TABLE `Truck` (
  `TruckID` int PRIMARY KEY,
  `PayloadCapacity` decimal(10,2) NOT NULL COMMENT 'Payload capacity in tons',
  `OwnershipType` varchar(50) NOT NULL DEFAULT 'Owned' COMMENT 'e.g., Owned, Leased',
  `LeaseStartDate` date,
  `LeaseEndDate` date
);

CREATE TABLE `UseVehicle` (
  `ShipperID` int,
  `VehicleID` int,
  PRIMARY KEY (`ShipperID`, `VehicleID`)
);

CREATE TABLE `CustomerShipment` (
  `ShipmentID` int PRIMARY KEY,
  `CustomerID` int,
  `Position` nvarchar(255),
  `ArrivedAt` timestamp
);

CREATE TABLE `ShoppingCart` (
  `CartID` int PRIMARY KEY,
  `CustomerID` int
);

CREATE TABLE `CartDetail` (
  `CartID` int,
  `ProductID` int,
  PRIMARY KEY (`CartID`, `ProductID`)
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
