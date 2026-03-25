import pool from "../config/database.js";
import nodemailer from "nodemailer";
import bcrypt from "bcryptjs";
import jwt from "jsonwebtoken";
const JWT_SECRET = process.env.JWT_SECRET || "shopeedupe";
const transporter = nodemailer.createTransport({
  service: "gmail",
  auth: {
    user: process.env.EMAIL_USER,
    pass: process.env.EMAIL_PASS,
  },
});
const otpStore = new Map();
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
    const sql = "SELECT UserID, BusinessName, BusinessAddress FROM User u JOIN Seller s ON u.UserID = s.SellerID WHERE u.UserID = ?";
    const [rows] = await pool.query(sql, [userId]);
    res.status(200).json({ isSeller: rows.length > 0, businessName: rows[0]?.BusinessName || null, businessAddress: rows[0]?.BusinessAddress || null });
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
      return res.status(401).json({ error: out.reason || "Invalid email or password" });
    }

    const [userInfo] = await pool.query('SELECT FullName FROM User WHERE UserID = ?', [out.returnedUserID]);

    const token = jwt.sign(
      { userId: out.returnedUserID, role: "customer" },
      JWT_SECRET,
      { expiresIn: "1d" }
    );

    res.cookie("token", token, {
      httpOnly: true,     // Protects against XSS
      secure: true,       // Use true in production (HTTPS)
      sameSite: "Strict", // Protects against CSRF
      maxAge: 86400000    // 1 day in milliseconds
    });

    return res.status(200).json({
      message: "Login successful",
      userId: out.returnedUserID,
      userInfo: userInfo[0]
    });
  } catch (error) {
    console.error("Unexpected error:", error);
    res.status(500).json({ error: "Internal server errors" });
  }
};

// OTP for registration
export const sendRegistrationOTP = async (req, res) => {
  const { email, fullName } = req.body;

  if (!email) {
    return res.status(400).json({ error: "Email is required to send OTP" });
  }

  try {
    // 1. Generate a 6-digit OTP
    const otp = Math.floor(100000 + Math.random() * 900000).toString();

    // 2. Store it with an expiration time (e.g., 10 minutes)
    const expiresAt = Date.now() + 10 * 60 * 1000;
    otpStore.set(email, { otp, expiresAt });

    // 3. Send the email
    const mailOptions = {
      from: `"Shopee" <${process.env.EMAIL_USER}>`,
      to: email,
      subject: "Your Registration Verification Code",
      text: `Hello ${fullName || "User"},\n\nYour verification code is: ${otp}\nThis code will expire in 10 minutes.`,
    };

    await transporter.sendMail(mailOptions);

    res.status(200).json({ message: "OTP sent successfully to your email." });
  } catch (error) {
    console.error("Error sending OTP:", error);
    res.status(500).json({ error: "Failed to send OTP" });
  }
};
// Customer Register
export const customerRegister = async (req, res) => {
  const {
    fullName, gender, dateOfBirth, nationalId,
    email, phoneNumber, address, password, otp
  } = req.body;

  // Validate required fields (including OTP)
  if (!fullName || !email || !password || !otp) {
    return res.status(400).json({ error: "Missing required fields or OTP" });
  }

  // Validate OTP
  const record = otpStore.get(email);
  if (!record) {
    return res.status(400).json({ error: "No OTP requested for this email" });
  }
  if (record.otp !== otp) {
    return res.status(400).json({ error: "Invalid OTP" });
  }
  if (Date.now() > record.expiresAt) {
    otpStore.delete(email); // Clean up expired OTP
    return res.status(400).json({ error: "OTP has expired. Please request a new one." });
  }

  const sql = "CALL sp_AddNewCustomer(?, ?, ?, ?, ?, ?, ?, ?)";

  try {
    await pool.query(sql, [
      fullName, gender, dateOfBirth, nationalId,
      email, phoneNumber, address, password,
    ]);

    otpStore.delete(email);

    return res.status(200).json({ message: "User created successfully" });
  } catch (err) {
    if (err.code === "ER_DUP_ENTRY") {
      let field = "";
      if (err.sqlMessage.includes("ux_user_email")) field = "Email";
      else if (err.sqlMessage.includes("ux_user_phone")) field = "Phone number";
      else if (err.sqlMessage.includes("ux_user_nationalid")) field = "National ID";

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
    res.status(200).json({ message: "Seller created successfully" });
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
      text: `Hello ${customer.FullName || "Customer"
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
