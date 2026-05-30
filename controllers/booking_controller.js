import { Booking, Expert, User } from '../models/index.js';
import { Op } from 'sequelize';

export const createBooking = async (req, res) => {
  try {
    const { expertId, sessionType, date, timeSlot, durationMinutes, topic } = req.body;
    
    // expertId here is the ID in expert_profiles table
    const expert = await Expert.findByPk(expertId);
    if (!expert) return res.status(404).json({ success: false, message: 'Expert not found' });

    const amount = expert.pricePerHour * (durationMinutes / 60);

    const booking = await Booking.create({
      learnerId: req.user.id,
      expertId: expert.userId, // Storing User ID of expert
      sessionType,
      date,
      timeSlot,
      durationMinutes,
      topic,
      amount,
      status: 'pending_payment'
    });
    
    // Mocking razorpay response
    const razorpayOrderId = "order_" + Math.random().toString(36).substr(2, 9);
    booking.razorpayOrderId = razorpayOrderId;
    await booking.save();

    res.status(201).json({
      success: true,
      data: {
        bookingId: booking.id,
        status: booking.status,
        razorpayOrderId: booking.razorpayOrderId,
        amount: booking.amount,
        currency: 'INR'
      }
    });
  } catch (error) {
    res.status(400).json({ success: false, message: error.message });
  }
};

export const getMyBookings = async (req, res) => {
  try {
    const { status } = req.query;
    const where = {
      [Op.or]: [{ learnerId: req.user.id }, { expertId: req.user.id }]
    };
    if (status) where.status = status;

    const bookings = await Booking.findAll({
      where,
      include: [
        { model: User, as: 'learner', attributes: ['name', 'profileImage'] },
        { model: User, as: 'expert', attributes: ['name', 'profileImage'] }
      ],
      order: [['createdAt', 'DESC']]
    });

    res.json({
      success: true,
      data: bookings,
      meta: { total: bookings.length }
    });
  } catch (error) {
    res.status(500).json({ success: false, message: error.message });
  }
};

export const getBookingById = async (req, res) => {
  try {
    const booking = await Booking.findByPk(req.params.id, {
      include: [
        { model: User, as: 'learner', attributes: ['name', 'profileImage', 'email', 'phone'] },
        { model: User, as: 'expert', attributes: ['name', 'profileImage', 'email', 'phone'] }
      ]
    });
    if (!booking) return res.status(404).json({ success: false, message: 'Booking not found' });
    res.json({ success: true, data: booking });
  } catch (error) {
    res.status(500).json({ success: false, message: error.message });
  }
};

export const cancelBooking = async (req, res) => {
  try {
    const booking = await Booking.findOne({
      where: {
        id: req.params.id,
        [Op.or]: [{ learnerId: req.user.id }, { expertId: req.user.id }]
      }
    });
    if (!booking) return res.status(404).json({ success: false, message: 'Booking not found or unauthorized' });
    
    booking.status = 'cancelled';
    await booking.save();
    
    res.json({ success: true, message: 'Booking cancelled', data: booking });
  } catch (error) {
    res.status(400).json({ success: false, message: error.message });
  }
};
