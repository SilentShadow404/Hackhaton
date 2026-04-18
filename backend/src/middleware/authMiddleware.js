const { auth } = require("../config/firebaseAdmin");
const env = require("../config/env");

async function authMiddleware(req, res, next) {
  try {
    const header = req.headers.authorization || "";
    const [scheme, token] = header.split(" ");

    if (scheme !== "Bearer" || !token) {
      return res.status(401).json({ message: "Missing or invalid authorization header" });
    }

    if (env.authMode === "mock") {
      if (token !== "demo-token") {
        return res.status(401).json({ message: "Invalid demo token" });
      }

      req.user = {
        uid: "demo-user",
        email: "demo@sme.local",
      };

      return next();
    }

    const decodedToken = await auth.verifyIdToken(token);
    req.user = {
      uid: decodedToken.uid,
      email: decodedToken.email || null,
    };

    return next();
  } catch (error) {
    return res.status(401).json({ message: "Invalid or expired token" });
  }
}

module.exports = {
  authMiddleware,
};
