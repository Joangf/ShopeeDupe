import express from 'express';
import {
  getUsers,
  postUser,
  forgotPassword,
  verifyEmail,
  resetPassword,
} from "../controllers/userController.js";
import { authAdmin } from '../middleware/authUser.js';
const userRoute = express.Router();

userRoute.get('', authAdmin, getUsers);
userRoute.post('', postUser);

// register user
userRoute.post('/user', postUser);
// login customer
userRoute.post("/auth/login/customer", getUsers);
userRoute.post("/auth/forgot-password", forgotPassword);
userRoute.post("/verify/email", verifyEmail);
userRoute.post("/auth/reset-password", resetPassword);
userRoute.post("/auth/login/seller", resetPassword);
export default userRoute;