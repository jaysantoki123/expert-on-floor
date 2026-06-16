import mongoose from 'mongoose';

const expertiseSchema = new mongoose.Schema({
  name: { type: String, required: true, unique: true }, // e.g., 'EV', 'Foundry', 'Drone'
  description: { type: String },
  icon: { type: String }, // Optional icon URL
  isActive: { type: Boolean, default: true }
}, { timestamps: true });

export default mongoose.model('Expertise', expertiseSchema);
