# 🏭 Expert on Floor

> **Digital marketplace connecting industrial businesses with specialized shop-floor experts.**  
> A full-stack platform built with **Node.js + Express** (backend) and **Flutter** (mobile frontend).

[![Node.js](https://img.shields.io/badge/Node.js-22.x-green?logo=node.js)](https://nodejs.org/)
[![Express](https://img.shields.io/badge/Express-5.x-black?logo=express)](https://expressjs.com/)
[![Flutter](https://img.shields.io/badge/Flutter-3.x-blue?logo=flutter)](https://flutter.dev/)
[![MySQL](https://img.shields.io/badge/MySQL-8.x-orange?logo=mysql)](https://www.mysql.com/)
[![MongoDB](https://img.shields.io/badge/MongoDB-Mongoose-green?logo=mongodb)](https://www.mongodb.com/)
[![License](https://img.shields.io/badge/License-ISC-blue)](LICENSE)

---

## 📖 Table of Contents

- [Overview](#-overview)
- [Features](#-features)
- [Architecture](#-architecture)
- [Tech Stack](#-tech-stack)
- [Project Structure](#-project-structure)
- [Database Schema](#-database-schema)
- [API Documentation](#-api-documentation)
- [Getting Started](#-getting-started)
- [Environment Variables](#-environment-variables)
- [Running the App](#-running-the-app)
- [Flutter Mobile App](#-flutter-mobile-app)
- [Contributors](#-contributors)

---

## 🔍 Overview

**Expert on Floor** is a two-sided marketplace that bridges the gap between:
- **Industrial businesses (Clients/Learners)** who need on-demand expert guidance for their shop-floor operations.
- **Specialists (Experts)** who offer consulting, training, and knowledge-sharing services in areas like manufacturing, quality control, production optimization, and more.

The platform provides:
- Role-based access for **Admins**, **Experts**, and **Clients/Learners**
- A booking and payment system for sessions
- AI-powered mentor recommendations
- Community forums, blogs, case studies, and roadmaps
- Real-time chat and notifications
- Google OAuth & OTP-based authentication

---

## ✨ Features

### 👤 Authentication
| Feature | Details |
|--------|---------|
| JWT Authentication | Secure token-based login/logout |
| Google OAuth 2.0 | One-click Google sign-in |
| OTP Verification | Email-based OTP for registration & password reset |
| Forgot/Reset Password | Secure email-link password recovery |
| Role-based Access | Admin / Expert / Client roles |

### 🎓 Expert Module
| Feature | Details |
|--------|---------|
| Expert Profile | Bio, expertise, experience, certificates, reviews |
| Availability Management | Set available slots for bookings |
| Session Management | Accept/reject/complete bookings |
| Earnings Dashboard | Track income and payment history |
| Content Creation | Blogs, Case Studies, Roadmaps |

### 🏢 Client / Learner Module
| Feature | Details |
|--------|---------|
| Expert Discovery | Browse & filter experts by domain |
| Booking System | Book sessions with preferred experts |
| Payment Integration | Pay for sessions securely |
| Dashboard | Upcoming sessions, past bookings, saved experts |
| AI Mentor | AI-powered recommendations via Gemini |

### 🤖 AI Module
| Feature | Details |
|--------|---------|
| Gemini Integration | Google Generative AI (`@google/generative-ai`) |
| Expert Recommendations | AI suggests best-matching experts |
| Chat AI | Conversational assistant for learners |
| Roadmap Generation | Auto-generate learning roadmaps |

### 🌐 Community Module
| Feature | Details |
|--------|---------|
| Community Posts | Share knowledge with the community |
| Q&A (Answers) | Ask questions, get expert answers |
| Blog Posts | Expert-authored articles |
| Case Studies | Real-world industrial case studies |

### 🔔 Other Features
| Feature | Details |
|--------|---------|
| Real-time Chat | Conversation & message models |
| Notifications | In-app notification system |
| File Uploads | Multer-based profile photo & document uploads |
| Swagger API Docs | Interactive API documentation at `/api-docs` |
| Admin Panel | Manage users, bookings, payments, reports |

---

## 🏗️ Architecture

```
┌─────────────────────────────────────────────────────────┐
│                    Flutter Mobile App                   │
│  (Dart · Provider · HTTP · Google Sign-In · Flutter     │
│   Animate · SharedPreferences · PinPut · Fluttertoast)  │
└────────────────────────┬────────────────────────────────┘
                         │ REST API (JSON)
                         ▼
┌─────────────────────────────────────────────────────────┐
│               Node.js / Express Backend                 │
│                                                         │
│  ┌──────────┐  ┌─────────────┐  ┌──────────────────┐   │
│  │  Routes  │→ │ Controllers │→ │     Models       │   │
│  │  /auth   │  │ auth_ctrl   │  │ User, Expert...  │   │
│  │  /expert │  │ expert_ctrl │  │                  │   │
│  │  /client │  │ client_ctrl │  └──────┬───────────┘   │
│  │  /admin  │  │ admin_ctrl  │         │               │
│  │  /ai     │  │ ai_ctrl     │         ▼               │
│  │  /chat   │  │ chat_ctrl   │  ┌──────────────────┐   │
│  │  /booking│  │ booking_ctrl│  │  MySQL (Sequelize)│   │
│  │  /payment│  │ payment_ctrl│  │  MongoDB (Mongoose)│  │
│  │  /comm.  │  │ community.. │  └──────────────────┘   │
│  └──────────┘  └─────────────┘                         │
│                                                         │
│  Middleware: JWT Auth · Multer Upload                   │
│  Services: Nodemailer · Google AI · Google OAuth        │
└─────────────────────────────────────────────────────────┘
```

---

## 🛠️ Tech Stack

### Backend
| Technology | Version | Purpose |
|-----------|---------|---------|
| **Node.js** | 22.x | Runtime environment |
| **Express** | 5.x | Web framework |
| **Sequelize** | 6.x | MySQL ORM |
| **Mongoose** | 9.x | MongoDB ODM |
| **MySQL2** | 3.x | MySQL database driver |
| **bcryptjs** | 3.x | Password hashing |
| **jsonwebtoken** | 9.x | JWT auth tokens |
| **nodemailer** | 7.x | Email sending (OTP, alerts) |
| **multer** | 2.x | File uploads |
| **cors** | 2.x | Cross-origin resource sharing |
| **dotenv** | 16.x | Environment variable management |
| **cookie-parser** | 1.x | Cookie parsing |
| **axios** | 1.x | HTTP client |
| **google-auth-library** | 10.x | Google OAuth verification |
| **@google/generative-ai** | 0.24.x | Gemini AI integration |
| **swagger-jsdoc** | 6.x | API documentation generation |
| **swagger-ui-express** | 5.x | Interactive Swagger UI |

### Frontend (Flutter)
| Technology | Version | Purpose |
|-----------|---------|---------|
| **Flutter** | 3.x | Cross-platform UI framework |
| **Dart** | 3.x | Programming language |
| **provider** | 6.x | State management |
| **http** | 1.x | REST API calls |
| **shared_preferences** | 2.x | Local storage (tokens, prefs) |
| **google_sign_in** | 6.x | Google OAuth on mobile |
| **flutter_animate** | 4.x | Rich UI animations |
| **pinput** | 4.x | OTP input widget |
| **fluttertoast** | 8.x | Toast notifications |
| **logger** | 2.x | Structured logging |
| **cupertino_icons** | 1.x | iOS-style icons |

### Database
| Database | ORM/ODM | Used For |
|---------|---------|---------|
| **MySQL 8** | Sequelize | Core relational data (users, bookings, payments) |
| **MongoDB** | Mongoose | Flexible/document data (chats, community posts) |

---

## 📁 Project Structure

```
expert-on-floor/
│
├── 📂 config/
│   └── database.js               # DB connection config (MySQL + MongoDB)
│
├── 📂 controllers/               # Business logic layer
│   ├── admin_controller.js       # Admin operations
│   ├── ai_controller.js          # Gemini AI endpoints
│   ├── auth_controller.js        # Register, login, OTP, Google OAuth
│   ├── booking_controller.js     # Session booking logic
│   ├── chat_controller.js        # Messaging logic
│   ├── client_controller.js      # Client/Learner actions
│   ├── community_controller.js   # Community posts & Q&A
│   ├── content_controller.js     # Blogs & case studies
│   ├── expert_controller.js      # Expert profile & operations
│   ├── expertise_controller.js   # Expertise categories
│   ├── notification_controller.js# Notification management
│   └── payment_controller.js     # Payment processing
│
├── 📂 middleware/
│   ├── auth.js                   # JWT verification middleware
│   └── upload.js                 # Multer file upload middleware
│
├── 📂 models/                    # Data models
│   ├── index.js                  # Sequelize model registry
│   ├── User.js                   # User model
│   ├── Expert.js                 # Expert profile model
│   ├── Booking.js                # Booking model
│   ├── Payment.js                # Payment model
│   ├── Review.js                 # Review & rating model
│   ├── Message.js                # Chat message model
│   ├── Conversation.js           # Chat conversation model
│   ├── CommunityPost.js          # Community post model
│   ├── Answer.js                 # Q&A answer model
│   ├── BlogPost.js               # Blog post model
│   ├── CaseStudy.js              # Case study model
│   ├── Roadmap.js                # Learning roadmap model
│   ├── Certificate.js            # Expert certificate model
│   ├── Expertise.js              # Expertise/domain model
│   ├── Notification.js           # Notification model
│   └── Contact.js                # Contact form model
│
├── 📂 routes/                    # API route definitions
│   ├── auth_routes.js            # /api/auth/*
│   ├── expert_routes.js          # /api/experts/*
│   ├── client_routes.js          # /api/clients/*
│   ├── admin_routes.js           # /api/admin/*
│   ├── ai_routes.js              # /api/ai/*
│   ├── booking_routes.js         # /api/bookings/*
│   ├── chat_routes.js            # /api/chat/*
│   ├── community_routes.js       # /api/community/*
│   ├── notification_routes.js    # /api/notifications/*
│   ├── payment_routes.js         # /api/payments/*
│   └── public_routes.js          # /api/public/*
│
├── 📂 uploads/                   # (gitignored) User uploaded files
│
├── 📂 frontend/                  # Flutter Mobile Application
│   ├── pubspec.yaml              # Flutter dependencies
│   └── lib/
│       ├── main.dart             # App entry point
│       ├── logger_factory.dart   # Logging utility
│       ├── 📂 core/              # App-wide constants & themes
│       ├── 📂 models/            # Dart data models
│       ├── 📂 providers/
│       │   ├── auth_provider.dart    # Auth state management
│       │   └── expert_provider.dart  # Expert state management
│       ├── 📂 services/
│       │   ├── auth_service.dart     # Auth API calls
│       │   └── expert_service.dart   # Expert API calls
│       ├── 📂 screens/
│       │   ├── splash_screen.dart        # Splash / loading screen
│       │   ├── onboarding_screen.dart    # First-launch onboarding
│       │   ├── login_screen.dart         # Login screen
│       │   ├── register_screen.dart      # Registration screen
│       │   ├── otp_verification_screen.dart # OTP input screen
│       │   ├── forgot_password_screen.dart  # Password recovery
│       │   ├── reset_password_screen.dart   # New password screen
│       │   ├── home_screen.dart          # Main home screen
│       │   └── 📂 learner/
│       │       ├── learner_dashboard_screen.dart # Learner dashboard
│       │       ├── expert_listing_screen.dart    # Browse experts
│       │       └── expert_profile_screen.dart    # View expert profile
│       ├── 📂 utils/             # Helper utilities
│       └── 📂 widgets/           # Reusable UI widgets
│
├── server.js                     # Express app entry point
├── package.json                  # Backend dependencies & scripts
├── pubspec.yaml                  # Flutter project config (root level)
├── expert-on-floor.sql           # MySQL database dump/schema
└── .env                          # (gitignored) Environment variables
```

---

## 🗄️ Database Schema

The project uses **MySQL** (via Sequelize) as the primary database and **MongoDB** (via Mongoose) for document-based data.

### Core MySQL Tables
| Table | Description |
|-------|-------------|
| `Users` | All registered users (role: admin/expert/client) |
| `Experts` | Expert profiles linked to User |
| `Bookings` | Session bookings between client and expert |
| `Payments` | Payment records per booking |
| `Reviews` | Ratings and reviews for experts |
| `Certificates` | Expert certifications/credentials |
| `Expertise` | Domain categories (e.g., Manufacturing, QC) |
| `Roadmaps` | Learning roadmaps created by experts |
| `BlogPosts` | Expert-authored blog articles |
| `CaseStudies` | Industrial case study documents |
| `CommunityPosts` | Forum/community posts |
| `Answers` | Community Q&A answers |
| `Notifications` | In-app notifications |
| `Contacts` | Contact form submissions |

### MongoDB Collections
| Collection | Description |
|-----------|-------------|
| `Conversations` | Chat conversation threads |
| `Messages` | Individual chat messages |

> 📄 See `expert-on-floor.sql` for the full MySQL schema dump.

---

## 📡 API Documentation

The API is fully documented with **Swagger/OpenAPI**.

Once the server is running, visit:
```
http://localhost:5000/api-docs
```

### API Route Groups
| Route Prefix | Description |
|-------------|-------------|
| `POST /api/auth/register` | Register a new user |
| `POST /api/auth/login` | Login with email & password |
| `POST /api/auth/google` | Google OAuth login |
| `POST /api/auth/verify-otp` | Verify email OTP |
| `POST /api/auth/forgot-password` | Initiate password reset |
| `POST /api/auth/reset-password` | Set new password |
| `GET /api/experts` | List all experts |
| `GET /api/experts/:id` | Get expert profile |
| `POST /api/bookings` | Create a booking |
| `GET /api/bookings` | Get user bookings |
| `POST /api/payments` | Process payment |
| `GET /api/community/posts` | List community posts |
| `POST /api/community/posts` | Create a community post |
| `GET /api/ai/recommend` | AI expert recommendations |
| `POST /api/ai/chat` | AI mentor chat |
| `GET /api/notifications` | Get notifications |
| `GET /api/admin/*` | Admin management (admin role only) |

---

## 🚀 Getting Started

### Prerequisites
- [Node.js](https://nodejs.org/) v18 or higher
- [MySQL](https://www.mysql.com/) 8.x
- [MongoDB](https://www.mongodb.com/) 6.x (or MongoDB Atlas)
- [Flutter](https://flutter.dev/docs/get-started/install) 3.x
- [Git](https://git-scm.com/)

### 1. Clone the Repository
```bash
git clone https://github.com/jaimiltrived/expert-on-floor.git
cd expert-on-floor
```

### 2. Install Backend Dependencies
```bash
npm install
```

### 3. Setup the Database
```bash
# Create the MySQL database
mysql -u root -p
CREATE DATABASE expert_on_floor;
exit;

# Import the schema
mysql -u root -p expert_on_floor < expert-on-floor.sql
```

### 4. Configure Environment Variables
```bash
cp .env.example .env
# Edit .env with your actual values (see Environment Variables section)
```

### 5. Install Flutter Dependencies
```bash
cd frontend
flutter pub get
```

---

## 🔐 Environment Variables

Create a `.env` file in the root directory with the following variables:

```env
# ─── Server ─────────────────────────────────────────────
PORT=5000
NODE_ENV=development

# ─── MySQL Database ─────────────────────────────────────
DB_HOST=localhost
DB_PORT=3306
DB_NAME=expert_on_floor
DB_USER=root
DB_PASSWORD=your_mysql_password

# ─── MongoDB ────────────────────────────────────────────
MONGO_URI=mongodb://localhost:27017/expert_on_floor

# ─── JWT ────────────────────────────────────────────────
JWT_SECRET=your_super_secret_jwt_key
JWT_EXPIRES_IN=7d

# ─── Google OAuth ───────────────────────────────────────
GOOGLE_CLIENT_ID=your_google_client_id
GOOGLE_CLIENT_SECRET=your_google_client_secret

# ─── Nodemailer (Email OTP) ─────────────────────────────
MAIL_HOST=smtp.gmail.com
MAIL_PORT=587
MAIL_USER=your_email@gmail.com
MAIL_PASS=your_app_password

# ─── Google Generative AI (Gemini) ──────────────────────
GEMINI_API_KEY=your_gemini_api_key

# ─── File Uploads ───────────────────────────────────────
UPLOAD_DIR=uploads/
MAX_FILE_SIZE=5242880
```

---

## ▶️ Running the App

### Backend (Development)
```bash
# Start with nodemon (auto-reload)
npm run dev

# Start in production
npm start
```
> Server runs at: `http://localhost:5000`  
> Swagger Docs: `http://localhost:5000/api-docs`

### Backend (Production)
```bash
NODE_ENV=production npm start
```

---

## 📱 Flutter Mobile App

The Flutter application lives in the `/frontend` directory.

### Setup
```bash
cd frontend
flutter pub get
```

### Run on Android Emulator / Device
```bash
flutter run
```

### Run on iOS Simulator (macOS only)
```bash
flutter run -d ios
```

### Build APK
```bash
flutter build apk --release
```

### Build iOS IPA (macOS only)
```bash
flutter build ios --release
```

### 📲 App Screens

| Screen | Description |
|--------|-------------|
| **Splash Screen** | Animated launch screen with branding |
| **Onboarding Screen** | First-launch feature introduction slides |
| **Login Screen** | Email/password & Google Sign-In |
| **Register Screen** | New user registration form |
| **OTP Verification** | 6-digit OTP input for email verification |
| **Forgot Password** | Email-based password recovery initiation |
| **Reset Password** | Set a new password after verification |
| **Home Screen** | Main navigation hub |
| **Learner Dashboard** | Client's personalized dashboard |
| **Expert Listing** | Browse & filter all available experts |
| **Expert Profile** | Detailed expert info, reviews, booking |

### State Management
The app uses the **Provider** pattern for state management:
- `AuthProvider` — Manages auth state (login, logout, token, user info)
- `ExpertProvider` — Manages expert data and listings

### Services
- `AuthService` — Handles all authentication API calls (login, register, OTP, Google OAuth)
- `ExpertService` — Handles expert-related API calls (listing, profile, booking)

---

## 🤝 Contributors

| Name | Role |
|------|------|
| **Jaimil Trivedi** | Full-Stack Developer |
| **Jay Santoki** | Full-Stack Developer |

---

## 📄 License

This project is licensed under the **ISC License**.

---

## 🙏 Acknowledgements

- [Express.js](https://expressjs.com/) — Fast, unopinionated web framework
- [Flutter](https://flutter.dev/) — Beautiful native apps
- [Google Gemini AI](https://ai.google.dev/) — AI-powered features
- [Swagger](https://swagger.io/) — API documentation

---

<p align="center">Made with ❤️ by the Expert on Floor Team</p>
