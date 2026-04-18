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

async function addReceivable(req, res) {
  if (!db) {
    return res.status(400).json({ message: "Firestore is not available in mock mode" });
  }

  const { businessId } = req.params;
  const { customerName, customerPhoneE164, amount, dueDate, description } = req.body;

  if (!customerName || Number(amount) <= 0 || !dueDate) {
    return res.status(400).json({ message: "customerName, amount, and dueDate are required" });
  }

  const businessCtx = await getBusinessOrThrow(businessId);
  if (!businessCtx) {
    return res.status(404).json({ message: "Business not found" });
  }

  if (businessCtx.businessDoc.data().ownerUid !== req.user.uid) {
    return res.status(403).json({ message: "Access denied" });
  }

  const due = parseDateOrNow(dueDate);
  if (Number.isNaN(due.getTime())) {
    return res.status(400).json({ message: "Invalid dueDate" });
  }
  const invoiceDate = new Date();
  const now = admin.firestore.FieldValue.serverTimestamp();
  const ref = businessCtx.businessRef.collection("receivables").doc();

  await ref.set({
    customerName,
    customerPhoneE164: customerPhoneE164 || "",
    amount: Number(amount),
    dueDate: admin.firestore.Timestamp.fromDate(due),
    invoiceDate: admin.firestore.Timestamp.fromDate(invoiceDate),
    description: description || "",
    status: isDueOver(due) ? "overdue" : "pending",
    paidAt: null,
    settledSaleId: null,
    createdBy: req.user.uid,
    createdAt: now,
    updatedAt: now,
    monthKey: getMonthKey(invoiceDate),
  });

  return res.status(201).json({ receivableId: ref.id });
}

async function listReceivables(req, res) {
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

  let query = businessCtx.businessRef.collection("receivables");
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
        customerName: data.customerName || "",
        customerPhoneE164: data.customerPhoneE164 || "",
        amount: Number(data.amount || 0),
        dueDate: dueDate ? dueDate.toISOString() : null,
        description: data.description || "",
        status: dynamicStatus,
      };
    })
    .sort((a, b) => new Date(a.dueDate || 0).getTime() - new Date(b.dueDate || 0).getTime());

  return res.status(200).json({ items });
}

async function markReceivablePaid(req, res) {
  if (!db) {
    return res.status(400).json({ message: "Firestore is not available in mock mode" });
  }

  const { businessId, receivableId } = req.params;
  const businessCtx = await getBusinessOrThrow(businessId);

  if (!businessCtx) {
    return res.status(404).json({ message: "Business not found" });
  }

  if (businessCtx.businessDoc.data().ownerUid !== req.user.uid) {
    return res.status(403).json({ message: "Access denied" });
  }

  const receivableRef = businessCtx.businessRef.collection("receivables").doc(receivableId);
  const salesRef = businessCtx.businessRef.collection("sales").doc();

  await db.runTransaction(async (tx) => {
    const receivableDoc = await tx.get(receivableRef);
    if (!receivableDoc.exists) {
      const error = new Error("Receivable not found");
      error.status = 404;
      throw error;
    }

    const receivable = receivableDoc.data();
    if (receivable.status === "paid") {
      return;
    }

    const nowDate = new Date();
    const now = admin.firestore.FieldValue.serverTimestamp();

    tx.set(
      salesRef,
      {
        amount: Number(receivable.amount || 0),
        date: admin.firestore.Timestamp.fromDate(nowDate),
        description: `Receivable settled: ${receivable.customerName || "Customer"}`,
        source: "receivable_settlement",
        linkedReceivableId: receivableId,
        createdBy: req.user.uid,
        createdAt: now,
        updatedAt: now,
        monthKey: getMonthKey(nowDate),
      },
      { merge: true }
    );

    tx.set(
      receivableRef,
      {
        status: "paid",
        paidAt: now,
        settledSaleId: salesRef.id,
        updatedAt: now,
      },
      { merge: true }
    );
  });

  return res.status(200).json({ ok: true });
}

async function getReceivableWhatsappLink(req, res) {
  if (!db) {
    return res.status(400).json({ message: "Firestore is not available in mock mode" });
  }

  const { businessId, receivableId } = req.params;
  const businessCtx = await getBusinessOrThrow(businessId);

  if (!businessCtx) {
    return res.status(404).json({ message: "Business not found" });
  }

  if (businessCtx.businessDoc.data().ownerUid !== req.user.uid) {
    return res.status(403).json({ message: "Access denied" });
  }

  const receivableDoc = await businessCtx.businessRef.collection("receivables").doc(receivableId).get();
  if (!receivableDoc.exists) {
    return res.status(404).json({ message: "Receivable not found" });
  }

  const receivable = receivableDoc.data();
  const phone = String(receivable.customerPhoneE164 || "").replace(/[^0-9]/g, "");
  if (!phone) {
    return res.status(400).json({ message: "Customer phone is missing" });
  }

  const dueDate = receivable.dueDate?.toDate ? receivable.dueDate.toDate().toISOString().split("T")[0] : "";
  const message = `Hi ${receivable.customerName || "there"}, this is a gentle reminder that an amount of INR ${Number(
    receivable.amount || 0
  ).toFixed(0)} is due on ${dueDate}. Please share payment update. Thank you.`;

  const waLink = `https://wa.me/${phone}?text=${encodeURIComponent(message)}`;

  return res.status(200).json({ waLink });
}

module.exports = {
  addReceivable,
  listReceivables,
  markReceivablePaid,
  getReceivableWhatsappLink,
};
