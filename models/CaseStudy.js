
import mongoose from 'mongoose';

const caseStudySchema = new mongoose.Schema({
  title: { type: String, required: true },
  slug: { type: String, required: true, unique: true },
  challenge: { type: String, required: true },
  solution: { type: String, required: true },
  results: { type: String, required: true },
  expertId: { type: mongoose.Schema.Types.ObjectId, ref: 'Expert' },
  clientIndustry: { type: String },
  metrics: { type: mongoose.Schema.Types.Map, of: String },
  images: [{ type: String }]
}, { timestamps: true });

export default mongoose.model('CaseStudy', caseStudySchema);
