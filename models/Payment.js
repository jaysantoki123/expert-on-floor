
import mongoose from 'mongoose';

const paymentSchema = new mongoose.Schema({
  bookingId: { type: mongoose.Schema.Types.ObjectId, ref: 'Booking', required: true },
  userId: { type: mongoose.Schema.Types.ObjectId, ref: 'User', required: true },
  amount: { type: Number, required: true },
  razorpayOrderId: { type: String, required: true },
  razorpayPaymentId: { type: String },
  status: { type: String, enum: ['pending', 'success', 'failed'], default: 'pending' },
  paymentMethod: { type: String }
}, { timestamps: true });

export default mongoose.model('Payment', paymentSchema);
