
import Expert from '../models/Expert.js';
import User from '../models/User.js';

// GET /experts - List all verified experts with pagination/filtering
export const getExperts = async (req, res) => {
  try {
    const { page = 1, limit = 10, expertise, minRating } = req.query;
    const query = { verificationStatus: 'verified' };
    
    if (expertise) query.expertise = { $in: [expertise] };
    if (minRating) query.avgRating = { $gte: parseFloat(minRating) };

    const experts = await Expert.find(query)
      .populate('userId', 'fullName profileImage')
      .limit(limit * 1)
      .skip((page - 1) * limit)
      .exec();

    const count = await Expert.countDocuments(query);

    res.json({
      experts,
      totalPages: Math.ceil(count / limit),
      currentPage: page
    });
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};

// GET /experts/:id - Get expert profile with full details
export const getExpertById = async (req, res) => {
  try {
    const expert = await Expert.findById(req.params.id).populate('userId', 'fullName profileImage email phone');
    if (!expert) return res.status(404).json({ message: 'Expert not found' });
    res.json(expert);
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};

// POST /experts/register - Register as expert with credentials
export const registerExpert = async (req, res) => {
  try {
    const { expertise, yearsOfExperience, bio, hourlyRate, projectRate } = req.body;
    const newExpert = new Expert({
      userId: req.user.id, // from auth middleware
      expertise,
      yearsOfExperience,
      bio,
      hourlyRate,
      projectRate
    });
    await newExpert.save();
    
    // Update user role to expert
    await User.findByIdAndUpdate(req.user.id, { role: 'expert' });
    
    res.status(201).json(newExpert);
  } catch (error) {
    res.status(400).json({ message: error.message });
  }
};

// PUT /experts/:id - Update expert profile (auth required)
export const updateExpert = async (req, res) => {
  try {
    const updatedExpert = await Expert.findOneAndUpdate(
      { _id: req.params.id, userId: req.user.id },
      req.body,
      { new: true }
    );
    if (!updatedExpert) return res.status(404).json({ message: 'Expert not found or unauthorized' });
    res.json(updatedExpert);
  } catch (error) {
    res.status(400).json({ message: error.message });
  }
};

// GET /experts/search - Search experts by expertise, location, rating
export const searchExperts = async (req, res) => {
  try {
    const { query, location, minRating } = req.query;
    const filter = { verificationStatus: 'verified' };
    
    if (query) {
      filter.$or = [
        { expertise: { $regex: query, $options: 'i' } },
        { bio: { $regex: query, $options: 'i' } }
      ];
    }
    
    if (minRating) filter.avgRating = { $gte: parseFloat(minRating) };
    
    // Note: Location filtering would depend on how location is stored in User/Expert model
    // Assuming we might add location to User model later

    const experts = await Expert.find(filter).populate('userId', 'fullName profileImage');
    res.json(experts);
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};

// GET /experts/:id/reviews - Get expert reviews and ratings
export const getExpertReviews = async (req, res) => {
  try {
    const reviews = await mongoose.model('Review').find({ expertId: req.params.id }).populate('clientId', 'fullName profileImage');
    res.json(reviews);
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};

// POST /experts/:id/availability - Set expert availability schedule
export const updateExpertAvailability = async (req, res) => {
  try {
    const { availability } = req.body;
    const expert = await Expert.findOneAndUpdate(
      { _id: req.params.id, userId: req.user.id },
      { availability },
      { new: true }
    );
    if (!expert) return res.status(404).json({ message: 'Expert not found or unauthorized' });
    res.json(expert);
  } catch (error) {
    res.status(400).json({ message: error.message });
  }
};
