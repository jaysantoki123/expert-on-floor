
import User from '../models/User.js';
import Expert from '../models/Expert.js';
import Booking from '../models/Booking.js';
import Payment from '../models/Payment.js';
import Contact from '../models/Contact.js';
import BlogPost from '../models/BlogPost.js';
import CaseStudy from '../models/CaseStudy.js';
import Certificate from '../models/Certificate.js';
import fs from 'fs';
import path from 'path';

// GET /admin/users - List all users
export const getUsers = async (req, res) => {
  try {
    const users = await User.find().select('-password');
    res.json(users);
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};

// PUT /admin/users/:id/role - Update user role
export const updateUserRole = async (req, res) => {
  try {
    const { role } = req.body;
    const user = await User.findByIdAndUpdate(req.params.id, { role }, { new: true });
    if (!user) return res.status(404).json({ message: 'User not found' });
    res.json(user);
  } catch (error) {
    res.status(400).json({ message: error.message });
  }
};

// GET /admin/experts - List all experts with verification status
export const getAllExperts = async (req, res) => {
  try {
    const experts = await Expert.find().populate('userId', 'fullName profileImage email');
    res.json(experts);
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};

// POST /experts/:id/verify - Submit documents for verification (admin)
export const verifyExpert = async (req, res) => {
  try {
    const { status, message } = req.body; // 'verified' or 'rejected'
    const expert = await Expert.findByIdAndUpdate(req.params.id, { verificationStatus: status }, { new: true });
    if (!expert) return res.status(404).json({ message: 'Expert not found' });
    
    // Optionally send email to expert about verification status
    
    res.json(expert);
  } catch (error) {
    res.status(400).json({ message: error.message });
  }
};

// POST /admin/experts/:id/certificate - Issue certificate to expert
export const issueCertificate = async (req, res) => {
  try {
    const { title, description, expiryDate } = req.body;
    const certificateId = 'CERT-' + Date.now();
    const newCertificate = new Certificate({
      expertId: req.params.id,
      issuedBy: req.user._id,
      title,
      description,
      expiryDate,
      certificateId,
      fileUrl: req.file ? req.file.path : null
    });
    await newCertificate.save();
    res.status(201).json(newCertificate);
  } catch (error) {
    res.status(400).json({ message: error.message });
  }
};

// GET /admin/experts/:id/documents - Get expert's verification folder/documents
export const getExpertDocuments = async (req, res) => {
  try {
    const expert = await Expert.findById(req.params.id);
    if (!expert) return res.status(404).json({ message: 'Expert not found' });
    res.json({ 
      documents: expert.verificationDocuments,
      certificates: await Certificate.find({ expertId: expert._id })
    });
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};

// DELETE /admin/experts/:id/documents/:filename - Delete a specific document
export const deleteExpertDocument = async (req, res) => {
  try {
    const expert = await Expert.findById(req.params.id);
    if (!expert) return res.status(404).json({ message: 'Expert not found' });

    const filename = req.params.filename;
    const docIndex = expert.verificationDocuments.findIndex(doc => doc.includes(filename));

    if (docIndex === -1) return res.status(404).json({ message: 'Document not found' });

    // Remove from database
    const docPath = expert.verificationDocuments[docIndex];
    expert.verificationDocuments.splice(docIndex, 1);
    await expert.save();

    // Remove from disk
    if (fs.existsSync(docPath)) {
      fs.unlinkSync(docPath);
    }

    res.json({ message: 'Document deleted successfully' });
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};

// GET /admin/bookings - List all bookings
export const getAllBookings = async (req, res) => {
  try {
    const bookings = await Booking.find()
      .populate('clientId', 'fullName profileImage')
      .populate({
        path: 'expertId',
        populate: { path: 'userId', select: 'fullName profileImage' }
      });
    res.json(bookings);
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};

// GET /admin/payments - List all payments
export const getAllPayments = async (req, res) => {
  try {
    const payments = await Payment.find().populate('userId', 'fullName email').populate('bookingId');
    res.json(payments);
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};

// POST /payments/:id/refund - Initiate refund
export const refundPayment = async (req, res) => {
  try {
    // Razorpay refund logic would go here
    const payment = await Payment.findByIdAndUpdate(req.params.id, { status: 'failed' }, { new: true });
    if (!payment) return res.status(404).json({ message: 'Payment not found' });
    res.json(payment);
  } catch (error) {
    res.status(400).json({ message: error.message });
  }
};

// GET /admin/contacts - Get contact messages
export const getContacts = async (req, res) => {
  try {
    const contacts = await Contact.find();
    res.json(contacts);
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};

// PUT /admin/contacts/:id/resolve - Mark contact as resolved
export const resolveContact = async (req, res) => {
  try {
    const contact = await Contact.findByIdAndUpdate(req.params.id, { isResolved: true }, { new: true });
    if (!contact) return res.status(404).json({ message: 'Contact not found' });
    res.json(contact);
  } catch (error) {
    res.status(400).json({ message: error.message });
  }
};

// POST /admin/blog - Create blog post
export const createBlogPost = async (req, res) => {
  try {
    const newBlogPost = new BlogPost(req.body);
    await newBlogPost.save();
    res.status(201).json(newBlogPost);
  } catch (error) {
    res.status(400).json({ message: error.message });
  }
};

// POST /admin/case-studies - Create case study
export const createCaseStudy = async (req, res) => {
  try {
    const newCaseStudy = new CaseStudy(req.body);
    await newCaseStudy.save();
    res.status(201).json(newCaseStudy);
  } catch (error) {
    res.status(400).json({ message: error.message });
  }
};
