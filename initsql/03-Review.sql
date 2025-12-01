-- Thủ tục tạo Review mới
DELIMITER //
CREATE PROCEDURE CreateReview(
    IN p_ProductID INT,       -- Mã sản phẩm (đảm bảo đã tồn tại)
    IN p_CustomerName NVARCHAR(255), -- Tên khách hàng (có thể cho NULL nếu cho là ẩn danh)
    IN p_Title NVARCHAR(255), -- Tiêu đề review (có thể cho NULL nếu không có tiêu đề)
    IN p_Content TEXT,        -- Nội dung review
    IN p_CustomerID INT       -- Mã khách hàng (đảm bảo đã tồn tại, có thể cho NULL nếu cho là ẩn danh)
)
BEGIN
    INSERT INTO `Review` (ProductID, ReplyID, CustomerName, Title, Content, CreatedAt, CustomerID)
    VALUES (p_ProductID, NULL, p_CustomerName, p_Title, p_Content, NOW(), p_CustomerID);
END;
//
DELIMITER ;

-- Thủ tục trả lời Review (tạo Review mới với ReplyID là ReviewID của review được phản hồi)
DELIMITER //
CREATE PROCEDURE CreateReply(
    IN p_ProductID INT,        -- Mã sản phẩm (đảm bảo đã tồn tại)
    IN p_ReplyID INT,        -- Mã review được phản hồi (đảm bảo đã tồn tại)
    IN p_CustomerName NVARCHAR(255), -- Tên khách hàng trả lời (có thể cho NULL nếu cho là ẩn danh)
    IN p_Title NVARCHAR(255),  -- Tiêu đề review trả lời (có thể cho NULL nếu không có tiêu đề)
    IN p_Content TEXT,         -- Nội dung review trả lời
    IN p_CustomerID INT        -- Mã khách hàng trả lời (đảm bảo đã tồn tại, có thể cho NULL nếu cho là ẩn danh)
)
BEGIN
    INSERT INTO `Review` (ProductID, ReplyID, CustomerName, Title, Content, CreatedAt, CustomerID)
    VALUES (p_ProductID, p_ReplyID, p_CustomerName, p_Title, p_Content, NOW(), p_CustomerID);
END;
//
DELIMITER ;