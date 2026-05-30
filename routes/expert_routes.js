import express from 'express';
import { getExperts, getExpertById, updateExpertProfile, getExpertReviews, submitReview, registerExpert, getExpertAvailability, updateExpertAvailability } from '../controllers/expert_controller.js';
import { authMiddleware, roleMiddleware } from '../middleware/auth.js';

const router = express.Router();

/**
 * @swagger
 * tags:
 *   - name: Experts
 *     description: Expert profiles, search, reviews & availability
 *
 * /experts:
 *   get:
 *     summary: Search and filter experts
 *     tags: [Experts]
 *     parameters:
 *       - in: query
 *         name: category
 *         schema:
 *           type: string
 *         description: e.g. Mobile Dev, AI/ML, Design
 *       - in: query
 *         name: skill
 *         schema:
 *           type: string
 *         description: Skill keyword e.g. Flutter, React
 *       - in: query
 *         name: minRating
 *         schema:
 *           type: number
 *         description: Minimum rating 1-5
 *       - in: query
 *         name: maxPrice
 *         schema:
 *           type: number
 *         description: Max price per hour in INR
 *       - in: query
 *         name: available
 *         schema:
 *           type: boolean
 *         description: true = only available experts
 *       - in: query
 *         name: sort
 *         schema:
 *           type: string
 *           enum: [rating, price_asc, price_desc, sessions]
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
 *         description: List of experts
 *         content:
 *           application/json:
 *             example:
 *               success: true
 *               data:
 *                 - id: 1
 *                   name: Rahul Sharma
 *                   category: Mobile Dev
 *                   rating: 4.9
 *                   pricePerHour: 999
 *               meta:
 *                 page: 1
 *                 total: 42
 *                 pages: 3
 *
 * /experts/top-rated:
 *   get:
 *     summary: Get top-rated experts
 *     tags: [Experts]
 *     responses:
 *       200:
 *         description: Top rated expert list
 *
 * /experts/categories:
 *   get:
 *     summary: Get available expert categories
 *     tags: [Experts]
 *     responses:
 *       200:
 *         description: Category list
 *         content:
 *           application/json:
 *             example:
 *               success: true
 *               data: [Technology, Manufacturing, Logistics, Quality Control, Safety]
 *
 * /experts/{id}:
 *   get:
 *     summary: Get full expert profile
 *     tags: [Experts]
 *     parameters:
 *       - in: path
 *         name: id
 *         required: true
 *         schema:
 *           type: integer
 *         description: Expert user ID
 *     responses:
 *       200:
 *         description: Full expert profile
 *         content:
 *           application/json:
 *             example:
 *               success: true
 *               data:
 *                 id: 1
 *                 name: Rahul Sharma
 *                 title: Senior Flutter Developer
 *                 bio: Ex-Google engineer...
 *                 skills: [Flutter, Dart, Firebase]
 *                 rating: 4.9
 *                 pricePerHour: 999
 *       404:
 *         description: Expert not found
 *
 * /experts/register:
 *   post:
 *     summary: Register the current user as an expert
 *     tags: [Experts]
 *     security:
 *       - bearerAuth: []
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             type: object
 *             required: [title, category, experienceYears, pricePerHour, skills]
 *             properties:
 *               title:
 *                 type: string
 *                 example: Senior Flutter Developer
 *               category:
 *                 type: string
 *                 example: Mobile Dev
 *               experienceYears:
 *                 type: integer
 *                 example: 8
 *               pricePerHour:
 *                 type: integer
 *                 example: 999
 *               skills:
 *                 type: array
 *                 items:
 *                   type: string
 *                 example: [Flutter, Dart, Firebase]
 *               bio:
 *                 type: string
 *               achievements:
 *                 type: array
 *                 items:
 *                   type: string
 *     responses:
 *       201:
 *         description: Expert profile created
 *
 * /experts/profile:
 *   put:
 *     summary: Expert updates their own profile
 *     tags: [Experts]
 *     security:
 *       - bearerAuth: []
 *     requestBody:
 *       content:
 *         application/json:
 *           schema:
 *             type: object
 *             properties:
 *               title:
 *                 type: string
 *               bio:
 *                 type: string
 *               pricePerHour:
 *                 type: integer
 *               skills:
 *                 type: array
 *                 items:
 *                   type: string
 *               isAvailable:
 *                 type: boolean
 *     responses:
 *       200:
 *         description: Profile updated
 *
 * /experts/{id}/reviews:
 *   get:
 *     summary: Get paginated reviews of an expert
 *     tags: [Experts]
 *     parameters:
 *       - in: path
 *         name: id
 *         required: true
 *         schema:
 *           type: integer
 *       - in: query
 *         name: page
 *         schema:
 *           type: integer
 *       - in: query
 *         name: limit
 *         schema:
 *           type: integer
 *     responses:
 *       200:
 *         description: List of reviews
 *   post:
 *     summary: Submit a review after completing a session
 *     tags: [Experts]
 *     security:
 *       - bearerAuth: []
 *     parameters:
 *       - in: path
 *         name: id
 *         required: true
 *         schema:
 *           type: integer
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             type: object
 *             required: [bookingId, rating]
 *             properties:
 *               bookingId:
 *                 type: integer
 *                 example: 42
 *               rating:
 *                 type: integer
 *                 minimum: 1
 *                 maximum: 5
 *                 example: 5
 *               comment:
 *                 type: string
 *                 example: Excellent session! Very clear explanations.
 *     responses:
 *       201:
 *         description: Review submitted
 *
 * /experts/{id}/availability:
 *   get:
 *     summary: Get available time slots for an expert
 *     tags: [Experts]
 *     security:
 *       - bearerAuth: []
 *     parameters:
 *       - in: path
 *         name: id
 *         required: true
 *         schema:
 *           type: integer
 *       - in: query
 *         name: startDate
 *         schema:
 *           type: string
 *           format: date
 *         example: "2026-05-15"
 *     responses:
 *       200:
 *         description: Available slots
 *         content:
 *           application/json:
 *             example:
 *               success: true
 *               data:
 *                 2026-05-15: [09:00, 10:00, 14:00]
 *   post:
 *     summary: Expert sets their availability slots
 *     tags: [Experts]
 *     security:
 *       - bearerAuth: []
 *     parameters:
 *       - in: path
 *         name: id
 *         required: true
 *         schema:
 *           type: integer
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             type: object
 *             properties:
 *               availability:
 *                 type: object
 *                 example:
 *                   2026-05-15: [09:00, 10:00, 14:00]
 *     responses:
 *       200:
 *         description: Availability updated
 */

router.get('/', getExperts);
router.get('/top-rated', getExperts);
router.get('/categories', (req, res) => res.json({ success: true, data: ['Technology', 'Manufacturing', 'Logistics', 'Quality Control', 'Safety'] }));
router.get('/:id', getExpertById);
router.get('/:id/reviews', getExpertReviews);
router.get('/:id/availability', getExpertAvailability);

router.post('/register', authMiddleware, registerExpert);
router.put('/profile', authMiddleware, roleMiddleware(['expert']), updateExpertProfile);
router.post('/:id/reviews', authMiddleware, submitReview);
router.post('/:id/availability', authMiddleware, roleMiddleware(['expert']), updateExpertAvailability);

export default router;
