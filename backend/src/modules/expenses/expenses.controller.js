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

async function addExpense(req, res) {
  if (!db) {
    return res.status(400).json({ message: "Firestore is not available in mock mode" });
  }

  const { businessId } = req.params;
  const { amount, date, category, description } = req.body;

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
  const expenseRef = businessCtx.businessRef.collection("expenses").doc();

  await expenseRef.set({
    amount: Number(amount),
    date: admin.firestore.Timestamp.fromDate(parsedDate),
    category: category || "other",
    description: description || "Manual expense",
    source: "manual",
    linkedPayableId: null,
    createdBy: req.user.uid,
    createdAt: now,
    updatedAt: now,
    monthKey: getMonthKey(parsedDate),
  });

  return res.status(201).json({ expenseId: expenseRef.id });
}

async function listExpenses(req, res) {
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
    .collection("expenses")
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
      category: data.category || "other",
      description: data.description || "",
      monthKey: data.monthKey || monthKey,
    };
  });

  return res.status(200).json({ items });
}

async function updateExpense(req, res) {
  if (!db) {
    return res.status(400).json({ message: "Firestore is not available in mock mode" });
  }

  const { businessId, expenseId } = req.params;
  const { amount, date, category, description } = req.body;

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

  if (category !== undefined) {
    updateData.category = category;
  }

  if (date) {
    const parsedDate = new Date(date);
    updateData.date = admin.firestore.Timestamp.fromDate(parsedDate);
    updateData.monthKey = getMonthKey(parsedDate);
  }

  await businessCtx.businessRef.collection("expenses").doc(expenseId).set(updateData, { merge: true });

  return res.status(200).json({ ok: true });
}

module.exports = {
  addExpense,
  listExpenses,
  updateExpense,
};
