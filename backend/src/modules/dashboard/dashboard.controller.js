const { db } = require("../../config/firebaseAdmin");

function getMonthKey(date = new Date()) {
  const year = date.getFullYear();
  const month = String(date.getMonth() + 1).padStart(2, "0");
  return `${year}-${month}`;
}

function sumAmounts(snapshot) {
  return snapshot.docs.reduce((acc, doc) => acc + Number(doc.data().amount || 0), 0);
}

async function getDashboardSummary(req, res) {
  if (!db) {
    return res.status(400).json({ message: "Firestore is not available in mock mode" });
  }

  const { businessId } = req.params;
  const monthKey = req.query.month || getMonthKey();
  const businessRef = db.collection("businesses").doc(businessId);
  const businessDoc = await businessRef.get();

  if (!businessDoc.exists) {
    return res.status(404).json({ message: "Business not found" });
  }

  const business = businessDoc.data();
  const startingBalance = Number(business.startingBalance || 0);

  const [salesSnap, expensesSnap, receivablesSnap, payablesSnap] = await Promise.all([
    businessRef.collection("sales").where("monthKey", "==", monthKey).get(),
    businessRef.collection("expenses").where("monthKey", "==", monthKey).get(),
    businessRef.collection("receivables").where("status", "in", ["pending", "overdue"]).get(),
    businessRef.collection("payables").where("status", "in", ["pending", "overdue"]).get(),
  ]);

  const totalSales = sumAmounts(salesSnap);
  const totalExpenses = sumAmounts(expensesSnap);
  const pendingReceivables = sumAmounts(receivablesSnap);
  const pendingPayables = sumAmounts(payablesSnap);

  const currentCash = startingBalance + totalSales - totalExpenses;
  const expectedCash = currentCash + pendingReceivables - pendingPayables;
  const burnRatePerDay = totalExpenses > 0 ? totalExpenses / 30 : 0;
  const runwayDays = burnRatePerDay > 0 ? currentCash / burnRatePerDay : null;

  return res.status(200).json({
    businessId,
    monthKey,
    startingBalance,
    totalSales,
    totalExpenses,
    pendingReceivables,
    pendingPayables,
    currentCash,
    expectedCash,
    runwayDays,
  });
}

async function getCashForecast(req, res) {
  if (!db) {
    return res.status(400).json({ message: "Firestore is not available in mock mode" });
  }

  const { businessId } = req.params;
  const days = Math.min(Number(req.query.days || 7), 14);
  const monthKey = getMonthKey();
  const businessRef = db.collection("businesses").doc(businessId);
  const businessDoc = await businessRef.get();

  if (!businessDoc.exists) {
    return res.status(404).json({ message: "Business not found" });
  }

  const business = businessDoc.data();
  const startingBalance = Number(business.startingBalance || 0);

  const [salesSnap, expensesSnap, receivablesSnap, payablesSnap] = await Promise.all([
    businessRef.collection("sales").where("monthKey", "==", monthKey).get(),
    businessRef.collection("expenses").where("monthKey", "==", monthKey).get(),
    businessRef.collection("receivables").where("status", "in", ["pending", "overdue"]).get(),
    businessRef.collection("payables").where("status", "in", ["pending", "overdue"]).get(),
  ]);

  const totalSales = sumAmounts(salesSnap);
  const totalExpenses = sumAmounts(expensesSnap);
  const currentCash = startingBalance + totalSales - totalExpenses;

  const receivables = receivablesSnap.docs.map((d) => d.data());
  const payables = payablesSnap.docs.map((d) => d.data());

  const points = [];
  let runningCash = currentCash;
  const now = new Date();

  for (let i = 0; i <= days; i += 1) {
    const day = new Date(now);
    day.setDate(day.getDate() + i);
    const dayKey = day.toISOString().split("T")[0];

    const inflow = receivables
      .filter((r) => r.dueDate?.toDate && r.dueDate.toDate().toISOString().startsWith(dayKey))
      .reduce((acc, r) => acc + Number(r.amount || 0), 0);

    const outflow = payables
      .filter((p) => p.dueDate?.toDate && p.dueDate.toDate().toISOString().startsWith(dayKey))
      .reduce((acc, p) => acc + Number(p.amount || 0), 0);

    runningCash = runningCash + inflow - outflow;
    points.push({
      dayOffset: i,
      date: dayKey,
      inflow,
      outflow,
      cash: runningCash,
      isNegative: runningCash < 0,
    });
  }

  return res.status(200).json({
    businessId,
    currentCash,
    points,
  });
}

module.exports = {
  getDashboardSummary,
  getCashForecast,
};
