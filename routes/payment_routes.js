import express from 'express';
import { createOrder, verifyPayment, getPaymentHistory } from '../controllers/payment_controller.js';
import { authMiddleware } from '../middleware/auth.js';

const router = express.Router();
router.use(authMiddleware);

/**
 * @swagger
 * tags:
 *   - name: Payments
 *     description: Razorpay payment integration
 *
 * /payments/create-order:
 *   post:
 *     summary: Create a Razorpay order for a booking
 *     tags: [Payments]
 *     security:
 *       - bearerAuth: []
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             type: object
 *             required: [bookingId]
 *             properties:
 *               bookingId:
 *                 type: integer
 *                 example: 42
 *     responses:
 *       200:
 *         description: Razorpay order created
 *         content:
 *           application/json:
 *             example:
 *               success: true
 *               data:
 *                 razorpayOrderId: order_abc123
 *                 amount: 99900
 *                 currency: INR
 *                 key: rzp_live_xxx
 *       404:
 *         description: Booking not found
 *
 * /payments/verify:
 *   post:
 *     summary: Verify Razorpay payment signature and confirm booking
 *     tags: [Payments]
 *     security:
 *       - bearerAuth: []
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             type: object
 *             required: [razorpayOrderId, razorpayPaymentId]
 *             properties:
 *               razorpayOrderId:
 *                 type: string
 *                 example: order_abc123
 *               razorpayPaymentId:
 *                 type: string
 *                 example: pay_xyz789
 *               razorpaySignature:
 *                 type: string
 *                 example: hmac_sha256_signature
 *     responses:
 *       200:
 *         description: Payment verified, booking confirmed
 *         content:
 *           application/json:
 *             example:
 *               success: true
 *               message: Payment verified. Booking confirmed.
 *               data:
 *                 bookingId: 42
 *                 status: confirmed
 *
 * /payments/history:
 *   get:
 *     summary: Get payment and transaction history for current user
 *     tags: [Payments]
 *     security:
 *       - bearerAuth: []
 *     responses:
 *       200:
 *         description: Payment history
 *         content:
 *           application/json:
 *             example:
 *               success: true
 *               data:
 *                 - id: 1
 *                   razorpayPaymentId: pay_xyz789
 *                   amount: 999
 *                   status: success
 */

router.post('/create-order', createOrder);
router.post('/verify', verifyPayment);
router.get('/history', getPaymentHistory);

export default router;
