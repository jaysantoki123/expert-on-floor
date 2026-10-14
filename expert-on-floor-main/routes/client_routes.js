
import express from 'express';
import { createBooking, getBookingDetails, getUserBookings, updateBooking, confirmBooking, completeBooking, cancelBooking, getMeetingLink, getUserPayments, createReview, submitContact, getLearnerDashboard } from '../controllers/client_controller.js';
import { authMiddleware, roleMiddleware } from '../middleware/auth.js';

const router = express.Router();


router.post('/contact', submitContact);


router.use(authMiddleware);

router.get('/dashboard', getLearnerDashboard);

router.post('/bookings', roleMiddleware(['learner']), createBooking);
router.get('/bookings/:id', getBookingDetails);
router.get('/bookings', getUserBookings);
router.put('/bookings/:id', updateBooking);
router.post('/bookings/:id/confirm', confirmBooking);
router.post('/bookings/:id/complete', completeBooking);
router.post('/bookings/:id/cancel', cancelBooking);
router.get('/bookings/:id/meeting-link', getMeetingLink);

router.get('/payments', getUserPayments);

router.post('/reviews', roleMiddleware(['learner']), createReview);

export default router;
