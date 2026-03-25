import express from 'express';
import authenticationToken from '../middleware/authUser.js';
import {
  createOrder,
  getOrdersByUser,
  getOrderDetails,
  updateOrderPayment
} from '../controllers/orderController.js';

const orderRoute = express.Router();

orderRoute.post('/order/create', authenticationToken, createOrder);
orderRoute.get('/order/user/:userId', authenticationToken, getOrdersByUser);
orderRoute.get('/order/details/:orderId', authenticationToken, getOrderDetails);
orderRoute.put('/order/payment', authenticationToken, updateOrderPayment);
export default orderRoute;