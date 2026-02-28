
import mongoose from 'mongoose';

const reviewSchema = new mongoose.Schema({
  bookingId: { type: mongoose.Schema.Types.ObjectId, ref: 'Booking', required: true },
  clientId: { type: mongoose.Schema.Types.ObjectId, ref: 'User', required: true },
  expertId: { type: mongoose.Schema.Types.ObjectId, ref: 'Expert', required: true },
  rating: { type: Number, min: 1, max: 5, required: true },
  comment: { type: String }
}, { timestamps: true });

export default mongoose.model('Review', reviewSchema);
