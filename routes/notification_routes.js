import express from 'express';
import { getUserNotifications, markAllRead } from '../controllers/notification_controller.js';
import { authMiddleware } from '../middleware/auth.js';

const router = express.Router();
router.use(authMiddleware);

/**
 * @swagger
 * tags:
 *   - name: Notifications
 *     description: User notifications
 *
 * /notifications:
 *   get:
 *     summary: Get all notifications for the current user (newest first)
 *     tags: [Notifications]
 *     security:
 *       - bearerAuth: []
 *     parameters:
 *       - in: query
 *         name: unread
 *         schema:
 *           type: boolean
 *         description: true = only unread notifications
 *     responses:
 *       200:
 *         description: Notifications list
 *         content:
 *           application/json:
 *             example:
 *               success: true
 *               data:
 *                 - id: 1
 *                   type: booking_confirmed
 *                   title: Session Confirmed!
 *                   body: Your session with Rahul Sharma on May 17 is confirmed.
 *                   isRead: false
 *                   createdAt: "2026-05-13T12:00:00Z"
 *               meta:
 *                 unreadCount: 3
 *
 * /notifications/read-all:
 *   patch:
 *     summary: Mark all notifications as read
 *     tags: [Notifications]
 *     security:
 *       - bearerAuth: []
 *     responses:
 *       200:
 *         description: All notifications marked as read
 *         content:
 *           application/json:
 *             example:
 *               success: true
 *               message: All notifications marked as read
 */

router.get('/', getUserNotifications);
router.patch('/read-all', markAllRead);

export default router;
