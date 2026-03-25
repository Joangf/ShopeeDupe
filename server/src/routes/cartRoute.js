import express from 'express';
import authenticationToken from '../middleware/authUser.js';

import {
  addToCart,
  updateCartItem,
  removeFromCart,
  getCartItems,
} from '../controllers/cartController.js';

const cartRoute = express.Router();

cartRoute.post('/cart/add', authenticationToken, addToCart);

cartRoute.put('/cart/update', authenticationToken, updateCartItem);
cartRoute.delete('/cart/remove', authenticationToken, removeFromCart);
cartRoute.get('/cart/:userId', authenticationToken, getCartItems);

export default cartRoute;