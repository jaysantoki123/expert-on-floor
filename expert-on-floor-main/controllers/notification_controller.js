import { Notification, User } from '../models/index.js';
import { getIO } from '../config/socket.js';
import firebaseAdmin from '../config/firebase.js';
import { getMessaging } from 'firebase-admin/messaging';

export const getUserNotifications = async (req, res) => {
  try {
    const { unread } = req.query;
    const where = { userId: req.user.id };
    if (unread === 'true') where.isRead = false;

    const notifications = await Notification.findAll({
      where,
      order: [['createdAt', 'DESC']],
      limit: 100
    });

    const unreadCount = await Notification.count({ where: { userId: req.user.id, isRead: false } });

    res.json({
      success: true,
      data: notifications,
      meta: { unreadCount }
    });
  } catch (error) {
    res.status(500).json({ success: false, message: 'An internal error occurred' });
  }
};

export const markAllRead = async (req, res) => {
  try {
    await Notification.update({ isRead: true }, { where: { userId: req.user.id, isRead: false } });
    res.json({ success: true, message: 'All notifications marked as read' });
  } catch (error) {
    res.status(500).json({ success: false, message: 'An internal error occurred' });
  }
};

export const createNotification = async (userId, title, body, type, bookingId = null) => {
  console.log(`📢 [createNotification] Called → userId=${userId}, type=${type}, title="${title}", bookingId=${bookingId}`);
  try {
    const notification = await Notification.create({ userId, title, body, type, bookingId });
    
    // Broadcast real-time notification to the user's socket room
    const io = getIO();
    if (io) {
      io.to(`user_${userId}`).emit('new_notification', notification.toJSON());
    }

    // Send FCM push notification if the user has an FCM token and Firebase is initialized
    try {
      const user = await User.findByPk(userId);
      console.log(`🔍 [FCM Diagnostic] Target User ID: ${userId} | User Found: ${!!user} | Has FCM Token: ${user ? !!user.fcmToken : false} | Firebase Admin Initialized: ${!!firebaseAdmin}`);
      if (user && user.fcmToken && firebaseAdmin) {
        const message = {
          notification: {
            title,
            body,
          },
          data: {
            type: type || '',
            bookingId: bookingId ? bookingId.toString() : '',
            click_action: 'FLUTTER_NOTIFICATION_CLICK',
          },
          token: user.fcmToken,
        };

        const response = await getMessaging(firebaseAdmin).send(message);
        console.log(`✉️ FCM push notification sent to user ${userId}:`, response);
      }
    } catch (fcmErr) {
      console.error(`❌ FCM error for user ${userId}:`, fcmErr.message);
    }

    return notification;
  } catch (error) {
    console.error('Error creating notification:', error);
    throw error;
  }
};
