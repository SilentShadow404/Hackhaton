const app = require("./app");
const env = require("./config/env");

if (env.authMode === "firebase") {
  require("./config/firebaseAdmin");
}

app.listen(env.port, () => {
  // eslint-disable-next-line no-console
  console.log(`Backend running on port ${env.port} (auth mode: ${env.authMode})`);
});
