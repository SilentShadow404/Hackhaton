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
const { asyncHandler } = require("../middleware/asyncHandler");

const router = express.Router();

router.get("/health", healthCheck);
router.get("/api/v1/auth/me", authMiddleware, asyncHandler(getCurrentUser));
router.post("/api/v1/businesses/bootstrap", authMiddleware, asyncHandler(bootstrapBusiness));
router.get("/api/v1/businesses/:businessId/dashboard/summary", authMiddleware, asyncHandler(getDashboardSummary));
router.get("/api/v1/businesses/:businessId/dashboard/forecast", authMiddleware, asyncHandler(getCashForecast));
router.post("/api/v1/businesses/:businessId/sales", authMiddleware, asyncHandler(addSale));
router.get("/api/v1/businesses/:businessId/sales", authMiddleware, asyncHandler(listSales));
router.patch("/api/v1/businesses/:businessId/sales/:saleId", authMiddleware, asyncHandler(updateSale));

router.post("/api/v1/businesses/:businessId/expenses", authMiddleware, asyncHandler(addExpense));
router.get("/api/v1/businesses/:businessId/expenses", authMiddleware, asyncHandler(listExpenses));
router.patch("/api/v1/businesses/:businessId/expenses/:expenseId", authMiddleware, asyncHandler(updateExpense));

router.post("/api/v1/businesses/:businessId/receivables", authMiddleware, asyncHandler(addReceivable));
router.get("/api/v1/businesses/:businessId/receivables", authMiddleware, asyncHandler(listReceivables));
router.post(
	"/api/v1/businesses/:businessId/receivables/:receivableId/mark-paid",
	authMiddleware,
	asyncHandler(markReceivablePaid)
);
router.get(
	"/api/v1/businesses/:businessId/receivables/:receivableId/whatsapp-link",
	authMiddleware,
	asyncHandler(getReceivableWhatsappLink)
);

router.post("/api/v1/businesses/:businessId/payables", authMiddleware, asyncHandler(addPayable));
router.get("/api/v1/businesses/:businessId/payables", authMiddleware, asyncHandler(listPayables));
router.post(
	"/api/v1/businesses/:businessId/payables/:payableId/mark-paid",
	authMiddleware,
	asyncHandler(markPayablePaid)
);

module.exports = router;
