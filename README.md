# angoothape

```
angoothape/
  angoothape-frontend/    Flutter retailer app
  angoothape-backend/     Express + PostgreSQL API
```

## Demo login

| Field | Value |
| --- | --- |
| Partner ID | `AP100245` |
| Password | `Demo@123` |
| Email OTP | shown on the MFA screen when `DEV_RETURN_OTP=1` (also emailed / logged by the API) |
| Authenticator | scan the QR on first login, then enter the 6-digit PIN |

## Backend

Needs Docker (Postgres) and Node 20+.

```bash
cd angoothape-backend
cp .env.example .env
docker compose up -d
npm install
npm run migrate
npm run seed
npm run dev
```

API: http://localhost:8080

## Frontend

```bash
cd angoothape-frontend
flutter pub get
flutter run --dart-define=API_BASE=http://localhost:8080
```

Web:

```bash
cd angoothape-frontend
flutter run -d chrome --dart-define=API_BASE=http://localhost:8080
```

## Firebase Hosting

```bash
cd angoothape-frontend
flutter build web --release --dart-define=API_BASE=https://YOUR-API-HOST
firebase deploy --only hosting
```
