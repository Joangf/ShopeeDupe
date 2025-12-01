import pool from "../config/database.js";
import nodemailer from "nodemailer";
import bcrypt from "bcryptjs";
// // Config JWT and twilio
const JWT_SECRET = process.env.JWT_SECRET || "shopeedupe";

// ==============================================================================
// Customer
// ==============================================================================
// Customer Login
export const getUserInfo = async (req, res) => {
  try {
    const userId = req.params.id;
    const sql = "SELECT * FROM `User` WHERE UserID = ?";
    const [rows] = await pool.query(sql, [userId]);
    if (rows.length === 0) {
      return res.status(404).json({ error: "User not found" });
    }
    res.status(200).json({ result: rows[0] });
  } catch (error) {
    console.error("Unexpected error:", error);
    res.status(500).json({ error: "Internal server errors" });
  }
};

export const updateUserInfo = async (req, res) => {
  try {
    const userId = req.params.id;
    const {
      fullName,
      gender,
      dateOfBirth,
      nationalId,
      email,
      phoneNumber,
      address,
    } = req.body;

    const sql = `
      UPDATE \`User\`
      SET FullName = ?, Gender = ?, DateOfBirth = ?, NationalID = ?, Email = ?, PhoneNumber = ?, Address = ?
      WHERE UserID = ?
    `;
    const [result] = await pool.query(sql, [
      fullName,
      gender,
      dateOfBirth,
      nationalId,
      email,
      phoneNumber,
      address,
      userId,
    ]);

    if (result.affectedRows === 0) {
      return res.status(404).json({ error: "User not found" });
    }
    res.status(200).json({ message: "User updated successfully" });
  } catch (error) {
    console.error("Unexpected error:", error);
    res.status(500).json({ error: "Internal server errors" });
  }
};

export const isSeller = async (req, res) => {
  try {
    const userId = req.params.id;
    const sql = "SELECT UserID FROM User u JOIN Seller s ON u.UserID = s.SellerID WHERE u.UserID = ?";
    const [rows] = await pool.query(sql, [userId]);
    res.status(200).json({ isSeller: rows.length > 0 });
  } catch (error) {
    console.error("Unexpected error:", error);
    res.status(500).json({ error: "Internal server errors" });
  }
};
export const customerLogin = async (req, res) => {
  try {
    const {
      userId,
      email,
      phoneNumber,
      password
    } = req.body;
    if (!password) {
      return res.status(400).json({ error: "Missing password" });
    }
    await pool.query("SET @success = NULL;");
    await pool.query("SET @returnedUserID = NULL;");
    await pool.query("SET @reason = NULL;");

    await pool.query(
      "CALL sp_Login(?, ?, ?, ?, @success, @returnedUserID, @reason)",
      [userId, email, phoneNumber, password]
    );

    const [outRows] = await pool.query(
      "SELECT @success AS success, @returnedUserID AS returnedUserID, @reason AS reason"
    );

    const out = outRows[0];

    if (out.success != 1) {
      return res
        .status(401)
        .json({ error: out.reason || "Invalid email or password" });
    }

    return res.status(200).json({
      message: "Login successful",
      userId: out.returnedUserID,
    });
  } catch (error) {
    console.error("Unexpected error:", error);
    res.status(500).json({ error: "Internal server errors" });
  }
};

// Customer Register
export const customerRegister = async (req, res) => {
  const {
    fullName,
    gender,
    dateOfBirth,
    nationalId,
    email,
    phoneNumber,
    address,
    password,
  } = req.body;

  // Validate required fields
  if (!fullName || !email || !password) {
    return res.status(400).json({ error: "Missing required fields" });
  }
  const sql = "CALL sp_AddNewCustomer(?, ?, ?, ?, ?, ?, ?, ?)";

  try {
    const [row] = await pool.query(sql, [
      fullName,
      gender,
      dateOfBirth,
      nationalId,
      email,
      phoneNumber,
      address,
      password,
    ]);
    console.log(row);
    return res.status(200).json({
      message: "User created successfully"
    });
  } catch (err) {
    if (err.code === "ER_DUP_ENTRY") {
      let field = "";

      if (err.sqlMessage.includes("ux_user_email")) field = "Email";
      else if (err.sqlMessage.includes("ux_user_phone")) field = "Phone number";
      else if (err.sqlMessage.includes("ux_user_nationalid"))
        field = "National ID";

      return res.status(400).json({ error: `${field} already exists` });
    }
    return res.status(400).json({ error: err.sqlMessage });
  }
};

// ==============================================================================
// Seller
// ==============================================================================
// Seller Login
export const sellerLogin = async (req, res) => {
  try {
    const { userId, email, phoneNumber, password } = req.body;
    if (!password) {
      return res.status(400).json({ error: "Missing password" });
    }
    await pool.query("SET @success = NULL;");
    await pool.query("SET @returnedUserID = NULL;");
    await pool.query("SET @reason = NULL;");

    await pool.query(
      "CALL sp_Login(?, ?, ?, ?, @success, @returnedUserID, @reason)",
      [userId, email, phoneNumber, password]
    );

    const [outRows] = await pool.query(
      "SELECT @success AS success, @returnedUserID AS returnedUserID, @reason AS reason"
    );

    const out = outRows[0];

    if (out.success != 1) {
      return res
        .status(401)
        .json({ error: out.reason || "Invalid email or password" });
    }

    const [check] = await pool.query(
      "SELECT EXISTS (SELECT 1 FROM Seller WHERE SellerID = ?) AS isExists",
      [out.returnedUserID]
    );
    if (!check[0].isExists) {
      return res.status(401).json({ error: out.reason || "No exist this seller" });
    }
    return res.status(200).json({
      message: "Login successful",
      userId: out.returnedUserID,
    });
  } catch (error) {
    console.error("Unexpected error:", error);
    res.status(500).json({ error: "Internal server errors" });
  }
};

// Seller Register
export const sellerRegister = async (req, res) => {
  try {
    const {
      fullName,
      gender,
      dateOfBirth,
      nationalId,
      email,
      phoneNumber,
      address,
      password,
      businessAddress,
      businessName,
    } = req.body;

    if (!fullName || !email || !password || !nationalId || !phoneNumber) {
      return res.status(400).json({ error: "Missing required fields" });
    }

    const [row] = await pool.query(
      "CALL sp_AddNewSeller(?, ?, ?, ?, ?, ?, ?, ?, ? ,?)",
      [
        fullName,
        gender,
        dateOfBirth,
        nationalId,
        email,
        phoneNumber,
        address,
        password,
        businessAddress,
        businessName,
      ]
    );
    res.status(200).json({ message: "Seller created successfully"});
  } catch (error) {
    if (error.code === "ER_DUP_ENTRY") {
      let field = "";

      if (error.sqlMessage.includes("ux_user_email")) field = "Email";
      else if (error.sqlMessage.includes("ux_user_phone"))
        field = "Phone number";
      else if (error.sqlMessage.includes("ux_user_nationalid"))
        field = "National ID";

      return res.status(400).json({ error: `${field} already exists` });
    }

    return res.status(400).json({ error: error.message });
  }
};

export const sellerRegisterById = async (req, res) => {
  // Implementation for seller registration by ID
  const userId = req.params.id;
  const { businessAddress, businessName } = req.body;
  if (!businessAddress || !businessName) {
    return res.status(400).json({ error: "Missing required fields" });
  }
  try {
    const sql = 'INSERT INTO Seller (SellerID, Type, BusinessAddress, BusinessName) VALUES (?, ?, ?, ?)';
    const [result] = await pool.query(sql, [userId, 'Personal', businessAddress, businessName]);
    res.status(201).json({ message: "Seller registered successfully", data: result });
  } catch (error) {
    console.error("Unexpected error:", error);
    res.status(500).json({ error: "Internal server errors" });
  }
};
export const forgotPassword = async (req, res) => {
  const { email, phonenumber } = req.body;

  if (!email || !phonenumber) {
    return res.status(400).json({ error: "Missing email or phone number" });
  }

  try {
    const db = await pool.getConnection();
    const sql = "CALL func_FindCustomerByEmailandPhone(?, ?)";
    const [rows] = await db.query(sql, [phonenumber, email]);

    // Kết quả từ CALL là rows[0][0]: CustomerID
    if (!rows[0] || rows[0].length === 0) {
      return res.status(404).json({ error: "User not found" });
    }

    const CustomerID = rows[0][0].CustomerID;

    const infoSql = "SELECT FullName, Email FROM `User` WHERE UserID = ?";
    const [infoRows] = await db.query(infoSql, [CustomerID]);
    const customer = infoRows[0];

    // Tạo mật khẩu mới
    const newPassword = Math.random().toString(36).slice(-8);
    const hashedPassword = await bcrypt.hash(newPassword, 10);

    // Cập nhật mật khẩu
    const updateSql = "UPDATE `User` SET PasswordHash = ? WHERE UserID = ?";
    await db.query(updateSql, [hashedPassword, CustomerID]);

    // Gửi email
    const mailOptions = {
      from: `"Shopee" <${process.env.EMAIL_USER}>`,
      to: email,
      subject: "Your new password",
      text: `Hello ${
        customer.FullName || "Customer"
      },\n\nYour password has been reset. Your new password is: ${newPassword}\n\nPlease login and change it immediately.`,
    };

    await transporter.sendMail(mailOptions);

    res.status(200).json({
      message: "Password reset successfully. Please check your email.",
    });
  } catch (error) {
    console.error("Forgot password error:", error);
    res.status(500).json({ error: "Internal server error" });
  }
};

export const verifyEmail = async (req, res) => {
  const { email } = req.body;
};

export const resetPassword = async (req, res) => {
  const { email, newPassword } = req.body;
};
