import { Booking, User, Review, Payment, Expert, Roadmap, Notification } from '../models/index.js';
import Contact from '../models/Contact.js';
import xss from 'xss';
// POST /bookings - Create new booking request
export const createBooking = async (req, res) => {
  try {
    const { expertId, serviceType, scheduledDate, duration, totalAmount, notes } = req.body;
    const newBooking = await Booking.create({
      learnerId: req.user.id, // using learnerId for clientId
      expertId,
      sessionType: serviceType || 'video',
      date: scheduledDate ? scheduledDate.split('T')[0] : new Date().toISOString().split('T')[0],
      timeSlot: scheduledDate ? scheduledDate.split('T')[1]?.substring(0,8) || '12:00:00' : '12:00:00',
      durationMinutes: duration || 60,
      amount: totalAmount || 0,
      topic: notes ? xss(notes) : null,
      bookingStatus: 'PENDING'
    });
    res.status(201).json(newBooking);
  } catch (error) {
    res.status(400).json({ message: 'An internal error occurred' });
  }
};

// GET /bookings/:id - Get booking details
export const getBookingDetails = async (req, res) => {
  try {
    const booking = await Booking.findByPk(req.params.id, {
      include: [
        { model: User, as: 'learner', attributes: ['name', 'profileImage'] },
        { 
          model: User, 
          as: 'expert', 
          attributes: ['name', 'profileImage']
        }
      ]
    });
    if (!booking) return res.status(404).json({ message: 'Booking not found' });
    res.json(booking);
  } catch (error) {
    res.status(500).json({ message: 'An internal error occurred' });
  }
};

// GET /bookings - List user bookings (auth required)
export const getUserBookings = async (req, res) => {
  try {
    const { role } = req.user;
    const query = role === 'expert' ? { expertId: req.user.id } : { learnerId: req.user.id };
    const bookings = await Booking.findAll({
      where: query,
      include: [
        { model: User, as: 'learner', attributes: ['name', 'profileImage'] },
        { 
          model: User, 
          as: 'expert', 
          attributes: ['name', 'profileImage']
        }
      ]
    });
    res.json(bookings);
  } catch (error) {
    res.status(500).json({ message: 'An internal error occurred' });
  }
};

// PUT /bookings/:id - Update booking (reschedule, cancel)
export const updateBooking = async (req, res) => {
  try {
    const { scheduledDate, status, notes } = req.body;
    const booking = await Booking.findByPk(req.params.id);
    if (!booking) return res.status(404).json({ message: 'Booking not found' });

    // Only allow client or expert of this booking
    if (booking.learnerId !== req.user.id && booking.expertId !== req.user.id) {
      return res.status(403).json({ message: 'Unauthorized' });
    }

    if (scheduledDate) {
      booking.date = scheduledDate.split('T')[0];
      booking.timeSlot = scheduledDate.split('T')[1]?.substring(0,8) || booking.timeSlot;
    }
    if (status) booking.bookingStatus = status.toUpperCase();
    if (notes) booking.topic = notes;

    await booking.save();
    res.json(booking);
  } catch (error) {
    res.status(400).json({ message: 'An internal error occurred' });
  }
};

// POST /bookings/:id/confirm - Confirm booking after payment
export const confirmBooking = async (req, res) => {
  try {
    const booking = await Booking.findByPk(req.params.id);
    if (!booking) return res.status(404).json({ message: 'Booking not found' });
    booking.bookingStatus = 'CONFIRMED';
    await booking.save();
    res.json(booking);
  } catch (error) {
    res.status(400).json({ message: 'An internal error occurred' });
  }
};

// POST /bookings/:id/complete - Mark booking as completed
export const completeBooking = async (req, res) => {
  try {
    const booking = await Booking.findByPk(req.params.id);
    if (!booking) return res.status(404).json({ message: 'Booking not found' });
    booking.bookingStatus = 'COMPLETED';
    await booking.save();
    res.json(booking);
  } catch (error) {
    res.status(400).json({ message: 'An internal error occurred' });
  }
};

// POST /bookings/:id/cancel - Cancel booking with reason
export const cancelBooking = async (req, res) => {
  try {
    const { reason } = req.body;
    const booking = await Booking.findByPk(req.params.id);
    if (!booking) return res.status(404).json({ message: 'Booking not found' });
    booking.bookingStatus = 'CANCELLED';
    if (reason) booking.topic = xss(reason);
    await booking.save();
    res.json(booking);
  } catch (error) {
    res.status(400).json({ message: 'An internal error occurred' });
  }
};

// GET /bookings/:id/meeting-link - Get Zoom/Google Meet link
export const getMeetingLink = async (req, res) => {
  try {
    const booking = await Booking.findByPk(req.params.id);
    if (!booking) return res.status(404).json({ message: 'Booking not found' });
    if (booking.bookingStatus !== 'CONFIRMED') return res.status(400).json({ message: 'Booking not confirmed' });
    res.json({ meetingLink: booking.meetingLink || 'https://meet.google.com/mock-link' });
  } catch (error) {
    res.status(500).json({ message: 'An internal error occurred' });
  }
};

// GET /payments - List user payments
export const getUserPayments = async (req, res) => {
  try {
    const payments = await Payment.findAll({
      where: { userId: req.user.id },
      include: [{ model: Booking, as: 'booking' }]
    });
    res.json(payments);
  } catch (error) {
    res.status(500).json({ message: 'An internal error occurred' });
  }
};

// POST /reviews - Create review
export const createReview = async (req, res) => {
  try {
    const { bookingId, expertId, rating, comment } = req.body;
    const newReview = await Review.create({
      bookingId,
      learnerId: req.user.id,
      expertId,
      rating,
      comment
    });

    // Update expert avgRating and totalReviews
    const expert = await Expert.findByPk(expertId);
    if (expert) {
      const prevTotal = expert.totalReviews || 0;
      const prevAvg = parseFloat(expert.avgRating) || 0;
      expert.totalReviews = prevTotal + 1;
      expert.avgRating = ((prevAvg * prevTotal) + rating) / expert.totalReviews;
      await expert.save();
    }

    res.status(201).json(newReview);
  } catch (error) {
    res.status(400).json({ message: 'An internal error occurred' });
  }
};

// POST /contacts - Submit contact form
export const submitContact = async (req, res) => {
  try {
    const { name, email, phone, subject, message } = req.body;
    const newContact = new Contact({ 
      name: name ? xss(name) : name, 
      email, 
      phone, 
      subject: subject ? xss(subject) : subject, 
      message: message ? xss(message) : message 
    });
    await newContact.save();
    res.status(201).json(newContact);
  } catch (error) {
    res.status(400).json({ message: 'An internal error occurred' });
  }
};

// GET /dashboard - Aggregated Learner Dashboard
export const getLearnerDashboard = async (req, res) => {
  try {
    const userId = req.user.id;

    // Upcoming Sessions
    const upcomingSessions = await Booking.findAll({
      where: { learnerId: userId, bookingStatus: ['PAYMENT_PENDING', 'CONFIRMED'] },
      include: [{ model: User, as: 'expert', attributes: ['name', 'profileImage'] }],
      order: [['date', 'ASC']],
      limit: 5
    });

    // Roadmap Progress
    const roadmaps = await Roadmap.findAll({
      where: { userId },
      order: [['createdAt', 'DESC']],
      limit: 2
    });

    // Unread Notifications
    const unreadNotificationsCount = await Notification.count({
      where: { userId, isRead: false }
    });

    // Recent Mentors
    const recentMentorsBookings = await Booking.findAll({
      where: { learnerId: userId, bookingStatus: 'COMPLETED' },
      include: [{ model: User, as: 'expert', attributes: ['name', 'profileImage'] }],
      order: [['date', 'DESC']],
      limit: 5
    });

    // Deduplicate mentors
    const recentMentorsMap = new Map();
    recentMentorsBookings.forEach(booking => {
      if (booking.expert && !recentMentorsMap.has(booking.expertId)) {
        recentMentorsMap.set(booking.expertId, {
          id: booking.expertId,
          name: booking.expert.name,
          profileImage: booking.expert.profileImage
        });
      }
    });
    const recentMentors = Array.from(recentMentorsMap.values());

    res.json({
      success: true,
      data: {
        upcomingSessions,
        roadmaps,
        unreadNotificationsCount,
        recentMentors
      }
    });
  } catch (error) {
    res.status(500).json({ success: false, message: 'An internal error occurred' });
  }
};
