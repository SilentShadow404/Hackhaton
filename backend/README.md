# SME Cash Flow Backend (Phase 1)

## What is included

- Express server bootstrap
- Firebase Admin initialization
- Auth middleware to verify Firebase ID tokens
- Health endpoint
- Protected `auth/me` endpoint

## Setup

1. Copy `.env.example` to `.env`
2. Fill in Firebase Admin values in `.env`
3. Install dependencies
4. Start server

```bash
npm install
npm run dev
```

## Endpoints

- `GET /health`
  - Public health check
- `GET /api/v1/auth/me`
  - Protected route
  - Requires header: `Authorization: Bearer <firebase_id_token>`

## Quick test

```bash
curl http://localhost:4000/health
```
