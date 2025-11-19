-- DATABASE (tạo schema)
CREATE DATABASE IF NOT EXISTS BTL_HCSDL;
USE BTL_HCSDL;
SELECT DATABASE();

SELECT * FROM btl_hcsdl.user;
SELECT * FROM btl_hcsdl.seller;

CALL sp_Test_AddNewUser_Success();
CALL sp_Test_AddNewUser_DuplicateEmail();
CALL sp_Test_AddNewUser_InvalidDateOfBirth();
CALL sp_Test_AddNewSeller_Success();
    