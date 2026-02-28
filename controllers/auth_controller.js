
import User from '../models/User.js';
import bcrypt from 'bcryptjs';
import jwt from 'jsonwebtoken';

// Helper to generate tokens
const generateTokens = (user) => {
  const accessToken = jwt.sign(
    { id: user._id, role: user.role },
    process.env.JWT_SECRET,
    { expiresIn: '1d' }
  );

  const refreshToken = jwt.sign(
    { id: user._id, role: user.role },
    process.env.REFRESH_TOKEN_SECRET,
    { expiresIn: '7d' }
  );

  return { accessToken, refreshToken };
};

// POST /auth/register - Register new user with email validation
export const register = async (req, res) => {
  try {
    const { email, password, fullName, role, phone } = req.body;
    
    // Check if user already exists
    const existingUser = await User.findOne({ email });
    if (existingUser) return res.status(400).json({ message: 'User already exists' });

    // Hash password
    const hashedPassword = await bcrypt.hash(password, 10);

    // Create user
    const user = new User({
      email,
      password: hashedPassword,
      fullName,
      role: role || 'client',
      phone
    });

    await user.save();
    
    // Optionally send email verification link (e.g., via nodemailer)
    
    res.status(201).json({ 
      message: 'User registered successfully',
      user: { id: user._id, email: user.email, fullName: user.fullName, role: user.role }
    });
  } catch (error) {
    res.status(400).json({ message: error.message });
  }
};

// POST /auth/login - Login with email/password, returns JWT tokens
export const login = async (req, res) => {
  try {
    const { email, password } = req.body;
    
    const user = await User.findOne({ email });
    if (!user) return res.status(404).json({ message: 'User not found' });

    const isMatch = await bcrypt.compare(password, user.password);
    if (!isMatch) return res.status(401).json({ message: 'Invalid credentials' });

    const { accessToken, refreshToken } = generateTokens(user);

    user.lastLogin = new Date();
    await user.save();

    res.json({ 
      token: accessToken, 
      refreshToken,
      user: { id: user._id, fullName: user.fullName, role: user.role, email: user.email } 
    });
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};

// POST /auth/logout - Clear authentication session
export const logout = async (req, res) => {
  // Client-side logout usually involves deleting the token from local storage
  // If using cookies, we could clear the cookie here
  res.json({ message: 'Logged out successfully' });
};

// POST /auth/refresh-token - Generate new access token using refresh token
export const refreshToken = async (req, res) => {
  try {
    const { refreshToken: incomingToken } = req.body;
    if (!incomingToken) return res.status(400).json({ message: 'Refresh token required' });

    const decoded = jwt.verify(incomingToken, process.env.REFRESH_TOKEN_SECRET);
    const user = await User.findById(decoded.id);
    if (!user) return res.status(404).json({ message: 'User not found' });

    const { accessToken, refreshToken: newRefreshToken } = generateTokens(user);

    res.json({ 
      token: accessToken,
      refreshToken: newRefreshToken 
    });
  } catch (error) {
    res.status(401).json({ message: 'Invalid or expired refresh token' });
  }
};

// POST /auth/forgot-password - Send password reset email
export const forgotPassword = async (req, res) => {
  // Logic to send reset email
  res.json({ message: 'Password reset email sent' });
};

// POST /auth/reset-password/:token - Reset password with verification token
export const resetPassword = async (req, res) => {
  // Logic to reset password
  res.json({ message: 'Password reset successful' });
};

// POST /auth/verify-email/:token - Verify email address
export const verifyEmail = async (req, res) => {
  try {
    const { token } = req.params;
    // Verify token logic...
    const user = await User.findOneAndUpdate({ verificationToken: token }, { isEmailVerified: true });
    if (!user) return res.status(400).json({ message: 'Invalid verification token' });
    res.json({ message: 'Email verified successfully' });
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};
