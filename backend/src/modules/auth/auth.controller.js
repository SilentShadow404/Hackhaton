const { db } = require("../../config/firebaseAdmin");

async function getCurrentUser(req, res) {
  let businessId = null;

  if (db) {
    const businesses = await db
      .collection("businesses")
      .where("ownerUid", "==", req.user.uid)
      .limit(1)
      .get();

    if (!businesses.empty) {
      businessId = businesses.docs[0].id;
    }
  }

  return res.status(200).json({
    uid: req.user.uid,
    email: req.user.email,
    businessId,
  });
}

module.exports = {
  getCurrentUser,
};
