import express from 'express';
import { getPosts, createPost, getPostById, createAnswer, toggleLike } from '../controllers/community_controller.js';
import { authMiddleware } from '../middleware/auth.js';

const router = express.Router();

/**
 * @swagger
 * tags:
 *   - name: Community
 *     description: Community Q&A forum
 *
 * /community/posts:
 *   get:
 *     summary: Get paginated list of community questions
 *     tags: [Community]
 *     parameters:
 *       - in: query
 *         name: tag
 *         schema:
 *           type: string
 *         description: Filter by tag e.g. Flutter, Career
 *       - in: query
 *         name: search
 *         schema:
 *           type: string
 *         description: Full-text search in question text
 *       - in: query
 *         name: sort
 *         schema:
 *           type: string
 *           enum: [newest, popular, unanswered]
 *       - in: query
 *         name: page
 *         schema:
 *           type: integer
 *           default: 1
 *       - in: query
 *         name: limit
 *         schema:
 *           type: integer
 *           default: 20
 *     responses:
 *       200:
 *         description: List of posts
 *         content:
 *           application/json:
 *             example:
 *               success: true
 *               data:
 *                 - id: 1
 *                   author:
 *                     id: 5
 *                     name: Nikhil T.
 *                   question: How do I transition from Android to Flutter?
 *                   tag: Flutter
 *                   answers: 12
 *                   likes: 34
 *               meta:
 *                 page: 1
 *                 total: 48
 *   post:
 *     summary: Create a new community question
 *     tags: [Community]
 *     security:
 *       - bearerAuth: []
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             type: object
 *             required: [question, tag]
 *             properties:
 *               question:
 *                 type: string
 *                 example: What is the best state management for Flutter?
 *               tag:
 *                 type: string
 *                 example: Flutter
 *     responses:
 *       201:
 *         description: Post created
 *
 * /community/posts/{id}:
 *   get:
 *     summary: Get a single post with all its answers
 *     tags: [Community]
 *     parameters:
 *       - in: path
 *         name: id
 *         required: true
 *         schema:
 *           type: integer
 *     responses:
 *       200:
 *         description: Post with answers
 *       404:
 *         description: Post not found
 *
 * /community/posts/{id}/answers:
 *   post:
 *     summary: Post an answer to a community question
 *     tags: [Community]
 *     security:
 *       - bearerAuth: []
 *     parameters:
 *       - in: path
 *         name: id
 *         required: true
 *         schema:
 *           type: integer
 *         description: Post ID to answer
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             type: object
 *             required: [answer]
 *             properties:
 *               answer:
 *                 type: string
 *                 example: Riverpod is the recommended approach for 2026...
 *     responses:
 *       201:
 *         description: Answer posted
 *
 * /community/posts/{id}/like:
 *   post:
 *     summary: Toggle like on a post
 *     tags: [Community]
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
 *         description: Like toggled
 *         content:
 *           application/json:
 *             example:
 *               success: true
 *               likes: 35
 *
 * /community/tags:
 *   get:
 *     summary: Get popular community tags
 *     tags: [Community]
 *     responses:
 *       200:
 *         description: Tag list
 */

router.get('/posts', getPosts);
router.get('/tags', (req, res) => res.json({ success: true, data: ['Flutter', 'Node.js', 'React', 'Career', 'DevOps', 'MySQL', 'AI/ML'] }));
router.get('/posts/:id', getPostById);
router.post('/posts', authMiddleware, createPost);
router.post('/posts/:id/answers', authMiddleware, createAnswer);
router.post('/posts/:id/like', authMiddleware, toggleLike);

export default router;
