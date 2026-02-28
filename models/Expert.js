
import mongoose from 'mongoose';

const expertSchema = new mongoose.Schema({
  userId: { type: mongoose.Schema.Types.ObjectId, ref: 'User', required: true },
  expertise: [{ type: String }],
  yearsOfExperience: { type: Number },
  certifications: [{
    title: String,
    issuer: String,
    year: Number,
    verificationUrl: String
  }],
  bio: { type: String },
  hourlyRate: { type: Number },
  projectRate: { type: Number },
  availability: {
    monday: [{ start: String, end: String }],
    tuesday: [{ start: String, end: String }],
    wednesday: [{ start: String, end: String }],
    thursday: [{ start: String, end: String }],
    friday: [{ start: String, end: String }],
    saturday: [{ start: String, end: String }],
    sunday: [{ start: String, end: String }]
  },
  verificationStatus: { type: String, enum: ['pending', 'verified', 'rejected'], default: 'pending' },
  verificationDocuments: [{ type: String }],
  avgRating: { type: Number, default: 0 },
  totalReviews: { type: Number, default: 0 },
  isFeatured: { type: Boolean, default: false }
}, { timestamps: true });

export default mongoose.model('Expert', expertSchema);
