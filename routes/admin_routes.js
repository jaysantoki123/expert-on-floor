
import express from 'express';
import { 
  getUsers, 
  updateUserRole, 
  getAllExperts, 
  verifyExpert, 
  getAllBookings, 
  getAllPayments, 
  refundPayment, 
  getContacts, 
  resolveContact, 
  createBlogPost, 
  createCaseStudy,
  issueCertificate,
  getExpertDocuments,
  deleteExpertDocument
} from '../controllers/admin_controller.js';
import { createExpertise, updateExpertise, deleteExpertise } from '../controllers/expertise_controller.js';
import { authMiddleware, roleMiddleware } from '../middleware/auth.js';
import upload from '../middleware/upload.js';

const router = express.Router();

// All routes here require admin role
router.use(authMiddleware, roleMiddleware(['admin']));

router.get('/users', getUsers);
router.put('/users/:id/role', updateUserRole);

router.get('/experts', getAllExperts);
router.post('/experts/:id/verify', verifyExpert);

// Certificate & Document Folder Management
router.post('/experts/:id/certificate', upload.single('certificate'), issueCertificate);
router.get('/experts/:id/documents', getExpertDocuments);
router.delete('/experts/:id/documents/:filename', deleteExpertDocument);

// Expertise management
router.post('/expertise', createExpertise);
router.put('/expertise/:id', updateExpertise);
router.delete('/expertise/:id', deleteExpertise);

router.get('/bookings', getAllBookings);

router.get('/payments', getAllPayments);
router.post('/payments/:id/refund', refundPayment);

router.get('/contacts', getContacts);
router.put('/contacts/:id/resolve', resolveContact);

router.post('/blog', createBlogPost);
router.post('/case-studies', createCaseStudy);

export default router;
