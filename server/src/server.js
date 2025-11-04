import express from 'express';
import swaggerUi from 'swagger-ui-express';
import swaggerDocument from './config/swagger-output.json' with { type: 'json' };
import dotenv from 'dotenv';
import userRoute from './routes/userRoute.js';
dotenv.config();
const app = express();
app.use('/api/docs', swaggerUi.serve, swaggerUi.setup(swaggerDocument));
app.use(express.json());

// API routes would be defined here
app.use('/api/users', userRoute);

const PORT = process.env.PORT || 3000;
app.listen(PORT, () => {
  console.log(`Server is running on port ${PORT}`);
});
export default app;