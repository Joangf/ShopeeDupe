import express from 'express';

import {
  createOrder,
  getOrdersByUser,
  getOrderDetails,
  updateOrderPayment
} from '../controllers/orderController.js';

const orderRoute = express.Router();

orderRoute.post('/order/create', createOrder);
orderRoute.get('/order/user/:userId', getOrdersByUser);
orderRoute.get('/order/details/:orderId', getOrderDetails);
orderRoute.put('/order/payment', updateOrderPayment);
export default orderRoute;