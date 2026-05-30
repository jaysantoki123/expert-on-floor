import express from 'express';
import { createBooking, getMyBookings, getBookingById, cancelBooking } from '../controllers/booking_controller.js';
import { authMiddleware } from '../middleware/auth.js';

const router = express.Router();
router.use(authMiddleware);

/**
 * @swagger
 * tags:
 *   - name: Bookings
 *     description: Session booking management
 *
 * /bookings:
 *   post:
 *     summary: Create a new session booking with an expert
 *     tags: [Bookings]
 *     security:
 *       - bearerAuth: []
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             type: object
 *             required: [expertId, sessionType, date, timeSlot, durationMinutes]
 *             properties:
 *               expertId:
 *                 type: integer
 *                 example: 1
 *               sessionType:
 *                 type: string
 *                 enum: [chat, audio, video]
 *                 example: video
 *               date:
 *                 type: string
 *                 format: date
 *                 example: "2026-05-17"
 *               timeSlot:
 *                 type: string
 *                 example: "16:00"
 *               durationMinutes:
 *                 type: integer
 *                 example: 60
 *               topic:
 *                 type: string
 *                 example: Flutter State Management
 *     responses:
 *       201:
 *         description: Booking created with payment order
 *         content:
 *           application/json:
 *             example:
 *               success: true
 *               data:
 *                 bookingId: 42
 *                 status: pending_payment
 *                 razorpayOrderId: order_abc123
 *                 amount: 999
 *                 currency: INR
 *   get:
 *     summary: Get all bookings for the current user (learner or expert)
 *     tags: [Bookings]
 *     security:
 *       - bearerAuth: []
 *     parameters:
 *       - in: query
 *         name: status
 *         schema:
 *           type: string
 *           enum: [pending_payment, confirmed, completed, cancelled]
 *       - in: query
 *         name: type
 *         schema:
 *           type: string
 *           enum: [upcoming, past]
 *     responses:
 *       200:
 *         description: List of bookings
 *         content:
 *           application/json:
 *             example:
 *               success: true
 *               data:
 *                 - id: 42
 *                   sessionType: video
 *                   date: "2026-05-17"
 *                   status: confirmed
 *                   amount: 999
 *               meta:
 *                 total: 8
 *
 * /bookings/{id}:
 *   get:
 *     summary: Get single booking details
 *     tags: [Bookings]
 *     security:
 *       - bearerAuth: []
 *     parameters:
 *       - in: path
 *         name: id
 *         required: true
 *         schema:
 *           type: integer
 *         description: Booking ID
 *     responses:
 *       200:
 *         description: Booking details
 *       404:
 *         description: Booking not found
 *
 * /bookings/{id}/cancel:
 *   patch:
 *     summary: Cancel a booking
 *     tags: [Bookings]
 *     security:
 *       - bearerAuth: []
 *     parameters:
 *       - in: path
 *         name: id
 *         required: true
 *         schema:
 *           type: integer
 *     responses:
 *       200:
 *         description: Booking cancelled
 *       404:
 *         description: Booking not found or unauthorized
 */

router.post('/', createBooking);
router.get('/', getMyBookings);
router.get('/:id', getBookingById);
router.patch('/:id/cancel', cancelBooking);

export default router;
