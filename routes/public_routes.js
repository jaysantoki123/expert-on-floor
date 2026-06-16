import express from 'express';
import { getExpertise } from '../controllers/expertise_controller.js';
import { getBlogPosts, getBlogPostBySlug, getCaseStudies, getCaseStudyBySlug } from '../controllers/content_controller.js';

const router = express.Router();

// Expertise
router.get('/expertise', getExpertise);

// Blog
router.get('/blog', getBlogPosts);
router.get('/blog/:slug', getBlogPostBySlug);

// Case Studies
router.get('/case-studies', getCaseStudies);
router.get('/case-studies/:slug', getCaseStudyBySlug);

export default router;
