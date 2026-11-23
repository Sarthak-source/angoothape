# angoothape-backend

Express + PostgreSQL API. Same Node style as WorkerAppz chat-app (ESM, helmet, JWT) with Postgres instead of Mongo.

## Run

```bash
cp .env.example .env
docker compose up -d
npm install
npm run migrate
npm run seed
npm run dev
```

## Routes

| Method | Path | Auth |
| --- | --- | --- |
| POST | `/auth/login` | public |
| POST | `/auth/otp` | public |
| POST | `/auth/resend` | public |
| POST | `/auth/logout` | cookie |
| GET | `/catalog` | public |
| POST | `/join` | public |
| POST | `/join/:id/approve` | public (demo) |
| POST | `/join/ekyc` | public |
| POST | `/auth/forgot` | public |
| POST | `/auth/forgot/confirm` | public |
| PATCH | `/api/me` | JWT |
| PATCH | `/api/me/preferences` | JWT |
| POST | `/api/me/password` | JWT |
| GET | `/api/device` | JWT |
| PATCH | `/api/device` | JWT |
| POST | `/api/device/test` | JWT |
| POST | `/api/device/requests` | JWT |
| POST | `/api/wallet/topup` | JWT |
| POST | `/api/exports` | JWT |
| POST | `/api/receipts/:ref/actions` | JWT |
| GET | `/api/me` | JWT |
| GET | `/api/transactions` | JWT |
| GET | `/api/transactions/:ref` | JWT |
| POST | `/api/aeps` | JWT |
| POST | `/api/transactions/:ref/check` | JWT |
| POST | `/api/settlements` | JWT |
| POST | `/api/accounts` | JWT |
| POST | `/api/tickets` | JWT |
| POST | `/api/demo/reset` | JWT (demo retailer) |

`POST /auth/login` body: `{ "partnerId", "password" }`.  
In development (`DEV_RETURN_OTP=1`) the JSON includes `otp` so the Flutter demo screen can show it. Production must leave that flag off; OTP goes to SMS later.
