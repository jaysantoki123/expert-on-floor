import { Expert, User, Review, Booking, Payment, sequelize } from '../models/index.js';
import { Op } from 'sequelize';
import { createNotification } from './notification_controller.js';
import xss from 'xss';

export const getExperts = async (req, res) => {
  try {
    const { category, skill, minRating, maxPrice, available, sort, page = 1, limit = 20 } = req.query;
    const where = {};
    
    if (category) where.category = category;
    if (skill) {
      where[Op.and] = sequelize.fn('JSON_CONTAINS', sequelize.col('skills'), JSON.stringify(skill));
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
    res.status(500).json({ success: false, message: 'An internal error occurred' });
  }
};

export const getExpertById = async (req, res) => {
  try {
    const expert = await Expert.findByPk(req.params.id, {
      include: [{ model: User, as: 'user', attributes: ['name', 'profileImage'] }]
    });
    if (!expert) return res.status(404).json({ success: false, message: 'Expert not found' });
    
    res.json({ success: true, data: expert });
  } catch (error) {
    res.status(500).json({ success: false, message: 'An internal error occurred' });
  }
};

export const updateExpertProfile = async (req, res) => {
  try {
    const expert = await Expert.findOne({ where: { userId: req.user.id } });
    if (!expert) return res.status(404).json({ success: false, message: 'Expert profile not found' });
    
    // Only allow experts to update their own profile fields — not system-managed ones
    const allowedFields = ['title', 'category', 'experienceYears', 'pricePerHour', 'skills', 'achievements', 'bio'];
    const updates = {};
    for (const field of allowedFields) {
      if (req.body[field] !== undefined) {
        updates[field] = req.body[field];
      }
    }

    await expert.update(updates);
    
    res.json({ success: true, message: 'Profile updated', data: expert });
  } catch (error) {
    res.status(400).json({ success: false, message: 'An internal error occurred' });
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
    res.status(500).json({ success: false, message: 'An internal error occurred' });
  }
};

export const submitReview = async (req, res) => {
  try {
    const { bookingId, rating, comment } = req.body;
    const safeComment = comment ? xss(comment) : comment;
    const expertId = req.params.id;

    await sequelize.transaction(async (t) => {
      const existingReview = await Review.findOne({ where: { bookingId }, transaction: t });
      if (existingReview) {
        const err = new Error('Review already submitted');
        err.statusCode = 400;
        throw err;
      }

      // Fetch expert WITH a pessimistic row lock (t.LOCK.UPDATE)
      // This prevents the RMW race condition on avgRating/totalReviews
      const expert = await Expert.findByPk(expertId, { lock: t.LOCK.UPDATE, transaction: t });
      if (!expert) {
        const err = new Error('Expert profile not found');
        err.statusCode = 404;
        throw err;
      }

      // Ensure the booking actually exists and belongs to the user
      // Prevents fabricating fake bookings just to submit reviews
      const booking = await Booking.findByPk(bookingId, { transaction: t });
      if (!booking) {
        const err = new Error('Booking not found');
        err.statusCode = 404;
        throw err;
      }
      if (booking.learnerId !== req.user.id) {
        const err = new Error('Unauthorized: You can only review your own bookings');
        err.statusCode = 403;
        throw err;
      }
      if (booking.expertId !== expert.userId) {
        const err = new Error('Booking does not match this expert');
        err.statusCode = 400;
        throw err;
      }

      // Review.expertId is associated with User model, so it expects the expert's User ID (expert.userId)
      await Review.create({
        bookingId,
        learnerId: req.user.id,
        expertId: expert.userId,
        rating,
        comment: safeComment
      }, { transaction: t });
      
      // Update expert rating (safely protected from race conditions by the row lock)
      const prevTotal = expert.totalReviews || 0;
      const prevAvg = parseFloat(expert.avgRating) || 0;
      expert.totalReviews = prevTotal + 1;
      expert.avgRating = ((prevAvg * prevTotal) + rating) / expert.totalReviews;
      await expert.save({ transaction: t });
    });

    res.status(201).json({ success: true, message: 'Review submitted' });
  } catch (error) {
    res.status(error.statusCode || 400).json({ success: false, message: error.message });
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
    res.status(400).json({ success: false, message: 'An internal error occurred' });
  }
};

export const getExpertAvailability = async (req, res) => {
  try {
    const expert = await Expert.findByPk(req.params.id);
    if (!expert) return res.status(404).json({ success: false, message: 'Expert not found' });
    res.json({ success: true, data: expert.availability });
  } catch (error) {
    res.status(500).json({ success: false, message: 'An internal error occurred' });
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
    res.status(400).json({ success: false, message: 'An internal error occurred' });
  }
};

export const getExpertDashboard = async (req, res) => {
  try {
    const userId = req.user.id;
    const expert = await Expert.findOne({ where: { userId } });
    
    if (!expert) return res.status(404).json({ success: false, message: 'Expert profile not found' });

    // Earnings
    const payments = await Payment.findAll({
      where: { status: 'success' },
      include: [{
        model: Booking,
        as: 'booking',
        where: { expertId: userId }
      }]
    });
    
    const totalEarnings = payments.reduce((acc, curr) => acc + parseFloat(curr.amount || 0), 0);

    // Sessions
    const upcomingSessions = await Booking.count({
      where: { expertId: userId, bookingStatus: ['PAYMENT_PENDING', 'CONFIRMED'] }
    });
    
    const completedSessions = await Booking.count({
      where: { expertId: userId, bookingStatus: 'COMPLETED' }
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
    res.status(500).json({ success: false, message: 'An internal error occurred' });
  }
};

export const toggleLikeReview = async (req, res) => {
  try {
    const review = await Review.findByPk(req.params.id);
    if (!review) return res.status(404).json({ success: false, message: 'Review not found' });

    let likedBy = review.likedBy || [];
    const userId = req.user.id;
    const index = likedBy.indexOf(userId);

    let isLikedNow = false;
    if (index === -1) {
      likedBy.push(userId);
      review.likes += 1;
      isLikedNow = true;
    } else {
      likedBy.splice(index, 1);
      review.likes -= 1;
    }

    review.likedBy = [...likedBy];
    review.changed('likedBy', true);
    await review.save();

    // Trigger notification to the author of the review if they are not the liker
    if (isLikedNow && review.learnerId !== userId) {
      const author = await User.findByPk(review.learnerId);
      if (author) {
        await createNotification(
          review.learnerId,
          'Review Liked',
          `${req.user.name} liked your review: "${review.comment ? (review.comment.length > 50 ? review.comment.substring(0, 47) + '...' : review.comment) : 'Starred review'}"`,
          'review_like'
        );
      }
    }

    res.json({ success: true, likes: review.likes, isLiked: isLikedNow });
  } catch (error) {
    res.status(500).json({ success: false, message: 'An internal error occurred' });
  }
};

export const getMyReviews = async (req, res) => {
  try {
    const userId = req.user.id;
    const reviews = await Review.findAll({
      where: { learnerId: userId },
      include: [
        {
          model: User,
          as: 'expert',
          attributes: ['name'],
          include: [{
            model: Expert,
            as: 'expertProfile',
            attributes: ['title', 'category']
          }]
        },
        {
          model: Booking,
          as: 'booking',
          attributes: ['topic', 'sessionType', 'durationMinutes', 'date']
        }
      ],
      order: [['createdAt', 'DESC']]
    });

    res.json({ success: true, data: reviews });
  } catch (error) {
    res.status(500).json({ success: false, message: 'An internal error occurred' });
  }
};
