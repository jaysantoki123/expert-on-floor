import express from 'express';
import cors from 'cors';
import cookieParser from 'cookie-parser';
import dotenv from 'dotenv';

import authRoutes from './routes/auth_routes.js';
import expertRoutes from './routes/expert_routes.js';
import clientRoutes from './routes/client_routes.js';
import bookingRoutes from './routes/booking_routes.js';
import communityRoutes from './routes/community_routes.js';
import paymentRoutes from './routes/payment_routes.js';
import notificationRoutes from './routes/notification_routes.js';
import aiRoutes from './routes/ai_routes.js';
import chatRoutes from './routes/chat_routes.js';
import { syncDB } from './models/index.js';
import swaggerUi from 'swagger-ui-express';

dotenv.config();

// ──────────────────────────────────────────────
// SWAGGER SPEC (inline — avoids Windows glob issue)
// ──────────────────────────────────────────────
const swaggerSpec = {
  openapi: '3.0.0',
  info: {
    title: 'ExpertMentor API Documentation',
    version: '1.0.0',
    description: 'Complete backend API for ExpertMentor — connecting learners with industrial experts.\n\n**Base URL:** `/v1`\n\n**Auth:** `Authorization: Bearer <token>`',
  },
  servers: [
    { url: 'http://localhost:5000/v1', description: 'Local Dev' },
    { url: 'https://api.expertmentor.in/v1', description: 'Production' },
  ],
  components: {
    securitySchemes: {
      bearerAuth: { type: 'http', scheme: 'bearer', bearerFormat: 'JWT' },
    },
  },
  tags: [
    { name: 'Auth', description: 'Authentication & session management' },
    { name: 'Users', description: 'User profile management' },
    { name: 'Clients', description: 'Client & Learner dashboards and actions' },
    { name: 'Experts', description: 'Expert profiles, search, reviews & availability' },
    { name: 'Bookings', description: 'Session booking management' },
    { name: 'Chat', description: 'Conversations & messaging (REST + Socket.io)' },
    { name: 'Community', description: 'Community Q&A forum' },
    { name: 'Payments', description: 'Razorpay payment integration' },
    { name: 'Roadmap', description: 'AI-powered career roadmap generation' },
    { name: 'AI', description: 'AI Smart Match & analysis features' },
    { name: 'Notifications', description: 'User notification system' },
  ],
  paths: {
    // ── AUTH ──────────────────────────────────
    '/auth/register': {
      post: {
        tags: ['Auth'],
        summary: 'Register a new user (learner or expert)',
        requestBody: {
          required: true,
          content: {
            'application/json': {
              schema: {
                type: 'object',
                required: ['name', 'email', 'password', 'role'],
                properties: {
                  name: { type: 'string', example: 'Rohan Kumar' },
                  email: { type: 'string', example: 'rohan@gmail.com' },
                  phone: { type: 'string', example: '9876543210' },
                  password: { type: 'string', example: 'SecurePass@123' },
                  role: { type: 'string', enum: ['learner', 'expert'], example: 'learner' },
                },
              },
            },
          },
        },
        responses: {
          201: { description: 'User registered successfully' },
          409: { description: 'Email already registered' },
        },
      },
    },
    '/auth/login': {
      post: {
        tags: ['Auth'],
        summary: 'Login with email and password, receive JWT tokens',
        requestBody: {
          required: true,
          content: {
            'application/json': {
              schema: {
                type: 'object',
                required: ['email', 'password'],
                properties: {
                  email: { type: 'string', example: 'rohan@gmail.com' },
                  password: { type: 'string', example: 'SecurePass@123' },
                },
              },
            },
          },
        },
        responses: {
          200: { description: 'Login successful, returns token + refreshToken' },
          401: { description: 'Invalid credentials' },
        },
      },
    },
    '/auth/google': {
      post: {
        tags: ['Auth'],
        summary: 'Login or register with Google ID token',
        requestBody: {
          required: true,
          content: {
            'application/json': {
              schema: {
                type: 'object',
                required: ['token'],
                properties: {
                  token: { type: 'string', description: 'The ID token from Google' },
                  role: { type: 'string', enum: ['learner', 'expert'], description: 'Role to assign if user is new' },
                },
              },
            },
          },
        },
        responses: {
          200: { description: 'Google login successful, returns user data and tokens' },
          401: { description: 'Invalid Google token' },
        },
      },
    },
    '/auth/logout': {
      post: {
        tags: ['Auth'],
        summary: 'Logout and invalidate current session',
        security: [{ bearerAuth: [] }],
        responses: { 200: { description: 'Logged out successfully' } },
      },
    },
    '/auth/refresh-token': {
      post: {
        tags: ['Auth'],
        summary: 'Get new access token using refresh token',
        requestBody: {
          required: true,
          content: {
            'application/json': {
              schema: {
                type: 'object',
                required: ['refreshToken'],
                properties: { refreshToken: { type: 'string', example: 'eyJhbGci...' } },
              },
            },
          },
        },
        responses: {
          200: { description: 'New access token issued' },
          401: { description: 'Invalid or expired refresh token' },
        },
      },
    },
    '/auth/forgot-password': {
      post: {
        tags: ['Auth'],
        summary: 'Send 6-digit OTP to email for password reset',
        requestBody: {
          required: true,
          content: {
            'application/json': {
              schema: {
                type: 'object',
                required: ['email'],
                properties: { email: { type: 'string', example: 'rohan@gmail.com' } },
              },
            },
          },
        },
        responses: {
          200: { description: 'OTP sent to email' },
          404: { description: 'Email not found' },
        },
      },
    },
    '/auth/reset-password': {
      post: {
        tags: ['Auth'],
        summary: 'Reset password using the OTP received on email',
        requestBody: {
          required: true,
          content: {
            'application/json': {
              schema: {
                type: 'object',
                required: ['email', 'otp', 'newPassword'],
                properties: {
                  email: { type: 'string', example: 'rohan@gmail.com' },
                  otp: { type: 'string', example: '482910' },
                  newPassword: { type: 'string', example: 'NewPass@456' },
                },
              },
            },
          },
        },
        responses: { 200: { description: 'Password reset successful' } },
      },
    },

    // ── USERS ─────────────────────────────────
    '/users/me': {
      get: {
        tags: ['Users'],
        summary: 'Get current logged-in user profile',
        security: [{ bearerAuth: [] }],
        responses: {
          200: { description: 'User profile data (id, name, email, role, bio, totalSessions)' },
          401: { description: 'Unauthorized' },
        },
      },
      put: {
        tags: ['Users'],
        summary: 'Update profile (name, bio, avatar, phone)',
        security: [{ bearerAuth: [] }],
        requestBody: {
          content: {
            'application/json': {
              schema: {
                type: 'object',
                properties: {
                  name: { type: 'string' },
                  bio: { type: 'string' },
                  phone: { type: 'string' },
                  avatar: { type: 'string', description: 'URL or base64 string' },
                },
              },
            },
          },
        },
        responses: { 200: { description: 'Profile updated' } },
      },
    },

    // ── CLIENTS ───────────────────────────────
    '/clients/contact': {
      post: {
        tags: ['Clients'],
        summary: 'Submit a contact form',
        requestBody: {
          required: true,
          content: {
            'application/json': {
              schema: {
                type: 'object',
                required: ['name', 'email', 'message'],
                properties: {
                  name: { type: 'string' },
                  email: { type: 'string' },
                  phone: { type: 'string' },
                  subject: { type: 'string' },
                  message: { type: 'string' }
                }
              }
            }
          }
        },
        responses: { 201: { description: 'Contact submitted' } }
      }
    },
    '/clients/dashboard': {
      get: {
        tags: ['Clients'],
        summary: 'Get aggregated Learner Dashboard data',
        security: [{ bearerAuth: [] }],
        responses: {
          200: {
            description: 'Dashboard data (upcoming sessions, roadmaps, unread notifications, recent mentors)',
            content: {
              'application/json': {
                example: {
                  success: true,
                  data: {
                    upcomingSessions: [],
                    roadmaps: [],
                    unreadNotificationsCount: 0,
                    recentMentors: []
                  }
                }
              }
            }
          }
        }
      }
    },
    '/clients/bookings': {
      post: {
        tags: ['Clients'],
        summary: 'Create a new booking request',
        security: [{ bearerAuth: [] }],
        requestBody: {
          required: true,
          content: {
            'application/json': {
              schema: {
                type: 'object',
                required: ['expertId', 'serviceType', 'scheduledDate', 'duration', 'totalAmount'],
                properties: {
                  expertId: { type: 'integer' },
                  serviceType: { type: 'string' },
                  scheduledDate: { type: 'string', format: 'date-time' },
                  duration: { type: 'integer' },
                  totalAmount: { type: 'number' },
                  notes: { type: 'string' }
                }
              }
            }
          }
        },
        responses: { 201: { description: 'Booking created' } }
      },
      get: {
        tags: ['Clients'],
        summary: 'Get all user bookings (learner or expert)',
        security: [{ bearerAuth: [] }],
        responses: { 200: { description: 'List of bookings' } }
      }
    },
    '/clients/bookings/{id}': {
      get: {
        tags: ['Clients'],
        summary: 'Get single booking details',
        security: [{ bearerAuth: [] }],
        parameters: [{ in: 'path', name: 'id', required: true, schema: { type: 'integer' } }],
        responses: { 200: { description: 'Booking details' } }
      },
      put: {
        tags: ['Clients'],
        summary: 'Update a booking (reschedule, cancel)',
        security: [{ bearerAuth: [] }],
        parameters: [{ in: 'path', name: 'id', required: true, schema: { type: 'integer' } }],
        requestBody: {
          content: {
            'application/json': {
              schema: {
                type: 'object',
                properties: {
                  scheduledDate: { type: 'string', format: 'date-time' },
                  status: { type: 'string' },
                  notes: { type: 'string' }
                }
              }
            }
          }
        },
        responses: { 200: { description: 'Booking updated' } }
      }
    },
    '/clients/bookings/{id}/confirm': {
      post: {
        tags: ['Clients'],
        summary: 'Confirm a booking after payment',
        security: [{ bearerAuth: [] }],
        parameters: [{ in: 'path', name: 'id', required: true, schema: { type: 'integer' } }],
        responses: { 200: { description: 'Booking confirmed' } }
      }
    },
    '/clients/bookings/{id}/complete': {
      post: {
        tags: ['Clients'],
        summary: 'Mark a booking as completed',
        security: [{ bearerAuth: [] }],
        parameters: [{ in: 'path', name: 'id', required: true, schema: { type: 'integer' } }],
        responses: { 200: { description: 'Booking completed' } }
      }
    },
    '/clients/bookings/{id}/cancel': {
      post: {
        tags: ['Clients'],
        summary: 'Cancel a booking with a reason',
        security: [{ bearerAuth: [] }],
        parameters: [{ in: 'path', name: 'id', required: true, schema: { type: 'integer' } }],
        requestBody: {
          content: {
            'application/json': {
              schema: { type: 'object', properties: { reason: { type: 'string' } } }
            }
          }
        },
        responses: { 200: { description: 'Booking cancelled' } }
      }
    },
    '/clients/bookings/{id}/meeting-link': {
      get: {
        tags: ['Clients'],
        summary: 'Get Zoom/Google Meet link for a booking',
        security: [{ bearerAuth: [] }],
        parameters: [{ in: 'path', name: 'id', required: true, schema: { type: 'integer' } }],
        responses: { 200: { description: 'Meeting link' } }
      }
    },
    '/clients/payments': {
      get: {
        tags: ['Clients'],
        summary: 'List user payments',
        security: [{ bearerAuth: [] }],
        responses: { 200: { description: 'User payments' } }
      }
    },
    '/clients/reviews': {
      post: {
        tags: ['Clients'],
        summary: 'Create a review for an expert',
        security: [{ bearerAuth: [] }],
        requestBody: {
          required: true,
          content: {
            'application/json': {
              schema: {
                type: 'object',
                required: ['bookingId', 'expertId', 'rating'],
                properties: {
                  bookingId: { type: 'integer' },
                  expertId: { type: 'integer' },
                  rating: { type: 'number', format: 'float' },
                  comment: { type: 'string' }
                }
              }
            }
          }
        },
        responses: { 201: { description: 'Review created' } }
      }
    },

    // ── EXPERTS ───────────────────────────────
    '/experts/dashboard': {
      get: {
        tags: ['Experts'],
        summary: 'Get expert dashboard aggregated data',
        security: [{ bearerAuth: [] }],
        responses: {
          200: {
            description: 'Dashboard data including earnings, sessions, and reviews',
            content: {
              'application/json': {
                example: {
                  success: true,
                  data: {
                    totalEarnings: 15000,
                    upcomingSessions: 3,
                    completedSessions: 12,
                    avgRating: 4.8,
                    totalReviews: 24
                  }
                }
              }
            }
          }
        }
      }
    },
    '/experts': {
      get: {
        tags: ['Experts'],
        summary: 'Search and filter experts',
        parameters: [
          { in: 'query', name: 'category', schema: { type: 'string' }, description: 'e.g. Mobile Dev, AI/ML' },
          { in: 'query', name: 'skill', schema: { type: 'string' }, description: 'Skill keyword e.g. Flutter' },
          { in: 'query', name: 'minRating', schema: { type: 'number' } },
          { in: 'query', name: 'maxPrice', schema: { type: 'number' }, description: 'Max INR/hour' },
          { in: 'query', name: 'available', schema: { type: 'boolean' } },
          { in: 'query', name: 'sort', schema: { type: 'string', enum: ['rating', 'price_asc', 'price_desc', 'sessions'] } },
          { in: 'query', name: 'page', schema: { type: 'integer', default: 1 } },
          { in: 'query', name: 'limit', schema: { type: 'integer', default: 20 } },
        ],
        responses: { 200: { description: 'Paginated expert list' } },
      },
    },
    '/experts/top-rated': {
      get: {
        tags: ['Experts'],
        summary: 'Get top-rated experts',
        responses: { 200: { description: 'Top rated expert list' } },
      },
    },
    '/experts/categories': {
      get: {
        tags: ['Experts'],
        summary: 'Get available expert categories',
        responses: { 200: { description: 'Category list' } },
      },
    },
    '/experts/register': {
      post: {
        tags: ['Experts'],
        summary: 'Register the current user as an expert',
        security: [{ bearerAuth: [] }],
        requestBody: {
          required: true,
          content: {
            'application/json': {
              schema: {
                type: 'object',
                required: ['title', 'category', 'experienceYears', 'pricePerHour', 'skills'],
                properties: {
                  title: { type: 'string', example: 'Senior Flutter Developer' },
                  category: { type: 'string', example: 'Mobile Dev' },
                  experienceYears: { type: 'integer', example: 8 },
                  pricePerHour: { type: 'integer', example: 999 },
                  skills: { type: 'array', items: { type: 'string' }, example: ['Flutter', 'Dart'] },
                  bio: { type: 'string' },
                  achievements: { type: 'array', items: { type: 'string' } },
                },
              },
            },
          },
        },
        responses: { 201: { description: 'Expert profile created' } },
      },
    },
    '/experts/profile': {
      put: {
        tags: ['Experts'],
        summary: 'Expert updates their own profile',
        security: [{ bearerAuth: [] }],
        requestBody: {
          content: {
            'application/json': {
              schema: {
                type: 'object',
                properties: {
                  title: { type: 'string' },
                  bio: { type: 'string' },
                  pricePerHour: { type: 'integer' },
                  skills: { type: 'array', items: { type: 'string' } },
                  isAvailable: { type: 'boolean' },
                },
              },
            },
          },
        },
        responses: { 200: { description: 'Profile updated' } },
      },
    },
    '/experts/{id}': {
      get: {
        tags: ['Experts'],
        summary: 'Get full expert profile',
        parameters: [{ in: 'path', name: 'id', required: true, schema: { type: 'integer' } }],
        responses: {
          200: { description: 'Expert profile data' },
          404: { description: 'Expert not found' },
        },
      },
    },
    '/experts/{id}/reviews': {
      get: {
        tags: ['Experts'],
        summary: 'Get paginated reviews of an expert',
        parameters: [
          { in: 'path', name: 'id', required: true, schema: { type: 'integer' } },
          { in: 'query', name: 'page', schema: { type: 'integer' } },
          { in: 'query', name: 'limit', schema: { type: 'integer' } },
        ],
        responses: { 200: { description: 'List of reviews' } },
      },
      post: {
        tags: ['Experts'],
        summary: 'Submit a review after a session',
        security: [{ bearerAuth: [] }],
        parameters: [{ in: 'path', name: 'id', required: true, schema: { type: 'integer' } }],
        requestBody: {
          required: true,
          content: {
            'application/json': {
              schema: {
                type: 'object',
                required: ['bookingId', 'rating'],
                properties: {
                  bookingId: { type: 'integer', example: 42 },
                  rating: { type: 'integer', minimum: 1, maximum: 5, example: 5 },
                  comment: { type: 'string', example: 'Excellent session!' },
                },
              },
            },
          },
        },
        responses: {
          201: { description: 'Review submitted' },
          400: { description: 'Review already exists for this booking' },
        },
      },
    },
    '/experts/{id}/availability': {
      get: {
        tags: ['Experts'],
        summary: 'Get available time slots for an expert',
        security: [{ bearerAuth: [] }],
        parameters: [
          { in: 'path', name: 'id', required: true, schema: { type: 'integer' } },
          { in: 'query', name: 'startDate', schema: { type: 'string', format: 'date' }, example: '2026-05-15' },
          { in: 'query', name: 'endDate', schema: { type: 'string', format: 'date' } },
        ],
        responses: { 200: { description: 'Available slots by date' } },
      },
      post: {
        tags: ['Experts'],
        summary: 'Expert sets their availability',
        security: [{ bearerAuth: [] }],
        parameters: [{ in: 'path', name: 'id', required: true, schema: { type: 'integer' } }],
        requestBody: {
          required: true,
          content: {
            'application/json': {
              schema: {
                type: 'object',
                properties: {
                  availability: { type: 'object', example: { '2026-05-15': ['09:00', '10:00', '14:00'] } },
                },
              },
            },
          },
        },
        responses: { 200: { description: 'Availability updated' } },
      },
    },

    // ── BOOKINGS ──────────────────────────────
    '/bookings': {
      post: {
        tags: ['Bookings'],
        summary: 'Create a new session booking with an expert',
        security: [{ bearerAuth: [] }],
        requestBody: {
          required: true,
          content: {
            'application/json': {
              schema: {
                type: 'object',
                required: ['expertId', 'sessionType', 'date', 'timeSlot', 'durationMinutes'],
                properties: {
                  expertId: { type: 'integer', example: 1 },
                  sessionType: { type: 'string', enum: ['chat', 'audio', 'video'], example: 'video' },
                  date: { type: 'string', format: 'date', example: '2026-05-17' },
                  timeSlot: { type: 'string', example: '16:00' },
                  durationMinutes: { type: 'integer', example: 60 },
                  topic: { type: 'string', example: 'Flutter State Management' },
                },
              },
            },
          },
        },
        responses: {
          201: { description: 'Booking created — status: pending_payment, razorpayOrderId returned' },
        },
      },
      get: {
        tags: ['Bookings'],
        summary: 'Get all bookings for the current user',
        security: [{ bearerAuth: [] }],
        parameters: [
          { in: 'query', name: 'status', schema: { type: 'string', enum: ['pending_payment', 'confirmed', 'completed', 'cancelled'] } },
          { in: 'query', name: 'type', schema: { type: 'string', enum: ['upcoming', 'past'] } },
        ],
        responses: { 200: { description: 'List of bookings' } },
      },
    },
    '/bookings/{id}': {
      get: {
        tags: ['Bookings'],
        summary: 'Get single booking details',
        security: [{ bearerAuth: [] }],
        parameters: [{ in: 'path', name: 'id', required: true, schema: { type: 'integer' } }],
        responses: {
          200: { description: 'Booking details' },
          404: { description: 'Booking not found' },
        },
      },
    },
    '/bookings/{id}/cancel': {
      patch: {
        tags: ['Bookings'],
        summary: 'Cancel a booking',
        security: [{ bearerAuth: [] }],
        parameters: [{ in: 'path', name: 'id', required: true, schema: { type: 'integer' } }],
        responses: {
          200: { description: 'Booking cancelled' },
          404: { description: 'Booking not found or unauthorized' },
        },
      },
    },

    // ── CHAT ──────────────────────────────────
    '/conversations': {
      get: {
        tags: ['Chat'],
        summary: 'List all conversations for the current user',
        security: [{ bearerAuth: [] }],
        responses: { 200: { description: 'List of conversations with last message and unread count' } },
      },
    },
    '/conversations/{id}/messages': {
      get: {
        tags: ['Chat'],
        summary: 'Load chat message history for a conversation',
        security: [{ bearerAuth: [] }],
        parameters: [
          { in: 'path', name: 'id', required: true, schema: { type: 'integer' }, description: 'Conversation ID' },
          { in: 'query', name: 'before', schema: { type: 'string' }, description: 'ISO timestamp for cursor pagination' },
          { in: 'query', name: 'limit', schema: { type: 'integer', default: 50 } },
        ],
        responses: { 200: { description: 'Message history' } },
      },
    },
    '/messages': {
      post: {
        tags: ['Chat'],
        summary: 'Send a text message (REST fallback — prefer Socket.io)',
        security: [{ bearerAuth: [] }],
        requestBody: {
          required: true,
          content: {
            'application/json': {
              schema: {
                type: 'object',
                required: ['text'],
                properties: {
                  conversationId: { type: 'integer', description: 'Required if recipientId not given' },
                  recipientId: { type: 'integer', description: 'Auto-creates conversation if none exists' },
                  text: { type: 'string', example: 'Hello! Ready for the session?' },
                },
              },
            },
          },
        },
        responses: { 201: { description: 'Message sent' } },
      },
    },

    // ── COMMUNITY ─────────────────────────────
    '/community/posts': {
      get: {
        tags: ['Community'],
        summary: 'Get paginated list of community questions',
        parameters: [
          { in: 'query', name: 'tag', schema: { type: 'string' }, description: 'Filter by tag e.g. Flutter' },
          { in: 'query', name: 'search', schema: { type: 'string' }, description: 'Full-text search' },
          { in: 'query', name: 'sort', schema: { type: 'string', enum: ['newest', 'popular', 'unanswered'] } },
          { in: 'query', name: 'page', schema: { type: 'integer', default: 1 } },
          { in: 'query', name: 'limit', schema: { type: 'integer', default: 20 } },
        ],
        responses: { 200: { description: 'List of community posts' } },
      },
      post: {
        tags: ['Community'],
        summary: 'Create a new community question',
        security: [{ bearerAuth: [] }],
        requestBody: {
          required: true,
          content: {
            'application/json': {
              schema: {
                type: 'object',
                required: ['question', 'tag'],
                properties: {
                  question: { type: 'string', example: 'What is the best state management for Flutter?' },
                  tag: { type: 'string', example: 'Flutter' },
                },
              },
            },
          },
        },
        responses: { 201: { description: 'Post created' } },
      },
    },
    '/community/posts/{id}': {
      get: {
        tags: ['Community'],
        summary: 'Get a single post with all its answers',
        parameters: [{ in: 'path', name: 'id', required: true, schema: { type: 'integer' } }],
        responses: {
          200: { description: 'Post with answers' },
          404: { description: 'Post not found' },
        },
      },
    },
    '/community/posts/{id}/answers': {
      post: {
        tags: ['Community'],
        summary: 'Post an answer to a community question',
        security: [{ bearerAuth: [] }],
        parameters: [{ in: 'path', name: 'id', required: true, schema: { type: 'integer' }, description: 'Post ID' }],
        requestBody: {
          required: true,
          content: {
            'application/json': {
              schema: {
                type: 'object',
                required: ['answer'],
                properties: {
                  answer: { type: 'string', example: 'Riverpod is the recommended approach for 2026...' },
                },
              },
            },
          },
        },
        responses: { 201: { description: 'Answer posted' } },
      },
    },
    '/community/posts/{id}/like': {
      post: {
        tags: ['Community'],
        summary: 'Toggle like on a community post',
        security: [{ bearerAuth: [] }],
        parameters: [{ in: 'path', name: 'id', required: true, schema: { type: 'integer' } }],
        responses: { 200: { description: 'Like toggled, returns new like count' } },
      },
    },
    '/community/tags': {
      get: {
        tags: ['Community'],
        summary: 'Get popular community tags',
        responses: { 200: { description: 'Tag list' } },
      },
    },

    // ── PAYMENTS ──────────────────────────────
    '/payments/create-order': {
      post: {
        tags: ['Payments'],
        summary: 'Create a Razorpay order for a booking',
        security: [{ bearerAuth: [] }],
        requestBody: {
          required: true,
          content: {
            'application/json': {
              schema: {
                type: 'object',
                required: ['bookingId'],
                properties: { bookingId: { type: 'integer', example: 42 } },
              },
            },
          },
        },
        responses: {
          200: { description: 'Razorpay order created — returns razorpayOrderId, amount (paise), currency, key' },
          404: { description: 'Booking not found' },
        },
      },
    },
    '/payments/verify': {
      post: {
        tags: ['Payments'],
        summary: 'Verify Razorpay payment signature and confirm booking',
        security: [{ bearerAuth: [] }],
        requestBody: {
          required: true,
          content: {
            'application/json': {
              schema: {
                type: 'object',
                required: ['razorpayOrderId', 'razorpayPaymentId'],
                properties: {
                  razorpayOrderId: { type: 'string', example: 'order_abc123' },
                  razorpayPaymentId: { type: 'string', example: 'pay_xyz789' },
                  razorpaySignature: { type: 'string', example: 'hmac_sha256_signature' },
                },
              },
            },
          },
        },
        responses: {
          200: { description: 'Payment verified — booking status becomes confirmed' },
        },
      },
    },
    '/payments/history': {
      get: {
        tags: ['Payments'],
        summary: 'Get payment and transaction history',
        security: [{ bearerAuth: [] }],
        responses: { 200: { description: 'List of past payments with booking details' } },
      },
    },

    // ── ROADMAP ───────────────────────────────
    '/roadmap': {
      get: {
        tags: ['Roadmap'],
        summary: "Get current user's career roadmap",
        security: [{ bearerAuth: [] }],
        responses: {
          200: { description: 'Active roadmap with steps and progress' },
          404: { description: 'No roadmap found' },
        },
      },
    },
    '/roadmap/generate': {
      post: {
        tags: ['Roadmap'],
        summary: 'Generate an AI-powered personalized career roadmap (Gemini)',
        security: [{ bearerAuth: [] }],
        requestBody: {
          required: true,
          content: {
            'application/json': {
              schema: {
                type: 'object',
                required: ['goal', 'currentLevel', 'timeAvailableWeekly'],
                properties: {
                  goal: { type: 'string', example: 'Become a Flutter developer and get a job' },
                  currentLevel: { type: 'string', enum: ['beginner', 'intermediate', 'advanced'], example: 'beginner' },
                  timeAvailableWeekly: { type: 'integer', example: 10, description: 'Hours per week' },
                },
              },
            },
          },
        },
        responses: {
          200: { description: 'AI roadmap generated with title, totalWeeks and step-by-step plan' },
        },
      },
    },
    '/roadmap/steps/{id}': {
      patch: {
        tags: ['Roadmap'],
        summary: 'Mark a roadmap step as complete or incomplete',
        security: [{ bearerAuth: [] }],
        parameters: [{ in: 'path', name: 'id', required: true, schema: { type: 'integer' }, description: 'Step number' }],
        requestBody: {
          required: true,
          content: {
            'application/json': {
              schema: {
                type: 'object',
                required: ['isCompleted'],
                properties: { isCompleted: { type: 'boolean', example: true } },
              },
            },
          },
        },
        responses: {
          200: { description: 'Step updated — returns stepId, isCompleted, progressPercent' },
        },
      },
    },

    // ── AI ────────────────────────────────────
    '/ai/smart-match': {
      post: {
        tags: ['AI'],
        summary: 'AI recommends best-matched experts for a challenge',
        requestBody: {
          content: {
            'application/json': {
              schema: {
                type: 'object',
                properties: {
                  challenge: { type: 'string', example: 'I need help optimizing MySQL queries for high-traffic' },
                  skills: { type: 'array', items: { type: 'string' } },
                },
              },
            },
          },
        },
        responses: { 200: { description: 'Matched expert recommendations' } },
      },
    },
    '/ai/analyze-challenge': {
      post: {
        tags: ['AI'],
        summary: 'Analyze a technical challenge using AI',
        requestBody: {
          content: {
            'application/json': {
              schema: {
                type: 'object',
                properties: { challenge: { type: 'string', example: 'My Node.js app crashes under load' } },
              },
            },
          },
        },
        responses: { 200: { description: 'AI analysis result' } },
      },
    },
    '/ai/profile-optimizer': {
      post: {
        tags: ['AI'],
        summary: 'Get AI suggestions to optimize expert profile (expert only)',
        security: [{ bearerAuth: [] }],
        responses: { 200: { description: 'Profile optimization suggestions' } },
      },
    },

    // ── NOTIFICATIONS ─────────────────────────
    '/notifications': {
      get: {
        tags: ['Notifications'],
        summary: 'Get all notifications for the current user (newest first)',
        security: [{ bearerAuth: [] }],
        parameters: [
          { in: 'query', name: 'unread', schema: { type: 'boolean' }, description: 'true = only unread' },
        ],
        responses: { 200: { description: 'Notifications list with unreadCount in meta' } },
      },
    },
    '/notifications/read-all': {
      patch: {
        tags: ['Notifications'],
        summary: 'Mark all notifications as read',
        security: [{ bearerAuth: [] }],
        responses: { 200: { description: 'All notifications marked as read' } },
      },
    },
  },
};

const app = express();
const PORT = process.env.PORT || 5000;

app.use(express.json());
app.use(cors({
    origin: ['http://localhost', 'http://localhost:3000', 'http://localhost:5173'],
    credentials: true
}));
app.use(cookieParser());
app.use('/uploads', express.static('uploads'));

// Swagger Documentation
app.use('/api-docs', swaggerUi.serve, swaggerUi.setup(swaggerSpec, {
  customSiteTitle: 'ExpertMentor API Docs',
  customCss: `.swagger-ui .topbar { background-color: #1a1a2e; }
               .swagger-ui .topbar-wrapper img { display: none; }
               .swagger-ui .topbar-wrapper::after { content: '⚡ ExpertMentor API'; color: white; font-size: 1.2rem; font-weight: bold; }`,
  swaggerOptions: { persistAuthorization: true },
}));

// API v1 Routes
app.use('/v1/auth', authRoutes);
app.use('/v1/users', authRoutes);
app.use('/v1/clients', clientRoutes);
app.use('/v1/experts', expertRoutes);
app.use('/v1/bookings', bookingRoutes);
app.use('/v1/community', communityRoutes);
app.use('/v1/payments', paymentRoutes);
app.use('/v1/notifications', notificationRoutes);
app.use('/v1/roadmap', aiRoutes);
app.use('/v1/ai', aiRoutes);
app.use('/v1', chatRoutes);

async function startServer() {
    try {
        await syncDB();
        app.listen(PORT, () => {
            console.log(`\n🚀 Expert Mentor Server running on port ${PORT}`);
            console.log(`📚 Swagger Docs: http://localhost:${PORT}/api-docs\n`);
        });
    } catch (error) {
        console.error('Failed to start:', error);
    }
}

startServer();
