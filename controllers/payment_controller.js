import { Booking, Payment } from '../models/index.js';

export const createOrder = async (req, res) => {
  try {
    const { bookingId } = req.body;
    const booking = await Booking.findByPk(bookingId);
    if (!booking) return res.status(404).json({ success: false, message: 'Booking not found' });

    const razorpayOrderId = "order_" + Math.random().toString(36).substr(2, 9);
    booking.razorpayOrderId = razorpayOrderId;
    await booking.save();

    res.json({
      success: true,
      data: {
        razorpayOrderId: razorpayOrderId,
        amount: booking.amount * 100,
        currency: 'INR',
        key: process.env.RAZORPAY_KEY || 'rzp_test_mock'
      }
    });
  } catch (error) {
    res.status(500).json({ success: false, message: error.message });
  }
};

export const verifyPayment = async (req, res) => {
  try {
    const { razorpayOrderId, razorpayPaymentId } = req.body;

    const booking = await Booking.findOne({ where: { razorpayOrderId } });
    if (!booking) return res.status(404).json({ success: false, message: 'Booking not found' });

    booking.status = 'confirmed';
    await booking.save();

    const payment = await Payment.create({
      bookingId: booking.id,
      userId: req.user.id,
      razorpayOrderId,
      razorpayPaymentId,
      amount: booking.amount,
      status: 'success'
    });

    res.json({
      success: true,
      message: 'Payment verified. Booking confirmed.',
      data: { bookingId: booking.id, status: 'confirmed' }
    });
  } catch (error) {
    res.status(500).json({ success: false, message: error.message });
  }
};

export const getPaymentHistory = async (req, res) => {
  try {
    const payments = await Payment.findAll({ where: { userId: req.user.id }, include: [{ model: Booking, as: 'booking' }] });
    res.json({ success: true, data: payments });
  } catch (error) {
    res.status(500).json({ success: false, message: error.message });
  }
};
