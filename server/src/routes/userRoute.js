import express from 'express';
import {
  customerLogin,
  customerRegister,
  forgotPassword,
  verifyEmail,
  resetPassword,
  sellerLogin,
  sellerRegister,
  getUserInfo,
  updateUserInfo,
  sellerRegisterById,
  isSeller,
  getProfile,
} from "../controllers/userController.js";
import {
  addNewProduct
} from "../controllers/sellerController.js"
import { authAdmin } from '../middleware/authUser.js';
const userRoute = express.Router();

// ============================================================
// Customer Routes
// ============================================================

// register user
userRoute.get('/user/:id', getUserInfo);
userRoute.put('/user/:id', updateUserInfo);
userRoute.get('/user/role/:id', isSeller);
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
userRoute.post("/auth/register/seller/:id", sellerRegisterById)

userRoute.post("/seller/product/add", addNewProduct)

export default userRoute;