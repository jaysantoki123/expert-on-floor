import express from 'express';
import { getUserNotifications, markNotificationRead, markAllRead } from '../controllers/notification_controller.js';
import { authMiddleware } from '../middleware/auth.js';

const router = express.Router();

router.use(authMiddleware);

router.get('/', getUserNotifications);
router.put('/:id/read', markNotificationRead);
router.put('/read-all', markAllRead);

export default router;
