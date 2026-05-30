import express from 'express';
import { register, login, logout, refreshToken, forgotPassword, resetPassword, getMe, updateMe } from '../controllers/auth_controller.js';
import { authMiddleware } from '../middleware/auth.js';

const router = express.Router();

/**
 * @swagger
 * tags:
 *   - name: Auth
 *     description: Authentication & session management
 *   - name: Users
 *     description: User profile management
 *
 * /auth/register:
 *   post:
 *     summary: Register a new user (learner or expert)
 *     tags: [Auth]
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             type: object
 *             required: [name, email, password, role]
 *             properties:
 *               name:
 *                 type: string
 *                 example: Rohan Kumar
 *               email:
 *                 type: string
 *                 example: rohan@gmail.com
 *               phone:
 *                 type: string
 *                 example: "9876543210"
 *               password:
 *                 type: string
 *                 example: SecurePass@123
 *               role:
 *                 type: string
 *                 enum: [learner, expert]
 *                 example: learner
 *     responses:
 *       201:
 *         description: User registered successfully
 *         content:
 *           application/json:
 *             example:
 *               success: true
 *               data:
 *                 user: { id: 1, name: Rohan Kumar, email: rohan@gmail.com, role: learner }
 *                 token: eyJhbGci...
 *                 refreshToken: eyJhbGci...
 *       409:
 *         description: Email already registered
 *
 * /auth/login:
 *   post:
 *     summary: Login with email and password, receive JWT tokens
 *     tags: [Auth]
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             type: object
 *             required: [email, password]
 *             properties:
 *               email:
 *                 type: string
 *                 example: rohan@gmail.com
 *               password:
 *                 type: string
 *                 example: SecurePass@123
 *     responses:
 *       200:
 *         description: Login successful
 *         content:
 *           application/json:
 *             example:
 *               success: true
 *               data:
 *                 user: { id: 1, name: Rohan Kumar, role: learner }
 *                 token: eyJhbGci...
 *                 refreshToken: eyJhbGci...
 *       401:
 *         description: Invalid credentials
 *
 * /auth/logout:
 *   post:
 *     summary: Logout and invalidate session
 *     tags: [Auth]
 *     security:
 *       - bearerAuth: []
 *     responses:
 *       200:
 *         description: Logged out successfully
 *
 * /auth/refresh-token:
 *   post:
 *     summary: Get new access token using refresh token
 *     tags: [Auth]
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             type: object
 *             required: [refreshToken]
 *             properties:
 *               refreshToken:
 *                 type: string
 *                 example: eyJhbGci...
 *     responses:
 *       200:
 *         description: New tokens issued
 *       401:
 *         description: Invalid or expired refresh token
 *
 * /auth/forgot-password:
 *   post:
 *     summary: Send 6-digit OTP to email for password reset
 *     tags: [Auth]
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             type: object
 *             required: [email]
 *             properties:
 *               email:
 *                 type: string
 *                 example: rohan@gmail.com
 *     responses:
 *       200:
 *         description: OTP sent to email
 *       404:
 *         description: Email not found
 *
 * /auth/reset-password:
 *   post:
 *     summary: Reset password using the OTP received on email
 *     tags: [Auth]
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             type: object
 *             required: [email, otp, newPassword]
 *             properties:
 *               email:
 *                 type: string
 *                 example: rohan@gmail.com
 *               otp:
 *                 type: string
 *                 example: "482910"
 *               newPassword:
 *                 type: string
 *                 example: NewPass@456
 *     responses:
 *       200:
 *         description: Password reset successful
 *
 * /users/me:
 *   get:
 *     summary: Get current logged-in user profile
 *     tags: [Users]
 *     security:
 *       - bearerAuth: []
 *     responses:
 *       200:
 *         description: User profile data
 *         content:
 *           application/json:
 *             example:
 *               success: true
 *               data:
 *                 id: 1
 *                 name: Rohan Kumar
 *                 email: rohan@gmail.com
 *                 role: learner
 *                 bio: Flutter enthusiast
 *                 totalSessions: 8
 *   put:
 *     summary: Update profile (name, bio, avatar, phone)
 *     tags: [Users]
 *     security:
 *       - bearerAuth: []
 *     requestBody:
 *       content:
 *         application/json:
 *           schema:
 *             type: object
 *             properties:
 *               name:
 *                 type: string
 *               bio:
 *                 type: string
 *               phone:
 *                 type: string
 *               avatar:
 *                 type: string
 *     responses:
 *       200:
 *         description: Profile updated successfully
 */

router.post('/register', register);
router.post('/login', login);
router.post('/logout', authMiddleware, logout);
router.post('/refresh-token', refreshToken);
router.post('/forgot-password', forgotPassword);
router.post('/reset-password', resetPassword);
router.get('/me', authMiddleware, getMe);
router.put('/me', authMiddleware, updateMe);

export default router;
