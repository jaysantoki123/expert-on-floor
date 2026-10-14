import Razorpay from 'razorpay';
import crypto from 'crypto';
import { Booking, Payment, User, sequelize } from '../models/index.js';
import { createNotification } from './notification_controller.js';

let razorpayInstance;
if (process.env.RAZORPAY_KEY && process.env.RAZORPAY_SECRET) {
  razorpayInstance = new Razorpay({
    key_id: process.env.RAZORPAY_KEY,
    key_secret: process.env.RAZORPAY_SECRET
  });
}

export const createOrder = async (req, res) => {
  try {
    const { bookingId } = req.body;
    const booking = await Booking.findByPk(bookingId);
    if (!booking) return res.status(404).json({ success: false, message: 'Booking not found' });

    if (!razorpayInstance) {
      return res.status(500).json({ success: false, message: 'Payment gateway is not configured.' });
    }

    const amountInPaise = Math.round(booking.amount * 100);

    const options = {
      amount: amountInPaise,
      currency: 'INR',
      receipt: `receipt_booking_${booking.id}`
    };

    const order = await razorpayInstance.orders.create(options);

    booking.razorpayOrderId = order.id;
    booking.paymentStatus = 'PENDING';
    await booking.save();

    res.json({
      success: true,
      data: {
        razorpayOrderId: order.id,
        amount: order.amount,
        currency: order.currency,
        key: process.env.RAZORPAY_KEY
      }
    });
  } catch (error) {
    res.status(500).json({ success: false, message: 'An internal error occurred' });
  }
};

export const verifyPayment = async (req, res) => {
  try {
    const { razorpayOrderId, razorpayPaymentId, razorpaySignature } = req.body;

    // All three payment fields are mandatory — reject if any is missing
    if (!razorpayOrderId || !razorpayPaymentId || !razorpaySignature) {
      return res.status(400).json({ success: false, message: 'Missing required payment fields: razorpayOrderId, razorpayPaymentId, razorpaySignature' });
    }

    const booking = await Booking.findOne({ where: { razorpayOrderId } });
    if (!booking) return res.status(404).json({ success: false, message: 'Booking not found' });

    // Idempotency guard: If this booking is already marked as PAID, ignore the replay.
    // This prevents creating duplicate Payment rows for the same order.
    if (booking.paymentStatus === 'PAID') {
      return res.json({
        success: true,
        message: 'Payment already verified.',
        data: { bookingId: booking.id, status: 'confirmed' }
      });
    }

    // Always verify signature — no bypass path
    const expectedSignature = crypto
      .createHmac('sha256', process.env.RAZORPAY_SECRET)
      .update(razorpayOrderId + "|" + razorpayPaymentId)
      .digest('hex');

    if (expectedSignature !== razorpaySignature) {
      return res.status(400).json({ success: false, message: 'Invalid payment signature. Verification failed.' });
    }

    // Atomic: booking status update + payment record creation must both succeed or both roll back.
    // Prevents the phantom state: booking CONFIRMED/PAID with no Payment row.
    const payment = await sequelize.transaction(async (t) => {
      booking.bookingStatus = 'CONFIRMED';
      booking.paymentStatus = 'PAID';
      booking.paymentId = razorpayPaymentId;
      await booking.save({ transaction: t });

      return Payment.create({
        bookingId: booking.id,
        userId: req.user.id,
        razorpayOrderId,
        razorpayPaymentId,
        amount: booking.amount,
        status: 'success'
      }, { transaction: t });
    });

    // Notifications are fire-and-forget — they don't need to be atomic with the payment.
    try {
      const learner = await User.findByPk(booking.learnerId);
      const expert = await User.findByPk(booking.expertId);
      if (learner && expert) {
        // 1. Session Confirmed notification (booking_confirmed)
        await createNotification(
          booking.learnerId,
          'Session Confirmed',
          `Your session with ${expert.name} is confirmed for ${booking.date} at ${booking.timeSlot}.`,
          'booking_confirmed',
          booking.id
        );
        
        // 2. Session Reminder notification (session_reminder)
        await createNotification(
          booking.learnerId,
          'Upcoming Session Reminder',
          `Reminder: Your session "${booking.topic}" with ${expert.name} is scheduled on ${booking.date} at ${booking.timeSlot}.`,
          'session_reminder',
          booking.id
        );

        // 3. Notify the expert too
        await createNotification(
          booking.expertId,
          'New Session Booked',
          `${learner.name} has booked a session with you on ${booking.date} at ${booking.timeSlot}.`,
          'booking_confirmed',
          booking.id
        );
      }
    } catch (notifErr) {
      console.error('Error creating booking/reminder notifications:', notifErr);
    }

    res.json({
      success: true,
      message: 'Payment verified. Booking confirmed.',
      data: { bookingId: booking.id, status: 'confirmed' }
    });
  } catch (error) {
    res.status(500).json({ success: false, message: 'An internal error occurred' });
  }
};

export const getPaymentHistory = async (req, res) => {
  try {
    const payments = await Payment.findAll({
      where: { userId: req.user.id },
      include: [
        {
          model: Booking,
          as: 'booking',
          include: [
            {
              model: User,
              as: 'expert',
              attributes: ['name', 'profileImage']
            }
          ]
        }
      ],
      order: [['createdAt', 'DESC']]
    });
    res.json({ success: true, data: payments });
  } catch (error) {
    res.status(500).json({ success: false, message: 'An internal error occurred' });
  }
};
