import express from 'express';
import dotenv from 'dotenv';
import userRoute from './routes/userRoute.js';
import cors from 'cors';
dotenv.config();
const app = express();
app.use(cors('http://localhost:5173'));
app.use(express.json());

// API routes would be defined here
app.use('/api', userRoute);

const PORT = process.env.SERVER_PORT || 3000;
app.listen(PORT, () => {
  console.log(`Server is running on port ${PORT}`);
});