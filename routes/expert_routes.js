
import express from 'express';
import { getExperts, getExpertById, registerExpert, updateExpert, searchExperts, getExpertReviews, updateExpertAvailability } from '../controllers/expert_controller.js';
import { authMiddleware, roleMiddleware } from '../middleware/auth.js';
import upload from '../middleware/upload.js';
import Expert from '../models/Expert.js';

const router = express.Router();

router.get('/', getExperts);
router.get('/search', searchExperts);
router.get('/:id', getExpertById);
router.get('/:id/reviews', getExpertReviews);

// Protected routes
router.post('/register', authMiddleware, registerExpert);
router.put('/:id', authMiddleware, roleMiddleware(['expert', 'admin']), updateExpert);
router.post('/:id/availability', authMiddleware, roleMiddleware(['expert']), updateExpertAvailability);

// Document upload for verification
router.post('/:id/upload-documents', authMiddleware, roleMiddleware(['expert']), upload.array('verificationDocuments', 5), async (req, res) => {
  try {
    const expert = await Expert.findOne({ _id: req.params.id, userId: req.user._id });
    if (!expert) return res.status(404).json({ message: 'Expert not found or unauthorized' });

    const paths = req.files.map(file => file.path);
    expert.verificationDocuments.push(...paths);
    await expert.save();

    res.json({ message: 'Documents uploaded successfully', documents: expert.verificationDocuments });
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
});

export default router;
