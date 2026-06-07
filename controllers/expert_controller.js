import { Expert, User, Review, Booking, Payment } from '../models/index.js';
import { Op } from 'sequelize';

export const getExperts = async (req, res) => {
  try {
    const { category, skill, minRating, maxPrice, available, sort, page = 1, limit = 20 } = req.query;
    const where = {};
    
    if (category) where.category = category;
    if (skill) {
      where.skills = {
        [Op.like]: `%${skill}%` // Note: Simplified for JSON array search in MySQL
      };
    }
    if (minRating) where.avgRating = { [Op.gte]: parseFloat(minRating) };
    if (maxPrice) where.pricePerHour = { [Op.lte]: parseInt(maxPrice) };
    if (available === 'true') where.isAvailable = true;

    let order = [['createdAt', 'DESC']];
    if (sort === 'rating') order = [['avgRating', 'DESC']];
    else if (sort === 'price_asc') order = [['pricePerHour', 'ASC']];
    else if (sort === 'price_desc') order = [['pricePerHour', 'DESC']];
    else if (sort === 'sessions') order = [['totalSessions', 'DESC']];

    const { rows: experts, count: total } = await Expert.findAndCountAll({
      where,
      include: [{ model: User, as: 'user', attributes: ['name', 'profileImage'] }],
      order,
      limit: parseInt(limit),
      offset: (parseInt(page) - 1) * parseInt(limit)
    });

    res.json({
      success: true,
      data: experts,
      meta: {
        page: parseInt(page),
        total,
        pages: Math.ceil(total / limit)
      }
    });
  } catch (error) {
    res.status(500).json({ success: false, message: error.message });
  }
};

export const getExpertById = async (req, res) => {
  try {
    const expert = await Expert.findByPk(req.params.id, {
      include: [{ model: User, as: 'user', attributes: ['name', 'profileImage', 'email', 'phone'] }]
    });
    if (!expert) return res.status(404).json({ success: false, message: 'Expert not found' });
    
    res.json({ success: true, data: expert });
  } catch (error) {
    res.status(500).json({ success: false, message: error.message });
  }
};

export const updateExpertProfile = async (req, res) => {
  try {
    const expert = await Expert.findOne({ where: { userId: req.user.id } });
    if (!expert) return res.status(404).json({ success: false, message: 'Expert profile not found' });
    
    await expert.update(req.body);
    
    res.json({ success: true, message: 'Profile updated', data: expert });
  } catch (error) {
    res.status(400).json({ success: false, message: error.message });
  }
};

export const getExpertReviews = async (req, res) => {
  try {
    const { page = 1, limit = 20 } = req.query;
    const { rows: reviews, count: total } = await Review.findAndCountAll({
      where: { expertId: req.params.id },
      include: [{ model: User, as: 'learner', attributes: ['name', 'profileImage'] }],
      limit: parseInt(limit),
      offset: (parseInt(page) - 1) * parseInt(limit),
      order: [['createdAt', 'DESC']]
    });

    res.json({
      success: true,
      data: reviews,
      meta: { page: parseInt(page), total }
    });
  } catch (error) {
    res.status(500).json({ success: false, message: error.message });
  }
};

export const submitReview = async (req, res) => {
  try {
    const { bookingId, rating, comment } = req.body;
    const expertId = req.params.id;
    
    const existingReview = await Review.findOne({ where: { bookingId } });
    if (existingReview) return res.status(400).json({ success: false, message: 'Review already submitted' });

    const review = await Review.create({
      bookingId,
      learnerId: req.user.id,
      expertId,
      rating,
      comment
    });
    
    // Update expert rating
    const expert = await Expert.findByPk(expertId);
    if (expert) {
      const prevTotal = expert.totalReviews || 0;
      const prevAvg = parseFloat(expert.avgRating) || 0;
      expert.totalReviews = prevTotal + 1;
      expert.avgRating = ((prevAvg * prevTotal) + rating) / expert.totalReviews;
      await expert.save();
    }

    res.status(201).json({ success: true, message: 'Review submitted' });
  } catch (error) {
    res.status(400).json({ success: false, message: error.message });
  }
};

export const registerExpert = async (req, res) => {
  try {
    const { title, category, experienceYears, pricePerHour, skills, bio, achievements } = req.body;
    
    const existingExpert = await Expert.findOne({ where: { userId: req.user.id } });
    if (existingExpert) return res.status(400).json({ success: false, message: 'Expert profile already exists' });

    const newExpert = await Expert.create({
      userId: req.user.id,
      title,
      category,
      experienceYears,
      pricePerHour,
      skills,
      bio,
      achievements
    });
    
    await User.update({ role: 'expert' }, { where: { id: req.user.id } });
    
    res.status(201).json({ success: true, message: 'Expert profile created', data: newExpert });
  } catch (error) {
    res.status(400).json({ success: false, message: error.message });
  }
};

export const getExpertAvailability = async (req, res) => {
  try {
    const expert = await Expert.findByPk(req.params.id);
    if (!expert) return res.status(404).json({ success: false, message: 'Expert not found' });
    res.json({ success: true, data: expert.availability });
  } catch (error) {
    res.status(500).json({ success: false, message: error.message });
  }
};

export const updateExpertAvailability = async (req, res) => {
  try {
    const { availability } = req.body;
    const expert = await Expert.findOne({ where: { userId: req.user.id } });
    if (!expert) return res.status(404).json({ success: false, message: 'Expert profile not found' });
    
    expert.availability = availability;
    await expert.save();
    
    res.json({ success: true, message: 'Availability updated', data: expert.availability });
  } catch (error) {
    res.status(400).json({ success: false, message: error.message });
  }
};

export const getExpertDashboard = async (req, res) => {
  try {
    const userId = req.user.id;
    const expert = await Expert.findOne({ where: { userId } });
    
    if (!expert) return res.status(404).json({ success: false, message: 'Expert profile not found' });

    // Earnings
    const payments = await Payment.findAll({
      where: { status: 'completed' },
      include: [{
        model: Booking,
        as: 'booking',
        where: { expertId: userId }
      }]
    });
    
    const totalEarnings = payments.reduce((acc, curr) => acc + parseFloat(curr.amount || 0), 0);

    // Sessions
    const upcomingSessions = await Booking.count({
      where: { expertId: userId, status: ['pending_payment', 'confirmed'] }
    });
    
    const completedSessions = await Booking.count({
      where: { expertId: userId, status: 'completed' }
    });

    // Recent Reviews
    const recentReviews = await Review.findAll({
      where: { expertId: userId },
      include: [{ model: User, as: 'learner', attributes: ['name', 'profileImage'] }],
      order: [['createdAt', 'DESC']],
      limit: 5
    });

    res.json({
      success: true,
      data: {
        totalEarnings,
        upcomingSessions,
        completedSessions,
        avgRating: expert.avgRating || 0,
        totalReviews: expert.totalReviews || 0,
        recentReviews,
        availability: expert.availability
      }
    });
  } catch (error) {
    res.status(500).json({ success: false, message: error.message });
  }
};
