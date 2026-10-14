import { initializeApp, cert } from "firebase-admin/app";
import fs from "fs";
import path from "path";
import { fileURLToPath } from "url";

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);

const serviceAccountPath = path.join(__dirname, "firebase-service-account.json");

let firebaseAdmin = null;

try {
  if (fs.existsSync(serviceAccountPath)) {
    const serviceAccount = JSON.parse(
      fs.readFileSync(serviceAccountPath, "utf8")
    );

    firebaseAdmin = initializeApp({
      credential: cert(serviceAccount),
    });

    console.log("✅ Firebase Admin SDK initialized successfully.");
  } else {
    console.warn("⚠️ firebase-service-account.json not found.");
  }
} catch (error) {
  console.error("❌ Firebase initialization failed:", error);
}

export default firebaseAdmin;