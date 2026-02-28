import express from 'express';
import { smartMatch, optimizeProfile, analyzeChallenge } from '../controllers/ai_controller.js';
import { authMiddleware, roleMiddleware } from '../middleware/auth.js';

const router = express.Router();

// Publicly available AI features
router.post('/smart-match', smartMatch);
router.post('/analyze-challenge', analyzeChallenge);

// Expert-only AI features
router.post('/optimize-profile', authMiddleware, roleMiddleware(['expert']), optimizeProfile);

export default router;
