import mongoose from 'mongoose';

const certificateSchema = new mongoose.Schema({
  expertId: { type: mongoose.Schema.Types.ObjectId, ref: 'Expert', required: true },
  issuedBy: { type: mongoose.Schema.Types.ObjectId, ref: 'User', required: true }, // Admin ID
  title: { type: String, required: true },
  description: { type: String },
  issueDate: { type: Date, default: Date.now },
  expiryDate: { type: Date },
  certificateId: { type: String, unique: true }, // Unique identifier for verification
  fileUrl: { type: String }, // Path to the generated/uploaded certificate file
  status: { type: String, enum: ['active', 'expired', 'revoked'], default: 'active' }
}, { timestamps: true });

export default mongoose.model('Certificate', certificateSchema);
