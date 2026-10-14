import multer from 'multer';
import path from 'path';
import fs from 'fs';

// Set up storage
const storage = multer.diskStorage({
  destination: (req, file, cb) => {
    let folder = 'uploads/';
    if (file.fieldname === 'profileImage') {
      folder += 'profiles/';
    } else if (file.fieldname === 'verificationDocuments' || file.fieldname === 'certificate') {
      folder += 'experts/';
    }
    
    // Ensure folder exists
    if (!fs.existsSync(folder)) {
      fs.mkdirSync(folder, { recursive: true });
    }
    
    cb(null, folder);
  },
  filename: (req, file, cb) => {
    const extMap = {
      'image/jpeg': '.jpg',
      'image/png': '.png',
      'application/pdf': '.pdf'
    };
    const safeExt = extMap[file.mimetype] || '.bin';
    const uniqueSuffix = Date.now() + '-' + Math.round(Math.random() * 1E9);
    cb(null, file.fieldname + '-' + uniqueSuffix + safeExt);
  }
});

// File filter (e.g., only images/pdfs)
const fileFilter = (req, file, cb) => {
  const allowedTypes = ['image/jpeg', 'image/png', 'application/pdf'];
  if (allowedTypes.includes(file.mimetype)) {
    cb(null, true);
  } else {
    cb(new Error('Only JPEG, PNG, and PDF files are allowed!'), false);
  }
};

const upload = multer({ 
  storage: storage,
  fileFilter: fileFilter,
  limits: { fileSize: 5 * 1024 * 1024 } // 5MB limit
});

export const validateMagicBytes = (req, res, next) => {
  if (!req.file) return next();

  try {
    const buffer = Buffer.alloc(8);
    const fd = fs.openSync(req.file.path, 'r');
    fs.readSync(fd, buffer, 0, 8, 0);
    fs.closeSync(fd);
    
    const hex = buffer.toString('hex').toUpperCase();
    let valid = false;
    
   
    if (hex.startsWith('FFD8FF') && req.file.mimetype === 'image/jpeg') valid = true;
   
    if (hex.startsWith('89504E470D0A1A0A') && req.file.mimetype === 'image/png') valid = true;
   
    if (hex.startsWith('255044462D') && req.file.mimetype === 'application/pdf') valid = true;

    if (!valid) {
      fs.unlink(req.file.path, (err) => err && console.error('Failed to unlink invalid file:', err));
      return res.status(400).json({ success: false, message: 'Invalid file content (magic byte mismatch). Possible spoofed file.' });
    }
    next();
  } catch (error) {
    if (req.file && fs.existsSync(req.file.path)) {
      fs.unlink(req.file.path, (err) => err && console.error('Failed to unlink invalid file:', err));
    }
    return res.status(500).json({ success: false, message: 'File validation failed.' });
  }
};

export default upload;
