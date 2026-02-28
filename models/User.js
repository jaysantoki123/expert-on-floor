
import mongoose from 'mongoose';

const userSchema = new mongoose.Schema({
  email: { type: String, required: true, unique: true, index: true },
  password: { type: String, required: true },
  fullName: { type: String, required: true },
  role: { type: String, enum: ['client', 'expert', 'admin'], default: 'client' },
  phone: { type: String },
  profileImage: { type: String },
  isEmailVerified: { type: Boolean, default: false },
  isPhoneVerified: { type: Boolean, default: false },
  lastLogin: { type: Date }
}, { timestamps: true });

export default mongoose.model('User', userSchema);
