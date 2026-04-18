const { db, admin } = require("../../config/firebaseAdmin");

function getMonthKey(date = new Date()) {
  const year = date.getFullYear();
  const month = String(date.getMonth() + 1).padStart(2, "0");
  return `${year}-${month}`;
}

async function getBusinessOrThrow(businessId) {
  const businessRef = db.collection("businesses").doc(businessId);
  const businessDoc = await businessRef.get();

  if (!businessDoc.exists) {
    return null;
  }

  return { businessRef, businessDoc };
}

async function addSale(req, res) {
  if (!db) {
    return res.status(400).json({ message: "Firestore is not available in mock mode" });
  }

  const { businessId } = req.params;
  const { amount, date, description } = req.body;

  if (!amount || Number(amount) <= 0) {
    return res.status(400).json({ message: "Amount must be greater than 0" });
  }

  const businessCtx = await getBusinessOrThrow(businessId);
  if (!businessCtx) {
    return res.status(404).json({ message: "Business not found" });
  }

  const ownerUid = businessCtx.businessDoc.data().ownerUid;
  if (ownerUid !== req.user.uid) {
    return res.status(403).json({ message: "Access denied" });
  }

  const parsedDate = date ? new Date(date) : new Date();
  const now = admin.firestore.FieldValue.serverTimestamp();
  const salesRef = businessCtx.businessRef.collection("sales").doc();

  await salesRef.set({
    amount: Number(amount),
    date: admin.firestore.Timestamp.fromDate(parsedDate),
    description: description || "Manual sale",
    source: "manual",
    linkedReceivableId: null,
    createdBy: req.user.uid,
    createdAt: now,
    updatedAt: now,
    monthKey: getMonthKey(parsedDate),
  });

  return res.status(201).json({ saleId: salesRef.id });
}

async function listSales(req, res) {
  if (!db) {
    return res.status(400).json({ message: "Firestore is not available in mock mode" });
  }

  const { businessId } = req.params;
  const monthKey = req.query.month || getMonthKey();

  const businessCtx = await getBusinessOrThrow(businessId);
  if (!businessCtx) {
    return res.status(404).json({ message: "Business not found" });
  }

  const ownerUid = businessCtx.businessDoc.data().ownerUid;
  if (ownerUid !== req.user.uid) {
    return res.status(403).json({ message: "Access denied" });
  }

  const snapshot = await businessCtx.businessRef
    .collection("sales")
    .where("monthKey", "==", monthKey)
    .orderBy("date", "desc")
    .limit(20)
    .get();

  const items = snapshot.docs.map((doc) => {
    const data = doc.data();
    return {
      id: doc.id,
      amount: Number(data.amount || 0),
      date: data.date?.toDate ? data.date.toDate().toISOString() : null,
      description: data.description || "",
      monthKey: data.monthKey || monthKey,
    };
  });

  return res.status(200).json({ items });
}

async function updateSale(req, res) {
  if (!db) {
    return res.status(400).json({ message: "Firestore is not available in mock mode" });
  }

  const { businessId, saleId } = req.params;
  const { amount, date, description } = req.body;

  const businessCtx = await getBusinessOrThrow(businessId);
  if (!businessCtx) {
    return res.status(404).json({ message: "Business not found" });
  }

  const ownerUid = businessCtx.businessDoc.data().ownerUid;
  if (ownerUid !== req.user.uid) {
    return res.status(403).json({ message: "Access denied" });
  }

  const updateData = {
    updatedAt: admin.firestore.FieldValue.serverTimestamp(),
  };

  if (amount !== undefined) {
    updateData.amount = Number(amount);
  }

  if (description !== undefined) {
    updateData.description = description;
  }

  if (date) {
    const parsedDate = new Date(date);
    updateData.date = admin.firestore.Timestamp.fromDate(parsedDate);
    updateData.monthKey = getMonthKey(parsedDate);
  }

  await businessCtx.businessRef.collection("sales").doc(saleId).set(updateData, { merge: true });

  return res.status(200).json({ ok: true });
}

module.exports = {
  addSale,
  listSales,
  updateSale,
};
