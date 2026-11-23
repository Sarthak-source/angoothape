CREATE EXTENSION IF NOT EXISTS pgcrypto;

CREATE TABLE IF NOT EXISTS retailers (
  id            UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  partner_id    TEXT UNIQUE NOT NULL,
  password_hash TEXT NOT NULL,
  name          TEXT NOT NULL,
  shop          TEXT NOT NULL,
  city          TEXT NOT NULL,
  mobile_mask   TEXT NOT NULL,
  role          TEXT NOT NULL DEFAULT 'Retailer / Franchisee',
  distributor   TEXT,
  wallet_main   NUMERIC(14, 2) NOT NULL DEFAULT 0,
  wallet_aeps   NUMERIC(14, 2) NOT NULL DEFAULT 0,
  wallet_earn   NUMERIC(14, 2) NOT NULL DEFAULT 0,
  created_at    TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE TABLE IF NOT EXISTS otp_challenges (
  id           UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  retailer_id  UUID NOT NULL REFERENCES retailers(id) ON DELETE CASCADE,
  code_hash    TEXT NOT NULL,
  expires_at   TIMESTAMPTZ NOT NULL,
  consumed_at  TIMESTAMPTZ,
  created_at   TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE INDEX IF NOT EXISTS otp_challenges_retailer_idx
  ON otp_challenges (retailer_id, created_at DESC);

CREATE TABLE IF NOT EXISTS bank_accounts (
  id          UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  retailer_id UUID NOT NULL REFERENCES retailers(id) ON DELETE CASCADE,
  bank_id     TEXT NOT NULL,
  last4       TEXT NOT NULL,
  holder      TEXT NOT NULL,
  ifsc        TEXT NOT NULL,
  status      TEXT NOT NULL DEFAULT 'pending',
  is_primary  BOOLEAN NOT NULL DEFAULT false,
  note        TEXT,
  created_at  TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE TABLE IF NOT EXISTS transactions (
  id           UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  retailer_id  UUID NOT NULL REFERENCES retailers(id) ON DELETE CASCADE,
  occurred_at  TIMESTAMPTZ NOT NULL DEFAULT now(),
  service      TEXT NOT NULL,
  amount       INTEGER NOT NULL DEFAULT 0,
  bank_id      TEXT NOT NULL,
  aadhaar4     TEXT NOT NULL,
  mobile4      TEXT NOT NULL,
  status       TEXT NOT NULL,
  ref          TEXT UNIQUE NOT NULL,
  rrn          TEXT NOT NULL,
  reason       TEXT,
  cust_bal     NUMERIC(14, 2),
  unknown      BOOLEAN NOT NULL DEFAULT false,
  earn         NUMERIC(14, 2) NOT NULL DEFAULT 0,
  checks       INTEGER NOT NULL DEFAULT 0,
  credited     BOOLEAN NOT NULL DEFAULT false,
  created_at   TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE INDEX IF NOT EXISTS transactions_retailer_time_idx
  ON transactions (retailer_id, occurred_at DESC);

CREATE TABLE IF NOT EXISTS settlements (
  id          UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  retailer_id UUID NOT NULL REFERENCES retailers(id) ON DELETE CASCADE,
  public_id   TEXT UNIQUE NOT NULL,
  amount      INTEGER NOT NULL,
  acct_bank   TEXT NOT NULL,
  status      TEXT NOT NULL DEFAULT 'processing',
  utr         TEXT,
  note        TEXT,
  created_at  TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE TABLE IF NOT EXISTS tickets (
  id          UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  retailer_id UUID NOT NULL REFERENCES retailers(id) ON DELETE CASCADE,
  public_id   TEXT UNIQUE NOT NULL,
  type        TEXT NOT NULL,
  status      TEXT NOT NULL DEFAULT 'Open',
  message     TEXT NOT NULL,
  ref         TEXT,
  created_at  TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE TABLE IF NOT EXISTS banks (
  id          TEXT PRIMARY KEY,
  name        TEXT NOT NULL,
  short       TEXT NOT NULL,
  color       BIGINT NOT NULL,
  popular     BOOLEAN NOT NULL DEFAULT false,
  ifsc_prefix TEXT,
  sort        INTEGER NOT NULL DEFAULT 0
);

CREATE TABLE IF NOT EXISTS faqs (
  id       SERIAL PRIMARY KEY,
  lang     TEXT NOT NULL,
  sort     INTEGER NOT NULL,
  question TEXT NOT NULL,
  answer   TEXT NOT NULL
);

CREATE TABLE IF NOT EXISTS issue_types (
  id    SERIAL PRIMARY KEY,
  lang  TEXT NOT NULL,
  sort  INTEGER NOT NULL,
  label TEXT NOT NULL
);

CREATE TABLE IF NOT EXISTS future_services (
  id    TEXT NOT NULL,
  lang  TEXT NOT NULL,
  sort  INTEGER NOT NULL,
  label TEXT NOT NULL,
  PRIMARY KEY (id, lang)
);

CREATE TABLE IF NOT EXISTS mini_statement_lines (
  id             UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  transaction_id UUID NOT NULL REFERENCES transactions(id) ON DELETE CASCADE,
  sort           INTEGER NOT NULL,
  label          TEXT NOT NULL,
  occurred_on    DATE NOT NULL,
  amount         INTEGER NOT NULL
);

CREATE TABLE IF NOT EXISTS applications (
  id         UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  public_id  TEXT UNIQUE NOT NULL,
  role       TEXT NOT NULL,
  payload    JSONB NOT NULL DEFAULT '{}'::jsonb,
  status     TEXT NOT NULL DEFAULT 'submitted',
  created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

ALTER TABLE IF EXISTS banks ALTER COLUMN color TYPE BIGINT;
