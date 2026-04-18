const admin = require("firebase-admin");
const env = require("./env");

if (env.authMode === "firebase" && !admin.apps.length) {
  admin.initializeApp({
    credential: admin.credential.cert({
      projectId: env.firebaseProjectId,
      clientEmail: env.firebaseClientEmail,
      privateKey: env.firebasePrivateKey,
    }),
  });
}

const auth = env.authMode === "firebase" ? admin.auth() : null;
const db = env.authMode === "firebase" ? admin.firestore() : null;

module.exports = {
  admin,
  auth,
  db,
};
