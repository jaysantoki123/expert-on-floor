import express from 'express';
import { getConversations, getMessages, sendMessage } from '../controllers/chat_controller.js';
import { authMiddleware } from '../middleware/auth.js';

const router = express.Router();
router.use(authMiddleware);

/**
 * @swagger
 * tags:
 *   - name: Chat
 *     description: Real-time messaging via Socket.io, REST fallback endpoints
 *
 * /conversations:
 *   get:
 *     summary: List all conversations for current user
 *     tags: [Chat]
 *     security:
 *       - bearerAuth: []
 *     responses:
 *       200:
 *         description: List of conversations
 *         content:
 *           application/json:
 *             example:
 *               success: true
 *               data:
 *                 - id: 10
 *                   participant:
 *                     id: 1
 *                     name: Rahul Sharma
 *                   lastMessage:
 *                     text: Great session!
 *                     timestamp: "2026-05-13T10:05:00Z"
 *                   unreadCount: 2
 *
 * /conversations/{id}/messages:
 *   get:
 *     summary: Load chat message history for a conversation
 *     tags: [Chat]
 *     security:
 *       - bearerAuth: []
 *     parameters:
 *       - in: path
 *         name: id
 *         required: true
 *         schema:
 *           type: integer
 *         description: Conversation ID
 *       - in: query
 *         name: before
 *         schema:
 *           type: string
 *         description: ISO timestamp for cursor-based pagination
 *       - in: query
 *         name: limit
 *         schema:
 *           type: integer
 *           default: 50
 *     responses:
 *       200:
 *         description: Message history
 *         content:
 *           application/json:
 *             example:
 *               success: true
 *               data:
 *                 - id: 201
 *                   senderId: 5
 *                   text: Hi!
 *                   timestamp: "2026-05-13T10:00:00Z"
 *                   type: text
 *
 * /messages:
 *   post:
 *     summary: Send a text message (REST fallback, also use Socket.io)
 *     tags: [Chat]
 *     security:
 *       - bearerAuth: []
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             type: object
 *             required: [text]
 *             properties:
 *               conversationId:
 *                 type: integer
 *                 description: Required if recipientId not provided
 *               recipientId:
 *                 type: integer
 *                 description: Creates conversation if not exists
 *               text:
 *                 type: string
 *                 example: Hello! Ready for the session?
 *     responses:
 *       201:
 *         description: Message sent
 */

router.get('/conversations', getConversations);
router.get('/conversations/:id/messages', getMessages);
router.post('/messages', sendMessage);

export default router;
