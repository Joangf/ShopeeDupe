import express from 'express';

import {
  addToCart,
  updateCartItem,
  removeFromCart
} from '../controllers/cartController.js';

const cartRoute = express.Router();

cartRoute.post('/cart/add', addToCart);
cartRoute.put('/cart/update', updateCartItem);
cartRoute.delete('/cart/remove', removeFromCart);

export default cartRoute;