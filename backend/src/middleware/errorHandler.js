function notFoundHandler(req, res) {
  return res.status(404).json({ message: "Route not found" });
}

function errorHandler(err, req, res, next) {
  const status = err.status || 500;
  const message = err.message || "Internal server error";

  if (process.env.NODE_ENV !== "test") {
    // eslint-disable-next-line no-console
    console.error(err);
  }

  return res.status(status).json({ message });
}

module.exports = {
  notFoundHandler,
  errorHandler,
};
