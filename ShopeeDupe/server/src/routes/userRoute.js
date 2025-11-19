import express from 'express';
import { getUsers, postUser } from '../controllers/userController.js';
import { authAdmin } from '../middleware/authUser.js';
const userRoute = express.Router();

userRoute.get('', authAdmin, getUsers);
userRoute.post('', postUser);

export default userRoute;