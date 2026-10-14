# AGENTS.md — Expert on Floor

## Project Overview
Full-stack marketplace connecting industrial businesses with shop-floor experts.
- **Backend**: Node.js 22 + Express 5 + MySQL (Sequelize) + MongoDB (Mongoose)
- **Frontend**: Flutter 3 + Dart 3 (in `/frontend`)
- **Auth**: JWT + Google OAuth + Email OTP
- **Payments**: Razorpay
- **AI**: Google Gemini (`@google/generative-ai`)
- **Real-time**: Socket.io + Firebase Messaging

---

## Commands

### Backend (root)
```bash
npm install          # install deps
npm run dev          # dev server with nodemon (port 5000)
npm start            # production server
```

### Frontend (`/frontend`)
```bash
flutter pub get      # install deps
flutter run          # run on emulator/device
flutter build apk --release
flutter build ios --release  # macOS only
```

### Database
```bash
# MySQL (run once)
mysql -u root -p -e "CREATE DATABASE expert_on_floor;"
mysql -u root -p expert_on_floor < expert-on-floor.sql
# Tables auto-sync via Sequelize (alter: true) on server start
# MongoDB collections auto-create on first write
```

### API Docs
```
http://localhost:5000/api-docs  (Swagger UI)
```

---

## Environment Variables (`.env` — never commit)
```env
PORT=5000
NODE_ENV=development

# MySQL
DB_HOST=localhost
DB_PORT=3306
DB_NAME=expert_on_floor
DB_USER=root
DB_PASSWORD=your_password

# MongoDB
MONGO_URI=mongodb://localhost:27017/expert_on_floor

# JWT
JWT_SECRET=your_super_secret_jwt_key
JWT_EXPIRES_IN=7d

# Google OAuth
GOOGLE_CLIENT_ID=xxx
GOOGLE_CLIENT_SECRET=xxx

# Email (Nodemailer)
MAIL_HOST=smtp.gmail.com
MAIL_PORT=587
MAIL_USER=your_email@gmail.com
MAIL_PASS=your_app_password

# AI
GEMINI_API_KEY=your_gemini_key

# Payments
RAZORPAY_KEY=rzp_test_xxx
RAZORPAY_SECRET=xxx

# Uploads
UPLOAD_DIR=uploads/
MAX_FILE_SIZE=5242880
```

Copy from `.env.example` (create if missing) and fill in values.

---

## Architecture Highlights

### Dual Database
- **MySQL (Sequelize)**: Users, Experts, Bookings, Payments, Reviews, Community, Notifications, Roadmaps
- **MongoDB (Mongoose)**: Conversations, Messages (chat)

### Route Prefixes (all under `/api` in code, `/v1` in Swagger)
| Prefix | File | Purpose |
|--------|------|---------|
| `/auth` | `auth_routes.js` | Register, login, Google, OTP, JWT refresh |
| `/users` | `auth_routes.js` | Profile (me, update) |
| `/experts` | `expert_routes.js` | Profiles, search, availability, reviews |
| `/clients` | `client_routes.js` | Dashboard, bookings, payments, reviews |
| `/bookings` | `booking_routes.js` | Session CRUD, confirm/cancel/complete |
| `/chat` | `chat_routes.js` | Conversations, messages (REST + Socket.io) |
| `/community` | `community_routes.js` | Posts, Q&A |
| `/payments` | `payment_routes.js` | Razorpay orders, verify, webhooks |
| `/notifications` | `notification_routes.js` | In-app notifications |
| `/ai` | `ai_routes.js` | Gemini recommendations, chat, roadmaps |
| `/admin` | `admin_routes.js` | Admin-only management (roleMiddleware) |

### Auth Middleware
- `authMiddleware` — verifies JWT, attaches `req.user` (excludes password), adds `req.user.expertId` if role=expert
- `roleMiddleware(['admin','expert'])` — role-based access

### File Uploads
- Multer middleware in `middleware/upload.js`
- Files served statically from `/uploads` (gitignored)
- Avatar upload: `POST /api/auth/upload-avatar` (multipart, field `profileImage`)

### Real-time (Socket.io)
- Initialized in `config/socket.js`, attached to HTTP server in `server.js`
- Auth via token in handshake auth
- Events: `joinConversation`, `sendMessage`, `typing`, `readReceipt`

### Scheduler
- `services/scheduler.js` (cron jobs) started in `server.js`
- Handles booking reminders, status transitions

---

## Conventions

### Code Style
- ES Modules (`"type": "module"` in package.json)
- `async/await` with try/catch in controllers
- Response format: `{ success: boolean, data?: any, message?: string }`
- Controllers in `controllers/`, routes in `routes/`, models in `models/`
- Swagger JSDoc comments inline in route files

### Naming
- Tables: PascalCase (`Users`, `Bookings`, `Expertise`)
- Models: PascalCase files (`User.js`, `Booking.js`)
- Routes/Controllers: snake_case files, PascalCase exports

### Database
- `models/index.js` exports all models + `syncDB()` (called in `server.js`)
- `syncDB()` is **environment-gated**: `alter: true` only in `development`/`test`; production runs `sync()` with no options (safe — creates missing tables, never alters or drops columns)
- Migrations: none (schema managed via `expert-on-floor.sql` dump for prod changes)

---

## Known Quirks / Gotchas

| Issue | Details |
|-------|---------|
| No test suite | `npm test` exits with error — add Jest/Vitest if needed |
| No lint/format config | No ESLint/Prettier — add if team requires |
| `alter: true` gated | `sequelize.sync({ alter: true })` only runs in `development`/`test`; production uses safe `sync()` — fixed in `models/index.js` |
| `.env` has real secrets | `.env` is committed in this repo — rotate keys before deploying |
| Swagger paths use `/v1` | Code routes don't have `/v1` prefix; Swagger spec does |
| Dual DB connections | MySQL via Sequelize, MongoDB via Mongoose — both init in `server.js` |
| Flutter app name | `pubspec.yaml` name is `flutter_application_1` — rename if publishing |
| No `.env.example` | Create one from the template above for onboarding |

---

## File Map (Key Entry Points)
```
server.js                 # Express app, DB sync, Socket.io, Swagger, Scheduler
config/database.js        # Sequelize (MySQL) connection
config/socket.js          # Socket.io setup + auth
models/index.js           # All Sequelize models + associations + syncDB()
middleware/auth.js        # JWT + role middleware
routes/*.js               # API route groups
controllers/*.js          # Business logic
services/scheduler.js     # Cron jobs (node-cron)
uploads/                  # Multer uploads (gitignored)
frontend/                 # Flutter app (separate pubspec.yaml)
```

---

## Useful Queries for Agents
- **Run dev server**: `npm run dev` (port 5000)
- **API base**: `http://localhost:5000/api` (routes) / `/v1` (Swagger)
- **Swagger**: `http://localhost:5000/api-docs`
- **DB sync**: runs automatically on `npm run dev` via `syncDB()`
- **Flutter**: `cd frontend && flutter run`