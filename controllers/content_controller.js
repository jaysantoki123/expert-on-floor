import BlogPost from '../models/BlogPost.js';
import CaseStudy from '../models/CaseStudy.js';

// GET /blog - List all published blog posts
export const getBlogPosts = async (req, res) => {
  try {
    const { page = 1, limit = 10, category } = req.query;
    const query = { publishedAt: { $exists: true, $lte: new Date() } };
    
    if (category) query.categories = { $in: [category] };

    const posts = await BlogPost.find(query)
      .populate('author', 'userId') // author refers to Expert, populate to get expert's user details if needed
      .sort({ publishedAt: -1 })
      .limit(limit * 1)
      .skip((page - 1) * limit)
      .exec();

    const count = await BlogPost.countDocuments(query);

    res.json({
      posts,
      totalPages: Math.ceil(count / limit),
      currentPage: page
    });
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};

// GET /blog/:slug - Get single blog post by slug
export const getBlogPostBySlug = async (req, res) => {
  try {
    const post = await BlogPost.findOne({ slug: req.params.slug })
      .populate({
        path: 'author',
        populate: { path: 'userId', select: 'fullName profileImage' }
      });
    
    if (!post) return res.status(404).json({ message: 'Blog post not found' });
    
    // Increment views
    post.views += 1;
    await post.save();
    
    res.json(post);
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};

// GET /case-studies - List all case studies
export const getCaseStudies = async (req, res) => {
  try {
    const studies = await CaseStudy.find()
      .populate({
        path: 'expertId',
        populate: { path: 'userId', select: 'fullName profileImage' }
      })
      .sort({ createdAt: -1 });
    res.json(studies);
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};

// GET /case-studies/:slug - Get single case study by slug
export const getCaseStudyBySlug = async (req, res) => {
  try {
    const study = await CaseStudy.findOne({ slug: req.params.slug })
      .populate({
        path: 'expertId',
        populate: { path: 'userId', select: 'fullName profileImage' }
      });
    if (!study) return res.status(404).json({ message: 'Case study not found' });
    res.json(study);
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};



