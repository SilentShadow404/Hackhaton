const { db, admin } = require("../../config/firebaseAdmin");

async function bootstrapBusiness(req, res) {
  if (!db) {
    return res.status(400).json({ message: "Firestore is not available in mock mode" });
  }

  const { uid, email } = req.user;
  const businessesRef = db.collection("businesses");

  const existingSnapshot = await businessesRef.where("ownerUid", "==", uid).limit(1).get();
  if (!existingSnapshot.empty) {
    const businessDoc = existingSnapshot.docs[0];
    return res.status(200).json({
      businessId: businessDoc.id,
      name: businessDoc.data().name,
    });
  }

  const now = admin.firestore.FieldValue.serverTimestamp();
  const businessRef = businessesRef.doc();

  await businessRef.set({
    name: "My SME Business",
    ownerUid: uid,
    currency: "INR",
    timezone: "Asia/Karachi",
    startingBalance: 100000,
    createdAt: now,
    updatedAt: now,
  });

  await businessRef.collection("members").doc(uid).set({
    role: "owner",
    displayName: email ? email.split("@")[0] : "Owner",
    email: email || null,
    createdAt: now,
  });

  return res.status(201).json({
    businessId: businessRef.id,
    name: "My SME Business",
  });
}

module.exports = {
  bootstrapBusiness,
};
