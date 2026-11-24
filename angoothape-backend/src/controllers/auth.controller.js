import argon2 from 'argon2';
import crypto from 'node:crypto';
import { query } from '../db.js';
import { config } from '../config.js';
import { fail } from '../middleware/error.js';
import { signToken, setAuthCookie, clearAuthCookie } from '../middleware/auth.js';
import { maskEmail, sendOtpEmail } from '../mailer.js';
import { newTotpSecret, totpNow, totpOk, totpQrDataUrl, totpUri } from '../totp.js';

function sixDigit() {
  return String(crypto.randomInt(0, 1_000_000)).padStart(6, '0');
}

function partnerIdOf(req) {
  return String(req.body?.partnerId || req.body?.id || '')
    .trim()
    .toUpperCase();
}

async function mfaBody({
  challengeId,
  expiresAt,
  otp,
  email,
  enroll,
  totpSecret,
  partnerId,
}) {
  const body = {
    ok: true,
    mfaRequired: true,
    mfa: {
      methods: ['totp', 'email_otp'],
      nextStep: enroll || totpSecret ? 'totp' : 'email_otp',
      challengeId,
      expiresAt: expiresAt.toISOString(),
      maxAttempts: config.mfaMaxAttempts,
      emailMasked: maskEmail(email),
      enroll: Boolean(enroll),
      totpRequired: true,
    },
  };
  if (enroll && totpSecret) {
    body.mfa.otpauthUrl = totpUri(partnerId, totpSecret);
    body.mfa.qrDataUrl = await totpQrDataUrl(partnerId, totpSecret);
  }
  if (config.devReturnOtp && otp) body.otp = otp;
  if (config.devReturnOtp && totpSecret) body.totp = totpNow(totpSecret);
  return body;
}

function issueSession(res, retailer) {
  const token = signToken({ id: retailer.id, partner_id: retailer.partner_id });
  setAuthCookie(res, token);
  return {
    ok: true,
    mfaRequired: false,
    token,
    tokenType: 'Bearer',
    expiresIn: config.jwtExpires,
  };
}

async function hashCode(code) {
  return argon2.hash(code, { type: argon2.argon2id });
}

async function createOtpChallenge(retailerId, pendingTotpSecret = null) {
  await query(
    'UPDATE otp_challenges SET consumed_at = now() WHERE retailer_id = $1 AND consumed_at IS NULL',
    [retailerId],
  );
  const code = sixDigit();
  const expires = new Date(Date.now() + 5 * 60 * 1000);
  const inserted = await query(
    `INSERT INTO otp_challenges
       (retailer_id, code_hash, expires_at, attempts, pending_totp_secret)
     VALUES ($1,$2,$3,0,$4) RETURNING id`,
    [retailerId, await hashCode(code), expires, pendingTotpSecret],
  );
  return { id: inserted.rows[0].id, code, expires };
}

async function loadChallenge(partnerId, challengeId) {
  const { rows } = await query(
    challengeId
      ? `SELECT c.id, c.code_hash, c.expires_at, c.attempts, c.pending_totp_secret,
                c.totp_verified_at, c.email_verified_at,
                r.id AS retailer_id, r.partner_id, r.totp_secret, r.totp_enabled, r.email
           FROM otp_challenges c
           JOIN retailers r ON r.id = c.retailer_id
          WHERE c.id = $1 AND r.partner_id = $2 AND c.consumed_at IS NULL`
      : `SELECT c.id, c.code_hash, c.expires_at, c.attempts, c.pending_totp_secret,
                c.totp_verified_at, c.email_verified_at,
                r.id AS retailer_id, r.partner_id, r.totp_secret, r.totp_enabled, r.email
           FROM otp_challenges c
           JOIN retailers r ON r.id = c.retailer_id
          WHERE r.partner_id = $1 AND c.consumed_at IS NULL
          ORDER BY c.created_at DESC
          LIMIT 1`,
    challengeId ? [challengeId, partnerId] : [partnerId],
  );
  const row = rows[0];
  if (!row || new Date(row.expires_at) < new Date()) {
    throw fail(401, 'invalid_otp', 'Code expired. Request a new one.');
  }
  if (row.attempts >= config.mfaMaxAttempts) {
    throw fail(
      429,
      'mfa_locked',
      'Too many incorrect codes. Request a new one.',
    );
  }
  return row;
}

async function finishIfReady(res, row) {
  if (!row.totp_verified_at || !row.email_verified_at) {
    return null;
  }
  if (row.pending_totp_secret) {
    await query(
      `UPDATE retailers SET totp_secret = $2, totp_enabled = true WHERE id = $1`,
      [row.retailer_id, row.pending_totp_secret],
    );
  }
  await query('UPDATE otp_challenges SET consumed_at = now() WHERE id = $1', [
    row.id,
  ]);
  return issueSession(res, { id: row.retailer_id, partner_id: row.partner_id });
}

async function bumpFail(row) {
  const next = row.attempts + 1;
  await query('UPDATE otp_challenges SET attempts = $2 WHERE id = $1', [
    row.id,
    next,
  ]);
  if (next >= config.mfaMaxAttempts) {
    throw fail(
      429,
      'mfa_locked',
      'Too many incorrect codes. Request a new one.',
    );
  }
  throw fail(
    401,
    'invalid_otp',
    `That code is not correct. ${config.mfaMaxAttempts - next} tries left.`,
  );
}

export async function login(req, res) {
  const partnerId = partnerIdOf(req);
  const password = String(req.body?.password || req.body?.pw || '');
  if (!partnerId || !password) {
    throw fail(400, 'invalid_login', 'Enter partner ID and password');
  }
  const { rows } = await query(
    `SELECT id, partner_id, password_hash, email, totp_secret, totp_enabled
       FROM retailers WHERE partner_id = $1`,
    [partnerId],
  );
  const row = rows[0];
  const ok =
    row && (await argon2.verify(row.password_hash, password).catch(() => false));
  if (!ok) throw fail(401, 'invalid_login', 'ID or password is wrong');

  const enroll = !row.totp_enabled || !row.totp_secret;
  const pendingTotp = enroll ? newTotpSecret() : null;
  const challenge = await createOtpChallenge(row.id, pendingTotp);
  await sendOtpEmail({ to: row.email, code: challenge.code, purpose: 'login' });
  const body = await mfaBody({
    challengeId: challenge.id,
    expiresAt: challenge.expires,
    otp: challenge.code,
    email: row.email,
    enroll,
    totpSecret: pendingTotp || row.totp_secret,
    partnerId: row.partner_id,
  });
  body.mfa.nextStep = 'totp';
  res.json(body);
}

export async function verifyTotp(req, res) {
  const partnerId = partnerIdOf(req);
  const totp = String(req.body?.totp || req.body?.mfaToken || '').trim();
  const challengeId = String(req.body?.challengeId || '').trim();
  if (!/^\d{6}$/.test(totp)) {
    throw fail(400, 'invalid_totp', 'Enter the 6-digit authenticator PIN');
  }
  const row = await loadChallenge(partnerId, challengeId);
  const secret = row.pending_totp_secret || row.totp_secret;
  if (!totpOk(totp, secret)) await bumpFail(row);
  const updated = await query(
    `UPDATE otp_challenges SET totp_verified_at = now() WHERE id = $1
     RETURNING totp_verified_at, email_verified_at, pending_totp_secret`,
    [row.id],
  );
  Object.assign(row, updated.rows[0]);
  const done = await finishIfReady(res, row);
  if (done) {
    res.json(done);
    return;
  }
  const body = await mfaBody({
    challengeId: row.id,
    expiresAt: new Date(row.expires_at),
    email: row.email,
    enroll: false,
    totpSecret: null,
    partnerId: row.partner_id,
  });
  body.mfa.nextStep = 'email_otp';
  body.mfa.enroll = false;
  delete body.mfa.qrDataUrl;
  delete body.mfa.otpauthUrl;
  delete body.totp;
  res.json(body);
}

export async function verifyOtp(req, res) {
  const partnerId = partnerIdOf(req);
  const code = String(req.body?.otp || req.body?.code || '').trim();
  const challengeId = String(req.body?.challengeId || '').trim();
  if (!/^\d{6}$/.test(code)) {
    throw fail(400, 'invalid_otp', 'Enter the 6-digit email code');
  }
  const row = await loadChallenge(partnerId, challengeId);
  if (!row.totp_verified_at) {
    throw fail(401, 'totp_required', 'Complete authenticator verification first');
  }
  const emailOk = await argon2.verify(row.code_hash, code).catch(() => false);
  if (!emailOk) await bumpFail(row);
  const updated = await query(
    `UPDATE otp_challenges SET email_verified_at = now() WHERE id = $1
     RETURNING totp_verified_at, email_verified_at, pending_totp_secret`,
    [row.id],
  );
  Object.assign(row, updated.rows[0]);
  const done = await finishIfReady(res, row);
  if (!done) {
    throw fail(401, 'mfa_incomplete', 'Authenticator PIN is still required');
  }
  res.json(done);
}

export async function resendOtp(req, res) {
  const partnerId = partnerIdOf(req);
  const { rows } = await query(
    `SELECT id, partner_id, email, totp_secret, totp_enabled FROM retailers WHERE partner_id = $1`,
    [partnerId],
  );
  if (!rows[0]) throw fail(404, 'not_found', 'Unknown partner ID');
  const retailer = rows[0];
  const open = await query(
    `SELECT id, pending_totp_secret FROM otp_challenges
      WHERE retailer_id = $1 AND consumed_at IS NULL
      ORDER BY created_at DESC LIMIT 1`,
    [retailer.id],
  );
  const code = sixDigit();
  const expires = new Date(Date.now() + 5 * 60 * 1000);
  let challengeId;
  let pending = open.rows[0]?.pending_totp_secret || null;
  const enroll = !retailer.totp_enabled || !retailer.totp_secret;
  if (enroll && !pending) pending = newTotpSecret();
  if (open.rows[0]) {
    challengeId = open.rows[0].id;
    await query(
      `UPDATE otp_challenges
          SET code_hash = $2, expires_at = $3, attempts = 0, pending_totp_secret = $4
        WHERE id = $1`,
      [challengeId, await hashCode(code), expires, pending],
    );
  } else {
    const created = await createOtpChallenge(retailer.id, pending);
    challengeId = created.id;
  }
  await sendOtpEmail({ to: retailer.email, code, purpose: 'login' });
  res.json(
    await mfaBody({
      challengeId,
      expiresAt: expires,
      otp: code,
      email: retailer.email,
      enroll,
      totpSecret: pending || retailer.totp_secret,
      partnerId: retailer.partner_id,
    }),
  );
}

export function logout(_req, res) {
  clearAuthCookie(res);
  res.json({ ok: true });
}

export async function forgotPassword(req, res) {
  const partnerId = partnerIdOf(req);
  const { rows } = await query(
    'SELECT id, email FROM retailers WHERE partner_id = $1',
    [partnerId],
  );
  if (!rows[0]) throw fail(404, 'not_found', 'Unknown partner ID');
  await query(
    'UPDATE password_resets SET consumed_at = now() WHERE retailer_id = $1 AND consumed_at IS NULL',
    [rows[0].id],
  );
  const code = sixDigit();
  const expires = new Date(Date.now() + 5 * 60 * 1000);
  await query(
    `INSERT INTO password_resets (retailer_id, code_hash, expires_at)
     VALUES ($1,$2,$3)`,
    [rows[0].id, await hashCode(code), expires],
  );
  await sendOtpEmail({ to: rows[0].email, code, purpose: 'reset' });
  const body = { ok: true, expiresAt: expires.toISOString(), emailMasked: maskEmail(rows[0].email) };
  if (config.devReturnOtp) body.otp = code;
  res.json(body);
}

export async function confirmForgot(req, res) {
  const partnerId = partnerIdOf(req);
  const code = String(req.body?.otp || '').trim();
  const nextPw = String(req.body?.password || req.body?.next || '');
  if (!/^\d{6}$/.test(code)) throw fail(400, 'invalid_otp', 'Enter the 6-digit code');
  if (nextPw.length < 8) {
    throw fail(400, 'invalid', 'New password must be at least 8 characters');
  }
  const { rows } = await query(
    `SELECT r.id, p.id AS reset_id, p.code_hash, p.expires_at
       FROM password_resets p
       JOIN retailers r ON r.id = p.retailer_id
      WHERE r.partner_id = $1 AND p.consumed_at IS NULL
      ORDER BY p.created_at DESC
      LIMIT 1`,
    [partnerId],
  );
  const row = rows[0];
  if (!row || new Date(row.expires_at) < new Date()) {
    throw fail(401, 'invalid_otp', 'Code expired. Request a new one.');
  }
  const match = await argon2.verify(row.code_hash, code).catch(() => false);
  if (!match) throw fail(401, 'invalid_otp', 'That code is not correct');
  const hash = await argon2.hash(nextPw, { type: argon2.argon2id });
  await query('UPDATE retailers SET password_hash = $2 WHERE id = $1', [
    row.id,
    hash,
  ]);
  await query('UPDATE password_resets SET consumed_at = now() WHERE id = $1', [
    row.reset_id,
  ]);
  res.json({ ok: true });
}
