import express from 'express';
import { getMyRoadmap, generateRoadmap, updateRoadmapStep, smartMatch, optimizeProfile, analyzeChallenge } from '../controllers/ai_controller.js';
import { authMiddleware, roleMiddleware } from '../middleware/auth.js';

const router = express.Router();

/**
 * @swagger
 * tags:
 *   - name: AI
 *     description: AI features - Smart Match, Profile Optimizer
 *   - name: Roadmap
 *     description: AI-powered career roadmap generation and tracking
 *
 * /roadmap:
 *   get:
 *     summary: Get current user's career roadmap
 *     tags: [Roadmap]
 *     security:
 *       - bearerAuth: []
 *     responses:
 *       200:
 *         description: User's active roadmap
 *         content:
 *           application/json:
 *             example:
 *               success: true
 *               data:
 *                 roadmapId: 7
 *                 title: Flutter Developer
 *                 totalWeeks: 15
 *                 progressPercent: 33
 *                 steps:
 *                   - id: 1
 *                     title: Dart Fundamentals
 *                     weeks: 2
 *                     isCompleted: true
 *       404:
 *         description: No roadmap found
 *
 * /roadmap/generate:
 *   post:
 *     summary: Generate an AI-powered personalized career roadmap
 *     tags: [Roadmap]
 *     security:
 *       - bearerAuth: []
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             type: object
 *             required: [goal, currentLevel, timeAvailableWeekly]
 *             properties:
 *               goal:
 *                 type: string
 *                 example: Become a Flutter developer and get a job
 *               currentLevel:
 *                 type: string
 *                 enum: [beginner, intermediate, advanced]
 *                 example: beginner
 *               timeAvailableWeekly:
 *                 type: integer
 *                 example: 10
 *                 description: Hours available per week
 *     responses:
 *       200:
 *         description: Roadmap generated
 *         content:
 *           application/json:
 *             example:
 *               success: true
 *               data:
 *                 roadmapId: 7
 *                 title: Flutter Developer
 *                 totalWeeks: 15
 *                 steps:
 *                   - id: 1
 *                     title: Dart Fundamentals
 *                     weeks: 2
 *                     isCompleted: false
 *                     resources: [Dart docs, DartPad]
 *
 * /roadmap/steps/{id}:
 *   patch:
 *     summary: Mark a roadmap step as complete or incomplete
 *     tags: [Roadmap]
 *     security:
 *       - bearerAuth: []
 *     parameters:
 *       - in: path
 *         name: id
 *         required: true
 *         schema:
 *           type: integer
 *         description: Roadmap step ID
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             type: object
 *             required: [isCompleted]
 *             properties:
 *               isCompleted:
 *                 type: boolean
 *                 example: true
 *     responses:
 *       200:
 *         description: Step updated
 *         content:
 *           application/json:
 *             example:
 *               success: true
 *               data:
 *                 stepId: 1
 *                 isCompleted: true
 *                 progressPercent: 33
 *
 * /ai/smart-match:
 *   post:
 *     summary: AI recommends best-matched experts for a challenge
 *     tags: [AI]
 *     requestBody:
 *       content:
 *         application/json:
 *           schema:
 *             type: object
 *             properties:
 *               challenge:
 *                 type: string
 *                 example: I need help optimizing my MySQL queries for a high-traffic app
 *               skills:
 *                 type: array
 *                 items:
 *                   type: string
 *     responses:
 *       200:
 *         description: Matched expert recommendations
 *
 * /ai/analyze-challenge:
 *   post:
 *     summary: Analyze a technical challenge using AI
 *     tags: [AI]
 *     requestBody:
 *       content:
 *         application/json:
 *           schema:
 *             type: object
 *             properties:
 *               challenge:
 *                 type: string
 *     responses:
 *       200:
 *         description: Analysis result
 *
 * /ai/profile-optimizer:
 *   post:
 *     summary: AI suggestions to optimize expert profile (expert only)
 *     tags: [AI]
 *     security:
 *       - bearerAuth: []
 *     responses:
 *       200:
 *         description: Profile optimization suggestions
 */

router.get('/', authMiddleware, getMyRoadmap);
router.post('/generate', authMiddleware, generateRoadmap);
router.patch('/steps/:id', authMiddleware, updateRoadmapStep);

router.post('/smart-match', smartMatch);
router.post('/analyze-challenge', analyzeChallenge);
router.post('/profile-optimizer', authMiddleware, roleMiddleware(['expert']), optimizeProfile);

export default router;
