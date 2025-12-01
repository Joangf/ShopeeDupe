import express from 'express';

import {
  createOrder
} from '../controllers/orderController.js';

const orderRoute = express.Router();

orderRoute.post('/order/create', createOrder);

export default orderRoute;