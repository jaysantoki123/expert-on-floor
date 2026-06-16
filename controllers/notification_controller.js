import { Notification } from '../models/index.js';

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
    res.status(500).json({ success: false, message: error.message });
  }
};

export const markAllRead = async (req, res) => {
  try {
    await Notification.update({ isRead: true }, { where: { userId: req.user.id, isRead: false } });
    res.json({ success: true, message: 'All notifications marked as read' });
  } catch (error) {
    res.status(500).json({ success: false, message: error.message });
  }
};

export const createNotification = async (userId, title, body, type) => {
  try {
    const notification = await Notification.create({ userId, title, body, type });
    return notification;
  } catch (error) {
    console.error('Error creating notification:', error);
  }
};
