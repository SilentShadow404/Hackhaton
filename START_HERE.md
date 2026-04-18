# Start Here (Zero to Running)

You said you are starting from an empty folder. This guide is written for exactly that.

## 1) What is already prepared

- `backend/` Node.js API scaffold is ready.
- `app/` Flutter project scaffold is created.
- Backend supports `AUTH_MODE=mock` so you can run now without Firebase.

## 2) Run backend now (no Firebase yet)

Open PowerShell:

```powershell
cd e:\Hackhaton\backend
copy .env.example .env
npm.cmd install
npm.cmd run dev
```

Test health:

```powershell
curl http://localhost:4000/health
```

Test protected route in mock mode:

```powershell
curl -H "Authorization: Bearer demo-token" http://localhost:4000/api/v1/auth/me
```

## 3) Create Firebase project (when ready)

Install/login already prepared for CLI. Run:

```powershell
firebase.cmd login
firebase.cmd projects:create sme-cashflow-hackathon --display-name "SME Cashflow Hackathon"
firebase.cmd use sme-cashflow-hackathon
```

Then in Firebase Console:

- Enable Authentication: Email/Password
- Create Firestore database (production mode is fine for now)

Then create a service account key:

- Firebase Console -> Project Settings -> Service accounts -> Generate new private key
- Copy these values into `backend/.env`:
  - `FIREBASE_PROJECT_ID`
  - `FIREBASE_CLIENT_EMAIL`
  - `FIREBASE_PRIVATE_KEY` (with escaped `\\n` as in `.env.example`)

Then switch backend mode:

- In `backend/.env`, set `AUTH_MODE=firebase`
- Restart backend.

## 4) Run Flutter app now

```powershell
cd e:\Hackhaton\app
flutter pub get
flutter run
```

If your backend runs on a non-default port (for example `4001`), pass it explicitly:

```powershell
flutter run --dart-define=API_BASE_URL=http://localhost:4001
```

## 5) Next build phase

After this, we wire Flutter Auth screens to Firebase Auth and integrate token-based calls to backend.
