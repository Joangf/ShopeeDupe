import express from 'express';
import {
  customerLogin,
  customerRegister,
  forgotPassword,
  verifyEmail,
  resetPassword,
  sellerLogin,
  sellerRegister
} from "../controllers/userController.js";
import { authAdmin } from '../middleware/authUser.js';
const userRoute = express.Router();

// ============================================================
// Customer Routes
// ============================================================

// register user
userRoute.post('/auth/register/customer', customerRegister);
// login customer
userRoute.post("/auth/login/customer", customerLogin);
userRoute.post("/auth/forgot-password", forgotPassword);
userRoute.post("/verify/email", verifyEmail);
userRoute.post("/auth/reset-password", resetPassword);

// ============================================================
// Seller Routes
// ============================================================
userRoute.post("/auth/login/seller", sellerLogin);
userRoute.post("/auth/register/seller", sellerRegister);


export default userRoute;