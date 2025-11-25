import pool from "../config/database.js";
import nodemailer from "nodemailer";
import bcrypt from "bcryptjs";
// // Config JWT and twilio
const JWT_SECRET = process.env.JWT_SECRET || "shopeedupe";

// const client = twilio(process.env.TWILIO_SID, process.env.TWILIO_AUTH_TOKEN);
// const TWILIO_FROM = process.env.TWILIO_FROM;

// // Create OTP
// function generateOTP(length = 6) {
//   let otp = "";
//   for (let i = 0; i < length; i++) otp += Math.floor(Math.random() * 10);
//   return otp;
// }

const transporter = nodemailer.createTransport({
  host: "smtp.gmail.com",
  port: 465,
  secure: true,
  auth: {
    user: process.env.EMAIL_USER,
    pass: process.env.EMAIL_PASS,
  },
});

// ==============================================================================
// GetUser(email, password)
// ==============================================================================
export const getUsers = async (req, res) => {
  try {
    const {
      email,
      password
    } = req.body;
    if (!email || !password) {
      return res.status(400).json({ error: "Missing email or password" });
    }

    const sql = "func_AuthenticateCustomer(?, ?)";

    const db = await pool.getConnection();
    const [rows] = await db.query(sql, [email, password]);
    if (rows.length === 0) {
      return res.status(401).json({ error: "Invalid email or password" });
    }

    res.status(200).json({ message: "Login successful", result: rows[0] });
  } catch (error) {
    console.error("Unexpected error:", error);
    res.status(500).json({ error: "Internal server error" });
  }
};

// ==============================================================================
// Register
// ==============================================================================
export const postUser = async (req, res) => {
  try {
    const {
      firstname,
      lastName,
      gender,
      dateofbirth,
      nationalid,
      email,
      phonenumber,
      address,
      password,
    } = req.body;

    if (!firstName || !lastName || !email || !password) {
      return res.status(400).json({ error: "Missing required fields" });
    }
    
    const sql = "CALL sp_AddNewCustomer(?, ?, ?, ?, ?, ?, ?, ?)";

    fullname = firstname + " " + lastName;
    const db = await pool.getConnection();
    db.query(
      sql,
      [
        fullname,
        gender,
        dateofbirth,
        nationalid,
        email,
        phonenumber,
        address,
        password,
      ],
      (err, result) => {
        if (err) {
          if (err.code === "ER_DUP_ENTRY") {
            let field = "";
            if (err.sqlMessage.includes("ux_user_email")) field = "Email";
            else if (err.sqlMessage.includes("ux_user_phone"))
              field = "Phone number";
            else if (err.sqlMessage.includes("ux_user_nationalid"))
              field = "National ID";

            return res.status(400).json({ error: `${field} already exists` });
          }
          console.error("Error executing stored procedure:", err);
          return res.status(500).json({ error: "Internal server error" });
        }
        res.status(201).json({
          message: "User created successfully",
          data: result,
        });
      }
    );
  } catch (error) {
    console.error("Unexpected error:", error);
    res.status(500).json({ error: "Internal server error" });
  }
};

// 


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

    res
      .status(200)
      .json({
        message: "Password reset successfully. Please check your email.",
      });

  } catch (error) {
    console.error("Forgot password error:", error);
    res.status(500).json({ error: "Internal server error" });
  }
};

export const verifyEmail = async (req, res) => {
  const { email} = req.body;

  
};

export const resetPassword = async (req, res) => {
  const { email, newPassword } = req.body;
};
