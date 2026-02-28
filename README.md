# Expert on Floor 🏭🛠️

Expert on Floor is a digital marketplace built on the MERN stack designed to connect industrial businesses with specialized shop-floor experts. The platform enables on-demand consulting, knowledge transfer, and professional skill development through a secure, verified, and AI-enhanced system.

## 🚀 Key Features

### 👤 User Roles & Management
- **Industrial Clients**: Browse experts, book consultations, and manage projects.
- **Expert Professionals**: Showcase expertise, manage availability, and earn through consulting.
- **Admin**: Oversee platform operations, verify expert credentials, and manage content.

### 🛡️ Expert Verification & Trust
- **Document Management**: Secure upload system for certifications and verification documents.
- **Admin Review**: Manual verification workflow for expert profiles.
- **Digital Certificates**: Platform-issued certificates for verified competencies.

### 📅 Booking & Consultation
- **Smart Scheduling**: Manage availability and book time slots.
- **Secure Payments**: Razorpay integration for safe transactions.
- **Meeting Links**: Automated generation of virtual consultation links.

### 🤖 AI-Powered Intelligence
- **Smart Match**: AI analyzes industrial problems and recommends the best-suited experts.
- **Profile Optimizer**: AI-driven suggestions for experts to improve their bios and expertise listing.
- **Challenge Analysis**: Instant technical briefs for complex industrial challenges.

### 📝 Content & SEO
- **Expert Directory**: Advanced search and filtering by expertise, rating, and location.
- **SEO Blog & Case Studies**: Content management system for industrial insights and success stories.
- **Notifications**: Real-time alerts for bookings, payments, and system updates.

## 🛠️ Technical Stack

- **Frontend**: React.js / Next.js
- **Backend**: Node.js & Express.js
- **Database**: MongoDB (Mongoose ODM)
- **AI**: Google Gemini AI (1.5 Flash)
- **Authentication**: JWT (Access & Refresh Tokens) with RBAC (Role-Based Access Control)
- **File Handling**: Multer (Local Storage)
- **Security**: bcryptjs for hashing, Helmet.js for headers, and CORS configuration.

## 📂 Project Structure

```text
SoundSphere/
├── controllers/      # Business logic for all modules
├── middleware/       # JWT auth, RBAC, and file upload logic
├── models/           # Mongoose schemas (User, Expert, Booking, etc.)
├── routes/           # Express API endpoints
├── uploads/          # Static storage for profile images and certificates
├── server.js         # Entry point & server configuration
└── .env              # Environment variables
```

## ⚙️ Installation & Setup

1. **Clone the repository**
   ```bash
   git clone https://github.com/your-username/expert-on-floor.git
   cd expert-on-floor
   ```

2. **Install dependencies**
   ```bash
   npm install
   ```

3. **Configure Environment Variables**
   Create a `.env` file in the root directory and add the following:
   ```env
   PORT = 3000
   MONGO_URI = "your_mongodb_uri"
   JWT_SECRET = "your_access_token_secret"
   REFRESH_TOKEN_SECRET = "your_refresh_token_secret"
   GEMINI_API_KEY = "your_google_gemini_api_key"
   RAZORPAY_KEY_ID = "your_razorpay_key"
   RAZORPAY_KEY_SECRET = "your_razorpay_secret"
   ```

4. **Run the server**
   ```bash
   # Production
   npm start
   
   # Development
   npm run dev
   ```

## 🛣️ API Endpoints Overview

| Category | Endpoint | Method | Description |
| :--- | :--- | :--- | :--- |
| **Auth** | `/api/v1/auth/register` | POST | Register a new user |
| **Auth** | `/api/v1/auth/login` | POST | Authenticate and get tokens |
| **Experts** | `/api/v1/experts` | GET | List verified experts |
| **AI** | `/api/v1/ai/smart-match` | POST | Match problem with experts |
| **Admin** | `/api/v1/admin/experts/:id/verify` | POST | Verify an expert (Admin only) |
| **Public** | `/api/v1/public/blog` | GET | Fetch SEO blog posts |

---
*Developed as a premier marketplace for the industrial sector.*
