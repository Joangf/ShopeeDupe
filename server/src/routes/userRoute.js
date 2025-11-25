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
// login user
userRoute.post("/auth/login", getUsers);
userRoute.post("/auth/forgot-password", forgotPassword);
userRoute.post("/verify/email", verifyEmail);
userRoute.post("/auth/reset-password", resetPassword);
export default userRoute;