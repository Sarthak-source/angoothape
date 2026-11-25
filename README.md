# angoothaPe

Retailer app for AEPS-style cash withdrawal, wallet, history, and support.

```
angoothape/
  angoothape-frontend/    Flutter retailer app (web / mobile)
  angoothape-backend/     Express + PostgreSQL API
```

Auth is two tokens after password + authenticator PIN + email OTP:

- **JWT** (`token`) — `Authorization: Bearer` and cookie `ap_token`. Required on all `/api/*` routes.
- **MFA token** (`mfaToken`) — header `X-MFA-Token`. Required on money, identity, and device-changing routes.

Public (no JWT, no MFA): `/health`, `/catalog`, `/auth/*`, `/join` (signup).

JWT only: `GET /api/me`, `GET /api/transactions`, `GET /api/transactions/:ref`, `GET /api/device`, `PATCH /api/me/preferences`.

JWT **and** MFA token: AEPS, settlements, bank accounts, wallet top-up, pending txn check, tickets, device test/repair, receipt/export, profile update, password change, demo reset.

## Demo login

| Field | Value |
| --- | --- |
| Partner ID | `AP100245` |
| Password | `Demo@123` |
| Authenticator | First screen after password. Scan the QR on first login, then enter the 6-digit PIN. |
| Email OTP | Second screen. Shown in the UI when `DEV_RETURN_OTP=1` (also emailed, or logged by the API if SMTP is unset). |

## Run

**Backend** (Node 20+, Postgres). Docker Compose is the documented default; a local cluster on port `5433` also works if Docker is unavailable.

```bash
cd angoothape-backend
cp .env.example .env
docker compose up -d
npm install
npm run migrate
npm run seed
npm run dev
```

API: http://localhost:8080 · health: `GET /health`

| Script | What it does |
| --- | --- |
| `npm run dev` | Nodemon API on `:8080` |
| `npm start` | API without reload |
| `npm run migrate` | Apply `sql/schema.sql` |
| `npm run seed` | Demo retailer, banks, FAQs, sample txns |
| `npm run postman` | Write `docs/Angoothape-API.postman_collection.json` |

**Frontend**

```bash
cd angoothape-frontend
flutter pub get
flutter run --dart-define=API_BASE=http://localhost:8080
# web
flutter run -d chrome --dart-define=API_BASE=http://localhost:8080
```

```bash
flutter build web --release --dart-define=API_BASE=https://YOUR-API-HOST
firebase deploy --only hosting
```

---

# Backend

Express ESM app in `angoothape-backend`. Public routes: `/health`, `/auth/*`, `/catalog`, `/join*`. Everything under `/api` requires auth.

## HTTP API

### Health

| Method | Path | Function | What it does |
| --- | --- | --- | --- |
| GET | `/health` | inline in `app.js` | Liveness. `{ ok: true }`. No auth. |

### Auth (`src/controllers/auth.controller.js`)

JWT is issued only after **both** authenticator PIN and email OTP succeed.

| Method | Path | Function | What it does |
| --- | --- | --- | --- |
| POST | `/auth/login` | `login` | Checks partner ID + password. Starts MFA: emails a 6-digit OTP, returns TOTP challenge (QR on first enrol). No JWT yet. |
| POST | `/auth/totp` | `verifyTotp` | Checks the 6-digit authenticator PIN. Marks TOTP done. Does **not** issue JWT. |
| POST | `/auth/otp` | `verifyOtp` | Checks the email code. Requires TOTP already done. Issues JWT cookie + Bearer token. |
| POST | `/auth/resend` | `resendOtp` | Sends a new email OTP for the open challenge. Does not reset a completed TOTP step. |
| POST | `/auth/logout` | `logout` | Clears `ap_token`. |
| POST | `/auth/forgot` | `forgotPassword` | Emails a reset code (does not reveal whether the ID exists beyond 404). |
| POST | `/auth/forgot/confirm` | `confirmForgot` | Verifies reset code and sets a new password. |

Login helpers in the same file: `mfaBody` (challenge payload), `issueSession` (JWT + cookie), `createOtpChallenge`, `loadChallenge`, `finishIfReady`, `bumpFail`.

### Catalog (public)

| Method | Path | Function | What it does |
| --- | --- | --- | --- |
| GET | `/catalog` | `getCatalog` | Banks, FAQs, issue types, future services, device guides/FAQs, fail-reason copy (EN/HI). |

### Join / onboarding (public)

| Method | Path | Function | What it does |
| --- | --- | --- | --- |
| POST | `/join/ekyc` | `createEkyc` | Validates PAN, stores a simulated eKYC pass. |
| POST | `/join` | `createApplication` | Creates a partner application (`retailer` / `distributor` / `super`). |
| POST | `/join/:id/approve` | `approveApplication` | Marks that application approved (demo). |

### Session (`/api`, auth required)

| Method | Path | Function | What it does |
| --- | --- | --- | --- |
| GET | `/api/me` | `getMe` | Retailer profile, prefs, wallet, banks, settlements, tickets, recent txns. |
| PATCH | `/api/me` | `updateMe` | Updates name, shop, city, mobile. |
| PATCH | `/api/me/preferences` | `updatePreferences` | Language, dark mode, text scale. |
| POST | `/api/me/password` | `changePassword` | Verifies current password, hashes the new one. |
| POST | `/api/demo/reset` | `resetDemo` | Re-seeds demo data for the signed-in retailer. |

### AEPS

| Method | Path | Function | What it does |
| --- | --- | --- | --- |
| POST | `/api/aeps` | `submitAeps` | Records a cash-out / mini-statement / balance enquiry. Body can force `outcome` (`success` / `failed` / `pending` / `network`) for the prototype. Credits AEPS wallet + ₹5 earn on successful cash-out. |

### Transactions

| Method | Path | Function | What it does |
| --- | --- | --- | --- |
| GET | `/api/transactions` | `listTransactions` | Filter by `q`, `status`, `svc`, `range` (days). |
| GET | `/api/transactions/:ref` | `getTransaction` | One txn + mini-statement lines. |
| POST | `/api/transactions/:ref/check` | `checkTransaction` | Re-query a pending txn; may resolve to success/fail and credit wallet. |

### Wallet & banks

| Method | Path | Function | What it does |
| --- | --- | --- | --- |
| POST | `/api/settlements` | `createSettlement` | Moves amount from AEPS wallet to the primary bank (processing). |
| POST | `/api/accounts` | `addAccount` | Adds a settlement account from holder / account / IFSC. |
| POST | `/api/wallet/topup` | `topupWallet` | Credits main wallet (₹100–50000). |

### Tickets, device, receipts

| Method | Path | Function | What it does |
| --- | --- | --- | --- |
| POST | `/api/tickets` | `createTicket` | Opens a support ticket (`type`, `message`, optional txn `ref`). |
| GET | `/api/device` | `getDevice` | Scanner model, RD status, last test. |
| POST | `/api/device/test` | `testDevice` | Simulated capture test; stores a score. |
| PATCH | `/api/device` | `patchDevice` | Sets device state: `ready` / `disconnected` / `permission`. |
| POST | `/api/device/requests` | `deviceRequest` | Logs repair or order request. |
| POST | `/api/receipts/:ref/actions` | `receiptAction` | Logs print / share / download. |
| POST | `/api/exports` | `createExport` | Logs a CSV export request for a date range. |

## Backend modules (non-HTTP)

| File | Functions | What they do |
| --- | --- | --- |
| `src/totp.js` | `newTotpSecret`, `totpUri`, `totpQrDataUrl`, `totpOk`, `totpNow` | TOTP secret, otpauth URL, QR data URL, verify, current PIN (dev hint). |
| `src/mailer.js` | `maskEmail`, `sendOtpEmail` | Mask address; send via SMTP or log `[mail]` to the console. |
| `src/middleware/auth.js` | `signToken`, `setAuthCookie`, `clearAuthCookie`, `requireAuth` | JWT + `ap_token` cookie; Bearer or cookie on `/api`. |
| `src/middleware/error.js` | `fail`, `notFound`, `errorHandler` | Typed errors `{ code, message }`. |
| `src/db.js` | `query` | PostgreSQL pool. |
| `src/utils/tx.js` | `money`, `walletFrom`, `loadWallet`, `mapTx`, `attachMinis` | Wallet numbers and txn JSON with mini-statement lines. |
| `src/utils/asyncHandler.js` | `asyncHandler` | Forwards async route errors. |
| `src/requests.js` | `maskMobile`, `recordRequest` | Audit rows for exports, receipts, device, top-up. |
| `src/demo-seed.js` | `seedCatalog`, `seedDemoRetailer`, `insertMiniLines` | Banks/FAQs and demo retailer AP100245. |
| `src/migrate.js` | (script) | Applies schema. |
| `src/seed.js` | (script) | Runs catalog + demo seed. |
| `src/catalog-data.js` | static lists | Seed content for banks, FAQs, services. |

Auth on `/api/*`: `Authorization: Bearer <token>` **or** cookie `ap_token`.

---

# Frontend

Flutter app in `angoothape-frontend`. Features live under `lib/features/<module>/{data,domain,presentation}`. `AppController` (with `HomeController` + `JoinController` mixins) is the session brain; screens read it through `AppScope`.

`API_BASE` is compile-time (`--dart-define=API_BASE=...`). Token is stored with `flutter_secure_storage`.

## Screens

### Auth

| Screen | What it does |
| --- | --- |
| `WelcomeScreen` | Language + Log in / Become a partner. |
| `LoginScreen` | Partner ID + password. Calls `submitLogin` → MFA. |
| `MfaScreen` | QR (first enrol) + authenticator PIN. Calls `submitTotp` → email OTP. |
| `OtpScreen` | Email 6-digit code. Calls `submitOtp` → dashboard. |
| `ForgotScreen` | Partner ID; emails a reset code. |
| `ForgotConfirmScreen` | Reset code + new password. |
| `AuthHost` | Switches welcome / login / mfa / otp / forgot / join. |

### Onboarding

| Screen | What it does |
| --- | --- |
| `JoinScreen` | Role, shop/KYC, eKYC, docs, status. Steps: `RoleStep`, `BusinessStep`, `KycStep`, `StatusStep`. |

### Home

| Screen | What it does |
| --- | --- |
| `HomeShell` | Sidebar / bottom nav, demo ribbon, sheets. |
| `DashboardScreen` | Wallet snapshot, quick AEPS, recent txns. |
| `HistoryScreen` | Search / filter ledger. |
| `TxnScreen` | One transaction. |
| `WalletScreen` | Main / AEPS / earn, settle, top-up. |
| `BanksScreen` | Settlement accounts + add bank. |
| `LedgerScreen` | Alternate ledger layout (desktop-style). |

### AEPS

| Screen | What it does |
| --- | --- |
| `AepsScreen` | Host for the flow. |
| `AepsDetailsScreen` | Customer mobile, Aadhaar/VID, bank, amount, consent. |
| `AepsAuthScreen` | Fingerprint capture (simulated RD). |
| `AepsProcessingScreen` | Progress while the API runs. |
| `AepsResultScreen` | Success / fail / pending + receipt actions. |

### Support

| Screen | What it does |
| --- | --- |
| `HelpScreen` | FAQs. |
| `HelpNewScreen` | New support request form. |
| `TicketScreen` | Ticket confirmation. |
| `DeviceScreen` | Scanner status, test, repair/order. |
| `ProfileScreen` | Shop profile. |
| `MoreScreen` | Prefs: language, dark, text size, logout, reset demo. |
| `ServicesScreen` | Upcoming products (catalog). |
| `SupportScreen` | Shared support chrome / extra copy. |

## API clients (what the app calls)

| Client | Functions | Backend |
| --- | --- | --- |
| `AuthApi` | `login`, `verifyTotp`, `verifyOtp`, `resendOtp`, `logout`, `forgot`, `confirmForgot` | `/auth/*` |
| `SessionApi` | `catalog`, `me`, `savePreferences`, `resetDemo` | `/catalog`, `/api/me*` |
| `JoinApi` | `submit`, `startEkyc`, `approve` | `/join*` |
| `AepsApi` | `submit` | `/api/aeps` |
| `HomeApi` | `transactions`, `checkTransaction`, `settle`, `addAccount`, `topup`, `receiptAction`, `exportCsv` | txns / wallet / receipts |
| `SupportApi` | `createTicket`, `device`, `patchDevice`, `testDevice`, `deviceRequest`, `updateProfile`, `changePassword` | tickets / device / me |
| `ApiClient` | `restore`, `persistToken`, `clearToken`, `get`, `post`, `patch` | HTTP + Bearer |

Use cases (`login`, `verifyTotp`, `verifyOtp`, `forgotPassword`, `submitJoin`, `startEkyc`, `refreshSession`, `loadTransactions`, `createTicket`) wrap the same calls for the domain layer.

## `AppController` (session + auth + AEPS + support)

| Function | What it does |
| --- | --- |
| `go` / `nav` / `back` / `parentOf` / `showBack` | In-app routing (not URL routes). |
| `setLang` / `toggleLang` / `toggleDark` / `setScale` | Language, theme, text size (persisted via `/api/me/preferences`). |
| `toast` | Top snack. |
| `submitLogin` | Password login → `mfa` screen. |
| `submitTotp` | Authenticator PIN → `otp` screen (or dashboard if a token is returned). |
| `submitOtp` | Email code → persist JWT, `dash`. |
| `resendOtp` | New email code. |
| `togglePw` | Show/hide password. |
| `refreshSession` | `GET /api/me` into `AppData`. |
| `logout` | Clear token, return to welcome. |
| `resetDemo` | Re-seed demo retailer on the server. |
| `startForgot` / `submitForgot` / `confirmForgot` | Password reset screens. |
| `startAeps` / `setService` / `saveAepsDetails` / `reviewAeps` | Begin cash-out / MS / BE and validate the form. |
| `editAeps` / `setIdType` / `toggleShowId` / `fillSample` / `pickBank` / `setConsent` | Form helpers. |
| `capture` | Simulated fingerprint, then `submitAeps`. |
| `submitAeps` | `POST /api/aeps` with demo `outcome`. |
| `checkDevice` / `restartAeps` / `doneAeps` | Device gate and flow reset. |
| `openSupport` / `setHelpTab` / `setReqType` / `setReqRef` / `unlinkReq` | Help ticket UI. |
| `submitTicket` (via support flow) | `POST /api/tickets`. |
| `setDevTab` / `testCapture` / `recheckDevicePage` / `deviceRequest` | Device page. |
| `openScenarios` / `setOutcome` / `setFailReason` / `setPendingResolve` / `setDevice` / `setCaptureRetry` | Prototype outcome controls. |
| `openProfile` / `submitProfile` / `openPassword` / `submitPassword` | Profile and password sheets. |
| `closeSheet` | Dismiss modal. |

## `HomeController` mixin

| Function | What it does |
| --- | --- |
| `loadHistory` | `GET /api/transactions` with filters. |
| `setHist` / `clearHist` | Search, status, service, date range. |
| `checkStatus` | Re-check a pending txn. |
| `openReceipt` | Receipt sheet for a ref. |
| `openSettle` / `setSettleAmt` / `submitSettle` | AEPS → bank settlement. |
| `openAddBank` / `submitBank` | Add settlement account. |
| `openTopup` / `submitTopup` | Credit main wallet. |
| `receiptAction` | Print / share / download (logged on server). |
| `requestExport` | CSV export request. |

## `JoinController` mixin

| Function | What it does |
| --- | --- |
| `startJoin` | Open onboarding. |
| `setRole` | Retailer / distributor / super. |
| `joinNext` | Validate step and advance. |
| `setAgree` | T&C checkbox. |
| `runEkyc` | `POST /join/ekyc`. |
| `attachDoc` | Attach a named demo document. |
| `simulateApproval` | `POST /join/:id/approve`. |

## Core UI (shared)

| Piece | What it does |
| --- | --- |
| `ApiClient` | JSON HTTP, cookies/credentials, 401 handling. |
| `LayoutService` / `LayoutScope` | Mobile / tablet / desktop breakpoints. |
| `ApPalette` / `apTheme` | Light/dark tokens. |
| `strings.dart` | EN + HI copy (`c.t` / `c.both`). |
| `AuthLayout` / `AuthBack` / `AuthDigitRow` | Auth chrome matching login / MFA / OTP. |
| `AppScope` | Provides `AppController` to the tree. |
| Sheets | Bank pick, settle, top-up, add bank, receipt, profile, password, AEPS scenarios. |

---

## Typical login sequence

1. `POST /auth/login` `{ partnerId, password }` → `mfa.nextStep: "totp"` (+ QR if enrol).
2. `POST /auth/totp` `{ partnerId, totp, challengeId }` → `mfa.nextStep: "email_otp"`.
3. `POST /auth/otp` `{ partnerId, otp, challengeId }` → `{ token, mfaToken, tokenType: "Bearer" }`.
4. `GET /api/me` with `Authorization: Bearer <token>` (cookie also set). Sensitive POSTs also send `X-MFA-Token: <mfaToken>`.
