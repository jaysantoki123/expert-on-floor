import mongoose from 'mongoose';

const notificationSchema = new mongoose.Schema({
  userId: { type: mongoose.Schema.Types.ObjectId, ref: 'User', required: true },
  title: { type: String, required: true },
  message: { type: String, required: true },
  type: { 
    type: String, 
    enum: ['booking', 'payment', 'system', 'expert_verification'], 
    default: 'system' 
  },
  isRead: { type: Boolean, default: false },
  link: { type: String } // Optional link to redirect user (e.g., to booking details)
}, { timestamps: true });

export default mongoose.model('Notification', notificationSchema);
