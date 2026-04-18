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

function parseDateOrNow(input) {
  return input ? new Date(input) : new Date();
}

function isDueOver(dueDate) {
  return dueDate.getTime() < Date.now();
}

async function addPayable(req, res) {
  if (!db) {
    return res.status(400).json({ message: "Firestore is not available in mock mode" });
  }

  const { businessId } = req.params;
  const { vendorName, amount, dueDate, category, description } = req.body;

  if (!vendorName || Number(amount) <= 0 || !dueDate) {
    return res.status(400).json({ message: "vendorName, amount, and dueDate are required" });
  }

  const businessCtx = await getBusinessOrThrow(businessId);
  if (!businessCtx) {
    return res.status(404).json({ message: "Business not found" });
  }

  if (businessCtx.businessDoc.data().ownerUid !== req.user.uid) {
    return res.status(403).json({ message: "Access denied" });
  }

  const due = parseDateOrNow(dueDate);
  const billDate = new Date();
  const now = admin.firestore.FieldValue.serverTimestamp();
  const ref = businessCtx.businessRef.collection("payables").doc();

  await ref.set({
    vendorName,
    amount: Number(amount),
    dueDate: admin.firestore.Timestamp.fromDate(due),
    billDate: admin.firestore.Timestamp.fromDate(billDate),
    category: category || "other",
    description: description || "",
    status: isDueOver(due) ? "overdue" : "pending",
    paidAt: null,
    settledExpenseId: null,
    createdBy: req.user.uid,
    createdAt: now,
    updatedAt: now,
    monthKey: getMonthKey(billDate),
  });

  return res.status(201).json({ payableId: ref.id });
}

async function listPayables(req, res) {
  if (!db) {
    return res.status(400).json({ message: "Firestore is not available in mock mode" });
  }

  const { businessId } = req.params;
  const status = req.query.status;
  const businessCtx = await getBusinessOrThrow(businessId);

  if (!businessCtx) {
    return res.status(404).json({ message: "Business not found" });
  }

  if (businessCtx.businessDoc.data().ownerUid !== req.user.uid) {
    return res.status(403).json({ message: "Access denied" });
  }

  let query = businessCtx.businessRef.collection("payables");
  if (status) {
    query = query.where("status", "==", status);
  }

  const snapshot = await query.get();
  const items = snapshot.docs
    .map((doc) => {
      const data = doc.data();
      const dueDate = data.dueDate?.toDate ? data.dueDate.toDate() : null;
      const dynamicStatus =
        data.status === "pending" && dueDate && dueDate.getTime() < Date.now() ? "overdue" : data.status;

      return {
        id: doc.id,
        vendorName: data.vendorName || "",
        amount: Number(data.amount || 0),
        dueDate: dueDate ? dueDate.toISOString() : null,
        category: data.category || "other",
        description: data.description || "",
        status: dynamicStatus,
      };
    })
    .sort((a, b) => new Date(a.dueDate || 0).getTime() - new Date(b.dueDate || 0).getTime());

  return res.status(200).json({ items });
}

async function markPayablePaid(req, res) {
  if (!db) {
    return res.status(400).json({ message: "Firestore is not available in mock mode" });
  }

  const { businessId, payableId } = req.params;
  const businessCtx = await getBusinessOrThrow(businessId);

  if (!businessCtx) {
    return res.status(404).json({ message: "Business not found" });
  }

  if (businessCtx.businessDoc.data().ownerUid !== req.user.uid) {
    return res.status(403).json({ message: "Access denied" });
  }

  const payableRef = businessCtx.businessRef.collection("payables").doc(payableId);
  const expenseRef = businessCtx.businessRef.collection("expenses").doc();

  await db.runTransaction(async (tx) => {
    const payableDoc = await tx.get(payableRef);
    if (!payableDoc.exists) {
      throw new Error("Payable not found");
    }

    const payable = payableDoc.data();
    if (payable.status === "paid") {
      return;
    }

    const nowDate = new Date();
    const now = admin.firestore.FieldValue.serverTimestamp();

    tx.set(
      expenseRef,
      {
        amount: Number(payable.amount || 0),
        date: admin.firestore.Timestamp.fromDate(nowDate),
        category: payable.category || "other",
        description: `Payable settled: ${payable.vendorName || "Vendor"}`,
        source: "payable_settlement",
        linkedPayableId: payableId,
        createdBy: req.user.uid,
        createdAt: now,
        updatedAt: now,
        monthKey: getMonthKey(nowDate),
      },
      { merge: true }
    );

    tx.set(
      payableRef,
      {
        status: "paid",
        paidAt: now,
        settledExpenseId: expenseRef.id,
        updatedAt: now,
      },
      { merge: true }
    );
  });

  return res.status(200).json({ ok: true });
}

module.exports = {
  addPayable,
  listPayables,
  markPayablePaid,
};
