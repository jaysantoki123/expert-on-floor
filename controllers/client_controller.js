import { Booking, User, Review, Payment, Expert, Roadmap, Notification } from '../models/index.js';
import Contact from '../models/Contact.js';
// POST /bookings - Create new booking request
export const createBooking = async (req, res) => {
  try {
    const { expertId, serviceType, scheduledDate, duration, totalAmount, notes } = req.body;
    const newBooking = new Booking({
      clientId: req.user.id,
      expertId,
      serviceType,
      scheduledDate,
      duration,
      totalAmount,
      notes,
      status: 'pending'
    });
    await newBooking.save();
    res.status(201).json(newBooking);
  } catch (error) {
    res.status(400).json({ message: error.message });
  }
};

// GET /bookings/:id - Get booking details
export const getBookingDetails = async (req, res) => {
  try {
    const booking = await Booking.findById(req.params.id)
      .populate('clientId', 'fullName profileImage')
      .populate({
        path: 'expertId',
        populate: { path: 'userId', select: 'fullName profileImage' }
      });
    if (!booking) return res.status(404).json({ message: 'Booking not found' });
    res.json(booking);
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};

// GET /bookings - List user bookings (auth required)
export const getUserBookings = async (req, res) => {
  try {
    const { role } = req.user;
    const query = role === 'expert' ? { expertId: req.user.expertId } : { clientId: req.user.id };
    const bookings = await Booking.find(query)
      .populate('clientId', 'fullName profileImage')
      .populate({
        path: 'expertId',
        populate: { path: 'userId', select: 'fullName profileImage' }
      });
    res.json(bookings);
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};

// PUT /bookings/:id - Update booking (reschedule, cancel)
export const updateBooking = async (req, res) => {
  try {
    const { scheduledDate, status, notes } = req.body;
    const booking = await Booking.findById(req.params.id);
    if (!booking) return res.status(404).json({ message: 'Booking not found' });

    // Only allow client or expert of this booking
    if (booking.clientId.toString() !== req.user.id && (!req.user.expertId || booking.expertId.toString() !== req.user.expertId)) {
      return res.status(403).json({ message: 'Unauthorized' });
    }

    if (scheduledDate) booking.scheduledDate = scheduledDate;
    if (status) booking.status = status;
    if (notes) booking.notes = notes;

    await booking.save();
    res.json(booking);
  } catch (error) {
    res.status(400).json({ message: error.message });
  }
};

// POST /bookings/:id/confirm - Confirm booking after payment
export const confirmBooking = async (req, res) => {
  try {
    const booking = await Booking.findByIdAndUpdate(req.params.id, { status: 'confirmed' }, { new: true });
    if (!booking) return res.status(404).json({ message: 'Booking not found' });
    res.json(booking);
  } catch (error) {
    res.status(400).json({ message: error.message });
  }
};

// POST /bookings/:id/complete - Mark booking as completed
export const completeBooking = async (req, res) => {
  try {
    const booking = await Booking.findByIdAndUpdate(req.params.id, { status: 'completed' }, { new: true });
    if (!booking) return res.status(404).json({ message: 'Booking not found' });
    res.json(booking);
  } catch (error) {
    res.status(400).json({ message: error.message });
  }
};

// POST /bookings/:id/cancel - Cancel booking with reason
export const cancelBooking = async (req, res) => {
  try {
    const { reason } = req.body;
    const booking = await Booking.findByIdAndUpdate(req.params.id, { status: 'cancelled', notes: reason }, { new: true });
    if (!booking) return res.status(404).json({ message: 'Booking not found' });
    res.json(booking);
  } catch (error) {
    res.status(400).json({ message: error.message });
  }
};

// GET /bookings/:id/meeting-link - Get Zoom/Google Meet link
export const getMeetingLink = async (req, res) => {
  try {
    const booking = await Booking.findById(req.params.id);
    if (!booking) return res.status(404).json({ message: 'Booking not found' });
    if (booking.status !== 'confirmed') return res.status(400).json({ message: 'Booking not confirmed' });
    res.json({ meetingLink: booking.meetingLink });
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};

// GET /payments - List user payments
export const getUserPayments = async (req, res) => {
  try {
    const payments = await Payment.find({ userId: req.user.id }).populate('bookingId');
    res.json(payments);
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};

// POST /reviews - Create review
export const createReview = async (req, res) => {
  try {
    const { bookingId, expertId, rating, comment } = req.body;
    const newReview = new Review({
      bookingId,
      clientId: req.user.id,
      expertId,
      rating,
      comment
    });
    await newReview.save();

    // Update expert avgRating and totalReviews
    const expert = await Expert.findById(expertId);
    if (expert) {
      expert.totalReviews += 1;
      expert.avgRating = ((expert.avgRating * (expert.totalReviews - 1)) + rating) / expert.totalReviews;
      await expert.save();
    }

    res.status(201).json(newReview);
  } catch (error) {
    res.status(400).json({ message: error.message });
  }
};

// POST /contacts - Submit contact form
export const submitContact = async (req, res) => {
  try {
    const { name, email, phone, subject, message } = req.body;
    const newContact = new Contact({ name, email, phone, subject, message });
    await newContact.save();
    res.status(201).json(newContact);
  } catch (error) {
    res.status(400).json({ message: error.message });
  }
};

// GET /dashboard - Aggregated Learner Dashboard
export const getLearnerDashboard = async (req, res) => {
  try {
    const userId = req.user.id;

    // Upcoming Sessions
    const upcomingSessions = await Booking.findAll({
      where: { learnerId: userId, status: ['pending_payment', 'confirmed'] },
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
      where: { learnerId: userId, status: 'completed' },
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
    res.status(500).json({ success: false, message: error.message });
  }
};
