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
CALL sp_Test_AddNewSeller_UserNotExist();
CALL sp_Test_ChangeTypeSeller_Success();
CALL sp_Test_ChangeTypeSeller_SellerNotExist();
CALL sp_Test_Login_Success();
CALL sp_Test_Login_WrongPassword();
CALL sp_Test_Login_UserNotExist();
CALL sp_Test_Login_InvalidEmailFormat();
CALL sp_Test_Login_InvalidPhoneFormat();
CALL sp_Test_Login_NoInput();
CALL sp_Test_ChangeUserPassword_Success();
CALL sp_Test_ChangeUserPassword_UserNotExist();
