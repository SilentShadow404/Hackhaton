function healthCheck(req, res) {
  return res.status(200).json({
    status: "ok",
    service: "sme-cashflow-backend",
    timestamp: new Date().toISOString(),
  });
}

module.exports = {
  healthCheck,
};
