
import mongoose from 'mongoose';

const blogPostSchema = new mongoose.Schema({
  title: { type: String, required: true },
  slug: { type: String, required: true, unique: true },
  content: { type: String, required: true },
  excerpt: { type: String },
  author: { type: mongoose.Schema.Types.ObjectId, ref: 'Expert' },
  featuredImage: { type: String },
  categories: [{ type: String }],
  tags: [{ type: String }],
  metaDescription: { type: String },
  metaKeywords: [{ type: String }],
  views: { type: Number, default: 0 },
  publishedAt: { type: Date }
}, { timestamps: true });

export default mongoose.model('BlogPost', blogPostSchema);
