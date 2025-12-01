import express from 'express';
import dotenv from 'dotenv';
import userRoute from './routes/userRoute.js';
import productRoute from './routes/productRoute.js';
import cartRoute from './routes/cartRoute.js';
import orderRoute from './routes/orderRoute.js';
import cors from 'cors';
dotenv.config();
const app = express();
app.use(cors('http://localhost:5173'));
app.use(express.json());

// API routes would be defined here
app.use('/api', userRoute);
app.use('/api', productRoute);
app.use('/api', cartRoute);
app.use('/api', orderRoute);
const PORT = process.env.SERVER_PORT || 3000;
app.listen(PORT, () => {
  console.log(`Server is running on port ${PORT}`);
});