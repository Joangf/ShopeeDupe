-- Nếu bắt buộc phải dùng stored procedure để trả về bảng:
DELIMITER //
CREATE PROCEDURE sp_GetOrdersByUser(IN p_UserID INT)
BEGIN
    SELECT *
    FROM `Order`
    WHERE CustomerID = p_UserID
    ORDER BY OrderDate ASC;
END;
//
DELIMITER ;

-- MySQL không hỗ trợ table-valued function (function trả về bảng).

-- 
-- HƯỚNG DẪN SỬ DỤNG sp_GetOrdersByUser TRONG JAVASCRIPT (Node.js)
-- 
-- Ví dụ sử dụng với mysql2:
-- 
-- const mysql = require('mysql2/promise');
-- const connection = await mysql.createConnection({host, user, password, database});
-- const [rows] = await connection.query('CALL sp_GetOrdersByUser(?)', [userId]);
-- // rows[0] là kết quả trả về (danh sách order)
-- 
-- Ví dụ sử dụng với mysql:
-- 
-- const mysql = require('mysql');
-- const connection = mysql.createConnection({host, user, password, database});
-- connection.query('CALL sp_GetOrdersByUser(?)', [userId], (err, results) => {
--   if (err) throw err;
--   // results[0] là danh sách order
-- });



