
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
    const users = await User.findAll({ attributes: { exclude: ['password'] } });
    res.json(users);
  } catch (error) {
    res.status(500).json({ message: 'An internal error occurred' });
  }
};

// PUT /admin/users/:id/role - Update user role
export const updateUserRole = async (req, res) => {
  try {
    const { role } = req.body;
    const user = await User.findByPk(req.params.id);
    if (!user) return res.status(404).json({ message: 'User not found' });
    user.role = role;
    await user.save();
    res.json(user);
  } catch (error) {
    res.status(400).json({ message: 'An internal error occurred' });
  }
};

// GET /admin/experts - List all experts with verification status
export const getAllExperts = async (req, res) => {
  try {
    const experts = await Expert.findAll({
      include: [{ model: User, as: 'user', attributes: ['name', 'profileImage', 'email'] }]
    });
    res.json(experts);
  } catch (error) {
    res.status(500).json({ message: 'An internal error occurred' });
  }
};

// POST /experts/:id/verify - Submit documents for verification (admin)
export const verifyExpert = async (req, res) => {
  try {
    const { status, message } = req.body; // 'verified' or 'rejected'
    const expert = await Expert.findByPk(req.params.id);
    if (!expert) return res.status(404).json({ message: 'Expert not found' });
    expert.verificationStatus = status;
    await expert.save();
    
    // Optionally send email to expert about verification status
    
    res.json(expert);
  } catch (error) {
    res.status(400).json({ message: 'An internal error occurred' });
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
    res.status(400).json({ message: 'An internal error occurred' });
  }
};

// GET /admin/experts/:id/documents - Get expert's verification folder/documents
export const getExpertDocuments = async (req, res) => {
  try {
    const expert = await Expert.findByPk(req.params.id);
    if (!expert) return res.status(404).json({ message: 'Expert not found' });
    res.json({ 
      documents: expert.verificationDocuments,
      certificates: await Certificate.find({ expertId: expert.id })
    });
  } catch (error) {
    res.status(500).json({ message: 'An internal error occurred' });
  }
};

// DELETE /admin/experts/:id/documents/:filename - Delete a specific document
export const deleteExpertDocument = async (req, res) => {
  try {
    const expert = await Expert.findByPk(req.params.id);
    if (!expert) return res.status(404).json({ message: 'Expert not found' });

    const filename = req.params.filename;
    let docs = expert.verificationDocuments || [];
    const docIndex = docs.findIndex(doc => doc.includes(filename));

    if (docIndex === -1) return res.status(404).json({ message: 'Document not found' });

    // Remove from database
    const docPath = docs[docIndex];
    docs.splice(docIndex, 1);
    expert.verificationDocuments = docs;
    await expert.save();

    // Remove from disk
    if (fs.existsSync(docPath)) {
      fs.unlink(docPath, (err) => err && console.error('Failed to unlink document:', err));
    }

    res.json({ message: 'Document deleted successfully' });
  } catch (error) {
    res.status(500).json({ message: 'An internal error occurred' });
  }
};

// GET /admin/bookings - List all bookings
export const getAllBookings = async (req, res) => {
  try {
    const bookings = await Booking.findAll({
      include: [
        { model: User, as: 'learner', attributes: ['name', 'profileImage'] },
        { 
          model: User, 
          as: 'expert', 
          attributes: ['name', 'profileImage']
        }
      ]
    });
    res.json(bookings);
  } catch (error) {
    res.status(500).json({ message: 'An internal error occurred' });
  }
};

// GET /admin/payments - List all payments
export const getAllPayments = async (req, res) => {
  try {
    const payments = await Payment.findAll({
      include: [
        { model: User, as: 'user', attributes: ['name', 'email'] },
        { model: Booking, as: 'booking' }
      ]
    });
    res.json(payments);
  } catch (error) {
    res.status(500).json({ message: 'An internal error occurred' });
  }
};

// POST /payments/:id/refund - Initiate refund
export const refundPayment = async (req, res) => {
  try {
    // Razorpay refund logic would go here
    const payment = await Payment.findByPk(req.params.id);
    if (!payment) return res.status(404).json({ message: 'Payment not found' });
    payment.status = 'failed';
    await payment.save();
    res.json(payment);
  } catch (error) {
    res.status(400).json({ message: 'An internal error occurred' });
  }
};

// GET /admin/contacts - Get contact messages
export const getContacts = async (req, res) => {
  try {
    const contacts = await Contact.find();
    res.json(contacts);
  } catch (error) {
    res.status(500).json({ message: 'An internal error occurred' });
  }
};

// PUT /admin/contacts/:id/resolve - Mark contact as resolved
export const resolveContact = async (req, res) => {
  try {
    const contact = await Contact.findByIdAndUpdate(req.params.id, { isResolved: true }, { new: true });
    if (!contact) return res.status(404).json({ message: 'Contact not found' });
    res.json(contact);
  } catch (error) {
    res.status(400).json({ message: 'An internal error occurred' });
  }
};

// POST /admin/blog - Create blog post
export const createBlogPost = async (req, res) => {
  try {
    const newBlogPost = new BlogPost(req.body);
    await newBlogPost.save();
    res.status(201).json(newBlogPost);
  } catch (error) {
    res.status(400).json({ message: 'An internal error occurred' });
  }
};

// POST /admin/case-studies - Create case study
export const createCaseStudy = async (req, res) => {
  try {
    const newCaseStudy = new CaseStudy(req.body);
    await newCaseStudy.save();
    res.status(201).json(newCaseStudy);
  } catch (error) {
    res.status(400).json({ message: 'An internal error occurred' });
  }
};
