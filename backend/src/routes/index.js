const express = require("express");
const { healthCheck } = require("../modules/health/health.controller");
const { getCurrentUser } = require("../modules/auth/auth.controller");
const { bootstrapBusiness } = require("../modules/business/business.controller");
const { getDashboardSummary, getCashForecast } = require("../modules/dashboard/dashboard.controller");
const { addSale, listSales, updateSale } = require("../modules/sales/sales.controller");
const { addExpense, listExpenses, updateExpense } = require("../modules/expenses/expenses.controller");
const {
	addReceivable,
	listReceivables,
	markReceivablePaid,
	getReceivableWhatsappLink,
} = require("../modules/receivables/receivables.controller");
const { addPayable, listPayables, markPayablePaid } = require("../modules/payables/payables.controller");
const { authMiddleware } = require("../middleware/authMiddleware");

const router = express.Router();

router.get("/health", healthCheck);
router.get("/api/v1/auth/me", authMiddleware, getCurrentUser);
router.post("/api/v1/businesses/bootstrap", authMiddleware, bootstrapBusiness);
router.get("/api/v1/businesses/:businessId/dashboard/summary", authMiddleware, getDashboardSummary);
router.get("/api/v1/businesses/:businessId/dashboard/forecast", authMiddleware, getCashForecast);
router.post("/api/v1/businesses/:businessId/sales", authMiddleware, addSale);
router.get("/api/v1/businesses/:businessId/sales", authMiddleware, listSales);
router.patch("/api/v1/businesses/:businessId/sales/:saleId", authMiddleware, updateSale);

router.post("/api/v1/businesses/:businessId/expenses", authMiddleware, addExpense);
router.get("/api/v1/businesses/:businessId/expenses", authMiddleware, listExpenses);
router.patch("/api/v1/businesses/:businessId/expenses/:expenseId", authMiddleware, updateExpense);

router.post("/api/v1/businesses/:businessId/receivables", authMiddleware, addReceivable);
router.get("/api/v1/businesses/:businessId/receivables", authMiddleware, listReceivables);
router.post(
	"/api/v1/businesses/:businessId/receivables/:receivableId/mark-paid",
	authMiddleware,
	markReceivablePaid
);
router.get(
	"/api/v1/businesses/:businessId/receivables/:receivableId/whatsapp-link",
	authMiddleware,
	getReceivableWhatsappLink
);

router.post("/api/v1/businesses/:businessId/payables", authMiddleware, addPayable);
router.get("/api/v1/businesses/:businessId/payables", authMiddleware, listPayables);
router.post("/api/v1/businesses/:businessId/payables/:payableId/mark-paid", authMiddleware, markPayablePaid);

module.exports = router;
