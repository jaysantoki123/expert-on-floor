import { User, sequelize } from '../models/index.js';
import bcrypt from 'bcryptjs';
import jwt from 'jsonwebtoken';
import crypto from 'crypto';
import { OAuth2Client } from 'google-auth-library';
import nodemailer from 'nodemailer';
import xss from 'xss';

const client = new OAuth2Client(process.env.GOOGLE_CLIENT_ID);


const otpStore = new Map();

const OTP_EXPIRY_MS = 10 * 60 * 1000;

const SELF_ASSIGNABLE_ROLES = ['learner', 'expert'];

const hashToken = (token) => crypto.createHash('sha256').update(token).digest('hex');

const escapeHtml = (str) => String(str)
  .replace(/&/g, '&amp;')
  .replace(/</g, '&lt;')
  .replace(/>/g, '&gt;')
  .replace(/"/g, '&quot;')
  .replace(/'/g, '&#39;');

if (!process.env.JWT_SECRET) {
  throw new Error('FATAL: JWT_SECRET environment variable is not set');
}
if (!process.env.REFRESH_TOKEN_SECRET) {
  throw new Error('FATAL: REFRESH_TOKEN_SECRET environment variable is not set');
}

const generateOtp = () => Math.floor(100000 + Math.random() * 900000).toString();


const validatePasswordStrength = (password) => {
  if (!password || typeof password !== 'string') {
    return 'Password is required';
  }
  if (password.length < 8) {
    return 'Password must be at least 8 characters long';
  }
  if (!/[A-Z]/.test(password)) {
    return 'Password must include at least one uppercase letter';
  }
  if (!/[a-z]/.test(password)) {
    return 'Password must include at least one lowercase letter';
  }
  if (!/[0-9]/.test(password)) {
    return 'Password must include at least one number';
  }
  if (!/[!@#$%^&*(),.?":{}|<>_\-+=\[\];'`~\\]/.test(password)) {
    return 'Password must include at least one special character';
  }
  return null;
};


const createMailTransporter = () => nodemailer.createTransport({
  host: process.env.MAIL_HOST || 'smtp.gmail.com',
  port: parseInt(process.env.MAIL_PORT || '587'),
  secure: false,
  auth: {
    user: process.env.MAIL_USER,
    pass: process.env.MAIL_PASS,
  },
});


const generateTokens = (user) => {
  const accessToken = jwt.sign(
    { id: user.id },
    process.env.JWT_SECRET,
    { expiresIn: '15m' }
  );

  const refreshToken = jwt.sign(
    { id: user.id },
    process.env.REFRESH_TOKEN_SECRET,
    { expiresIn: '30d' }
  );

  return { accessToken, refreshToken };
};

export const register = async (req, res) => {
  console.log('Register called with:', req.body.email);
  try {
    const { name, email, phone, password, confirmPassword, role } = req.body;

    if (!confirmPassword) {
      return res.status(400).json({ success: false, message: 'Confirm password is required' });
    }
    if (password !== confirmPassword) {
      return res.status(400).json({ success: false, message: 'Passwords do not match' });
    }

    if (role && !SELF_ASSIGNABLE_ROLES.includes(role)) {
      return res.status(403).json({ success: false, message: `Role '${role}' cannot be self-assigned` });
    }

    const passwordError = validatePasswordStrength(password);
    if (passwordError) {
      return res.status(400).json({ success: false, message: passwordError });
    }

    const existingUser = await User.findOne({ where: { email } });
    if (existingUser) return res.status(409).json({ success: false, message: 'User already exists' });

    const hashedPassword = await bcrypt.hash(password, 10);

    // Atomic: User.create + refreshToken save must both succeed or both roll back.
    // Prevents orphaned user rows with no usable refresh token.
    const { user, accessToken, refreshToken } = await sequelize.transaction(async (t) => {
      const user = await User.create({
        email,
        password: hashedPassword,
        name,
        role: SELF_ASSIGNABLE_ROLES.includes(role) ? role : 'learner',
        phone
      }, { transaction: t });

      const { accessToken, refreshToken } = generateTokens(user);
      user.refreshToken = hashToken(refreshToken);
      await user.save({ transaction: t });

      return { user, accessToken, refreshToken };
    });

    res.status(201).json({ 
      success: true,
      data: {
        user: { id: user.id, name: user.name, email: user.email, role: user.role },
        token: accessToken,
        refreshToken
      }
    });
  } catch (error) {
    console.error('register error:', error);
    res.status(400).json({ success: false, message: 'Registration failed' });
  }
};

export const login = async (req, res) => {
  try {
    const { email, password } = req.body;
    
    const user = await User.findOne({ where: { email } });
    if (!user) return res.status(404).json({ success: false, message: 'User not found' });

    const isMatch = await bcrypt.compare(password, user.password);
    if (!isMatch) return res.status(401).json({ success: false, message: 'Invalid credentials' });

    const { accessToken, refreshToken } = generateTokens(user);

    user.refreshToken = hashToken(refreshToken);
    user.lastLogin = new Date();
    await user.save();

    res.json({ 
      success: true,
      data: {
        user: { 
          id: user.id, 
          name: user.name, 
          email: user.email, 
          phone: user.phone, 
          role: user.role,
          profileImage: user.profileImage
        },
        token: accessToken, 
        refreshToken
      }
    });
  } catch (error) {
    console.error('login error:', error);
    res.status(500).json({ success: false, message: 'An internal error occurred' });
  }
};

export const googleLogin = async (req, res) => {
  try {
    const { token, role } = req.body; // Token from Google, role optional for new users
    if (!token) return res.status(400).json({ success: false, message: 'Token required' });

    const ticket = await client.verifyIdToken({
      idToken: token,
      audience: process.env.GOOGLE_CLIENT_ID,
    });
    const payload = ticket.getPayload();
    const { email, name, picture } = payload;

    let user = await User.findOne({ where: { email } });
    
    if (!user) {
      // Create new user if not exists
      // Silently ignore privileged roles — default to 'learner'
      const safeRole = SELF_ASSIGNABLE_ROLES.includes(role) ? role : 'learner';
      user = await User.create({
        email,
        name,
        role: safeRole,
        profileImage: picture,
        password: await bcrypt.hash(Math.random().toString(36).slice(-8), 10), // Random password
        isEmailVerified: true
      });
    }

    const { accessToken, refreshToken } = generateTokens(user);

    user.refreshToken = hashToken(refreshToken);
    user.lastLogin = new Date();
    await user.save();

    res.json({
      success: true,
      data: {
        user: { 
          id: user.id, 
          name: user.name, 
          email: user.email, 
          phone: user.phone, 
          role: user.role, 
          profileImage: user.profileImage 
        },
        token: accessToken,
        refreshToken
      }
    });
  } catch (error) {
    console.error('googleLogin error:', error);
    res.status(401).json({ success: false, message: 'Invalid Google token' });
  }
};

export const logout = async (req, res) => {
  try {
    const user = await User.findByPk(req.user.id);
    if (user) {
      user.refreshToken = null;
      await user.save();
    }
    res.json({ success: true, message: 'Logged out successfully' });
  } catch (error) {
    console.error('logout error:', error);
    res.status(500).json({ success: false, message: 'An internal error occurred' });
  }
};

export const refreshToken = async (req, res) => {
  try {
    const { refreshToken: incomingToken } = req.body;
    if (!incomingToken) return res.status(400).json({ success: false, message: 'Refresh token required' });

    const decoded = jwt.verify(incomingToken, process.env.REFRESH_TOKEN_SECRET);
    const user = await User.findByPk(decoded.id);
    if (!user || user.refreshToken !== hashToken(incomingToken)) {
      return res.status(401).json({ success: false, message: 'Invalid refresh token' });
    }

    const { accessToken, refreshToken: newRefreshToken } = generateTokens(user);
    user.refreshToken = hashToken(newRefreshToken);
    await user.save();

    res.json({ 
      success: true,
      data: {
        token: accessToken,
        refreshToken: newRefreshToken 
      }
    });
  } catch (error) {
    res.status(401).json({ success: false, message: 'Invalid or expired refresh token' });
  }
};

export const getMe = async (req, res) => {
  try {
    const user = await User.findByPk(req.user.id, {
      attributes: { exclude: ['password', 'refreshToken'] }
    });
    if (!user) return res.status(404).json({ success: false, message: 'User not found' });
    
    res.json({ success: true, data: user });
  } catch (error) {
    console.error('getMe error:', error);
    res.status(500).json({ success: false, message: 'An internal error occurred' });
  }
};

export const updateMe = async (req, res) => {
  try {
    const { name, bio, phone, avatar } = req.body;
    const user = await User.findByPk(req.user.id);
    if (!user) return res.status(404).json({ success: false, message: 'User not found' });
    
    if (name) user.name = xss(name);
    if (phone) user.phone = phone;
    if (avatar) user.profileImage = avatar;
    
    await user.save();
    res.json({ success: true, message: 'Profile updated', data: user });
  } catch (error) {
    console.error('updateMe error:', error);
    res.status(500).json({ success: false, message: 'An internal error occurred' });
  }
};

export const updateFCMToken = async (req, res) => {
  try {
    const { fcmToken } = req.body;
    if (!fcmToken) {
      return res.status(400).json({ success: false, message: 'fcmToken is required' });
    }

    const user = await User.findByPk(req.user.id);
    if (!user) return res.status(404).json({ success: false, message: 'User not found' });

    user.fcmToken = fcmToken;
    await user.save();

    res.json({ success: true, message: 'FCM token updated successfully' });
  } catch (error) {
    console.error('updateFCMToken error:', error);
    res.status(500).json({ success: false, message: 'An internal error occurred' });
  }
};

export const forgotPassword = async (req, res) => {
  try {
    const { email } = req.body;
    const user = await User.findOne({ where: { email } });
    if (!user) return res.status(404).json({ success: false, message: 'User not found' });

    // Generate and store OTP
    const otp = generateOtp();
    otpStore.set(email, { otp, expiresAt: Date.now() + OTP_EXPIRY_MS, attempts: 0 });

    // Send OTP email
    const transporter = createMailTransporter();
    await transporter.sendMail({
      from: `"Expert on Floor" <${process.env.MAIL_USER}>`,
      to: email,
      subject: 'Your Password Reset OTP',
      html: `
        <div style="font-family:Arial,sans-serif;max-width:480px;margin:auto;padding:32px;border:1px solid #e5e7eb;border-radius:12px">
          <h2 style="color:#0F9D58;margin-bottom:8px">Password Reset OTP</h2>
          <p style="color:#374151">Hi ${escapeHtml(user.name)},</p>
          <p style="color:#374151">Use the OTP below to reset your password. It expires in <strong>10 minutes</strong>.</p>
          <div style="font-size:36px;font-weight:800;letter-spacing:8px;color:#0F9D58;text-align:center;padding:20px 0">${otp}</div>
          <p style="color:#6b7280;font-size:13px">If you did not request a password reset, please ignore this email.</p>
        </div>
      `,
    });

    console.log(`✉️ OTP sent to ${email}`);
    res.json({ success: true, message: `OTP sent to ${email}` });
  } catch (error) {
    console.error('forgotPassword error:', error);
    res.status(500).json({ success: false, message: 'An internal error occurred' });
  }
};

export const verifyOtp = async (req, res) => {
  try {
    const { email, otp } = req.body;
    if (!email || !otp) {
      return res.status(400).json({ success: false, message: 'Email and OTP are required' });
    }

    const record = otpStore.get(email);
    if (!record) {
      return res.status(400).json({ success: false, message: 'No OTP requested for this email' });
    }
    if (Date.now() > record.expiresAt) {
      otpStore.delete(email);
      return res.status(400).json({ success: false, message: 'OTP has expired. Please request a new one.' });
    }

    if (record.otp !== otp.toString()) {
      record.attempts = (record.attempts || 0) + 1;
      if (record.attempts >= 5) {
        otpStore.delete(email);
        return res.status(429).json({ success: false, message: 'Too many failed attempts. OTP invalidated. Please request a new one.' });
      }
      return res.status(400).json({ success: false, message: `Invalid OTP. You have ${5 - record.attempts} attempts left.` });
    }

    // Mark OTP as verified (keep in store so resetPassword can confirm)
    record.verified = true;
    res.json({ success: true, message: 'OTP verified successfully' });
  } catch (error) {
    console.error('verifyOtp error:', error);
    res.status(500).json({ success: false, message: 'An internal error occurred' });
  }
};

export const resetPassword = async (req, res) => {
  try {
    const { email, otp, newPassword, confirmPassword } = req.body;

    if (!confirmPassword) {
      return res.status(400).json({ success: false, message: 'Confirm password is required' });
    }
    if (newPassword !== confirmPassword) {
      return res.status(400).json({ success: false, message: 'Passwords do not match' });
    }

    // Validate OTP
    const record = otpStore.get(email);
    if (!record) {
      return res.status(400).json({ success: false, message: 'No OTP requested for this email' });
    }
    if (Date.now() > record.expiresAt) {
      otpStore.delete(email);
      return res.status(400).json({ success: false, message: 'OTP has expired. Please request a new one.' });
    }

    if (record.otp !== otp.toString()) {
      record.attempts = (record.attempts || 0) + 1;
      if (record.attempts >= 5) {
        otpStore.delete(email);
        return res.status(429).json({ success: false, message: 'Too many failed attempts. OTP invalidated. Please request a new one.' });
      }
      return res.status(400).json({ success: false, message: `Invalid OTP. You have ${5 - record.attempts} attempts left.` });
    }

    const passwordError = validatePasswordStrength(newPassword);
    if (passwordError) {
      return res.status(400).json({ success: false, message: passwordError });
    }

    const user = await User.findOne({ where: { email } });
    if (!user) return res.status(404).json({ success: false, message: 'User not found' });

    user.password = await bcrypt.hash(newPassword, 10);
    await user.save();

    // Invalidate OTP after successful reset
    otpStore.delete(email);

    res.json({ success: true, message: 'Password reset successful' });
  } catch (error) {
    console.error('resetPassword error:', error);
    res.status(500).json({ success: false, message: 'An internal error occurred' });
  }
};

export const changePassword = async (req, res) => {
  try {
    const { currentPassword, newPassword, confirmPassword } = req.body;

    if (!confirmPassword) {
      return res.status(400).json({ success: false, message: 'Confirm password is required' });
    }
    if (newPassword !== confirmPassword) {
      return res.status(400).json({ success: false, message: 'Passwords do not match' });
    }

    const user = await User.findByPk(req.user.id);
    if (!user) return res.status(404).json({ success: false, message: 'User not found' });

    const isMatch = await bcrypt.compare(currentPassword, user.password);
    if (!isMatch) return res.status(400).json({ success: false, message: 'Incorrect current password' });

    const passwordError = validatePasswordStrength(newPassword);
    if (passwordError) {
      return res.status(400).json({ success: false, message: passwordError });
    }

    user.password = await bcrypt.hash(newPassword, 10);
    await user.save();

    res.json({ success: true, message: 'Password changed successfully' });
  } catch (error) {
    console.error('changePassword error:', error);
    res.status(500).json({ success: false, message: 'An internal error occurred' });
  }
};

