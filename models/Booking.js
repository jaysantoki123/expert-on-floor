
import mongoose from 'mongoose';

const bookingSchema = new mongoose.Schema({
  clientId: { type: mongoose.Schema.Types.ObjectId, ref: 'User', required: true },
  expertId: { type: mongoose.Schema.Types.ObjectId, ref: 'Expert', required: true },
  serviceType: { type: String, required: true },
  scheduledDate: { type: Date, required: true },
  duration: { type: Number, required: true }, // in minutes
  totalAmount: { type: Number, required: true },
  status: { type: String, enum: ['pending', 'confirmed', 'completed', 'cancelled'], default: 'pending' },
  notes: { type: String },
  meetingLink: { type: String }
}, { timestamps: true });

export default mongoose.model('Booking', bookingSchema);
