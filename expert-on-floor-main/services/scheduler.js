import cron from 'node-cron';
import { Booking, User, Notification } from '../models/index.js';
import { createNotification } from '../controllers/notification_controller.js';
import { Op } from 'sequelize';

export const initScheduler = () => {
  console.log('⏰ Initializing Session Reminder and Expiry Scheduler cron job...');

  // Run every minute
  cron.schedule('* * * * *', async () => {
    try {
      const now = new Date();


      const confirmedBookings = await Booking.findAll({
        where: { bookingStatus: 'CONFIRMED' },
        include: [
          { model: User, as: 'learner', attributes: ['id', 'name'] },
          { model: User, as: 'expert', attributes: ['id', 'name'] }
        ]
      });

      const targetBookings = confirmedBookings.map(booking => {
        const bookingDateTime = new Date(`${booking.date}T${booking.timeSlot}`);
        const diffMs = bookingDateTime - now;
        return { booking, diffMins: Math.round(diffMs / 60000) };
      }).filter(b => b.diffMins === 30 || b.diffMins === 10);

      if (targetBookings.length > 0) {
        const bookingIds = targetBookings.map(b => b.booking.id);
        const existingNotifs = await Notification.findAll({
          where: { bookingId: { [Op.in]: bookingIds }, type: 'session_reminder' }
        });

        for (const { booking, diffMins } of targetBookings) {
          try {
            const timeLabel = `${diffMins} minutes`;
            const title = `Upcoming Session Reminder (${diffMins} mins)`;

            const alreadySent = existingNotifs.some(n => n.bookingId === booking.id && n.title === title && n.userId === booking.learnerId);

            if (!alreadySent) {
              const learnerName = booking.learner ? booking.learner.name : 'Learner';
              const expertName = booking.expert ? booking.expert.name : 'Expert';

              // Notify Learner
              await createNotification(
                booking.learnerId,
                title,
                `Reminder: Your session "${booking.topic || 'Session'}" with ${expertName} starts in ${timeLabel}.`,
                'session_reminder',
                booking.id
              );

              // Notify Expert
              await createNotification(
                booking.expertId,
                title,
                `Reminder: Your session "${booking.topic || 'Session'}" with ${learnerName} starts in ${timeLabel}.`,
                'session_reminder',
                booking.id
              );

              console.log(`✉️ Reminders (${diffMins} mins) sent for Booking ${booking.id}`);
            }
          } catch (bookingErr) {
            console.error(`Error processing reminder for booking ${booking.booking.id}:`, bookingErr);
          }
        }
      }

      // ────────────────────────────────────────────────────────
      // 2. Auto-Expire Unpaid/Pending Bookings
      // Payment deadline = 30 minutes BEFORE session start time.
      // Bookings are only expired once that deadline has passed,
      // giving the learner time to pay before the session begins.
      // ────────────────────────────────────────────────────────
      const PAYMENT_GRACE_MINUTES = 30; // minutes before session start

      const pendingBookings = await Booking.findAll({
        where: {
          bookingStatus: {
            [Op.in]: ['PENDING', 'PAYMENT_PENDING']
          }
        }
      });

      for (const booking of pendingBookings) {
        try {
          const bookingDateTime = new Date(`${booking.date}T${booking.timeSlot}`);
          // Payment deadline: PAYMENT_GRACE_MINUTES before session start
          const paymentDeadline = new Date(bookingDateTime.getTime() - PAYMENT_GRACE_MINUTES * 60 * 1000);

          // Only expire if payment deadline has passed (not just when session starts)
          if (now >= paymentDeadline) {
            booking.bookingStatus = 'PAYMENT_EXPIRED';
            booking.paymentStatus = 'FAILED';
            await booking.save();
            console.log(`⏰ Booking ${booking.id} automatically marked as PAYMENT_EXPIRED (payment deadline passed).`);

            // Notify Learner
            await createNotification(
              booking.learnerId,
              'Session Failed – Payment Not Completed',
              `Your session "${booking.topic || 'Session'}" on ${booking.date} at ${booking.timeSlot} could not be confirmed because payment was not completed in time.`,
              'payment_failed',
              booking.id
            );
          }
        } catch (expireErr) {
          console.error(`Error auto-expiring booking ${booking.id}:`, expireErr);
        }
      }

    } catch (err) {
      console.error('Error running scheduler task:', err);
    }
  });
};
