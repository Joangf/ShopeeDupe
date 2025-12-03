import express from 'express';

import {
  addToCart,
  updateCartItem,
  removeFromCart,
  getCartItems,
} from '../controllers/cartController.js';

const cartRoute = express.Router();

cartRoute.post('/cart/add', addToCart);

cartRoute.put('/cart/update', updateCartItem);
cartRoute.delete('/cart/remove', removeFromCart);
cartRoute.get('/cart/:userId', getCartItems);

export default cartRoute;