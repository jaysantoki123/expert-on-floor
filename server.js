
import express from 'express';
import cors from 'cors';
import cookieParser from 'cookie-parser';
import mongoose from 'mongoose';
import dotenv from 'dotenv';
import authRoutes from './routes/auth_routes.js';
import expertRoutes from './routes/expert_routes.js';
import clientRoutes from './routes/client_routes.js';
import adminRoutes from './routes/admin_routes.js';
import publicRoutes from './routes/public_routes.js';
import notificationRoutes from './routes/notification_routes.js';
import aiRoutes from './routes/ai_routes.js';

dotenv.config();

const app = express();
const PORT = process.env.PORT || 3000;

// MongoDB Connection
mongoose.connect(process.env.MONGO_URI || 'mongodb://localhost:27017/expertonfloor')
    .then(() => console.log('MongoDB connected successfully'))
    .catch(err => console.error('MongoDB connection error:', err));


app.use(express.json());
app.use(cors({
    origin: ["http://localhost", "http://localhost:3000"],
    credentials: true
}))
app.use(cookieParser())
app.use("/uploads", express.static("uploads"));

// Expert on Floor Routes
app.use('/api/v1/public', publicRoutes);
app.use('/api/v1/auth', authRoutes);
app.use('/api/v1/experts', expertRoutes);
app.use('/api/v1/client', clientRoutes);
app.use('/api/v1/admin', adminRoutes);
app.use('/api/v1/notifications', notificationRoutes);
app.use('/api/v1/ai', aiRoutes);

app.listen(PORT, () => {
    console.log(`Expert on Floor Server is running on port ${PORT}`);
})      
