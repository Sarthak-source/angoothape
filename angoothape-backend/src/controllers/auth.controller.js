import argon2 from 'argon2';
import crypto from 'node:crypto';
import { query } from '../db.js';
import { config } from '../config.js';
import { fail } from '../middleware/error.js';
import { signToken, setAuthCookie, clearAuthCookie } from '../middleware/auth.js';

function sixDigit() {
  return String(crypto.randomInt(0, 1_000_000)).padStart(6, '0');
}

function partnerIdOf(req) {
  return String(req.body?.partnerId || req.body?.id || '')
    .trim()
    .toUpperCase();
}

export async function login(req, res) {
  const partnerId = partnerIdOf(req);
  const password = String(req.body?.password || req.body?.pw || '');
  if (!partnerId || !password) {
    throw fail(400, 'invalid_login', 'Enter partner ID and password');
  }
  const { rows } = await query(
    'SELECT id, partner_id, password_hash FROM retailers WHERE partner_id = $1',
    [partnerId],
  );
  const row = rows[0];
  const ok =
    row && (await argon2.verify(row.password_hash, password).catch(() => false));
  if (!ok) throw fail(401, 'invalid_login', 'ID or password is wrong');

  await query(
    'UPDATE otp_challenges SET consumed_at = now() WHERE retailer_id = $1 AND consumed_at IS NULL',
    [row.id],
  );
  const code = sixDigit();
  const codeHash = await argon2.hash(code, { type: argon2.argon2id });
  const expires = new Date(Date.now() + 5 * 60 * 1000);
  const inserted = await query(
    `INSERT INTO otp_challenges (retailer_id, code_hash, expires_at)
     VALUES ($1,$2,$3) RETURNING id`,
    [row.id, codeHash, expires],
  );
  const body = {
    ok: true,
    challengeId: inserted.rows[0].id,
    expiresAt: expires.toISOString(),
  };
  if (config.devReturnOtp) body.otp = code;
  res.json(body);
}

export async function verifyOtp(req, res) {
  const partnerId = partnerIdOf(req);
  const code = String(req.body?.otp || req.body?.code || '').trim();
  if (!/^\d{6}$/.test(code)) {
    throw fail(400, 'invalid_otp', 'Enter the 6-digit code');
  }
  const { rows } = await query(
    `SELECT c.id, c.code_hash, c.expires_at, r.id AS retailer_id, r.partner_id
       FROM otp_challenges c
       JOIN retailers r ON r.id = c.retailer_id
      WHERE r.partner_id = $1 AND c.consumed_at IS NULL
      ORDER BY c.created_at DESC
      LIMIT 1`,
    [partnerId],
  );
  const row = rows[0];
  if (!row || new Date(row.expires_at) < new Date()) {
    throw fail(401, 'invalid_otp', 'Code expired. Request a new one.');
  }
  const match = await argon2.verify(row.code_hash, code).catch(() => false);
  if (!match) throw fail(401, 'invalid_otp', 'That code is not correct');

  await query('UPDATE otp_challenges SET consumed_at = now() WHERE id = $1', [
    row.id,
  ]);
  const token = signToken({ id: row.retailer_id, partner_id: row.partner_id });
  setAuthCookie(res, token);
  res.json({ ok: true, token });
}

export async function resendOtp(req, res) {
  const partnerId = partnerIdOf(req);
  const { rows } = await query(
    'SELECT id FROM retailers WHERE partner_id = $1',
    [partnerId],
  );
  if (!rows[0]) throw fail(404, 'not_found', 'Unknown partner ID');
  await query(
    'UPDATE otp_challenges SET consumed_at = now() WHERE retailer_id = $1 AND consumed_at IS NULL',
    [rows[0].id],
  );
  const code = sixDigit();
  const codeHash = await argon2.hash(code, { type: argon2.argon2id });
  const expires = new Date(Date.now() + 5 * 60 * 1000);
  await query(
    `INSERT INTO otp_challenges (retailer_id, code_hash, expires_at)
     VALUES ($1,$2,$3)`,
    [rows[0].id, codeHash, expires],
  );
  const body = { ok: true, expiresAt: expires.toISOString() };
  if (config.devReturnOtp) body.otp = code;
  res.json(body);
}

export function logout(_req, res) {
  clearAuthCookie(res);
  res.json({ ok: true });
}

export async function forgotPassword(req, res) {
  const partnerId = partnerIdOf(req);
  const { rows } = await query(
    'SELECT id FROM retailers WHERE partner_id = $1',
    [partnerId],
  );
  if (!rows[0]) throw fail(404, 'not_found', 'Unknown partner ID');
  await query(
    'UPDATE password_resets SET consumed_at = now() WHERE retailer_id = $1 AND consumed_at IS NULL',
    [rows[0].id],
  );
  const code = sixDigit();
  const codeHash = await argon2.hash(code, { type: argon2.argon2id });
  const expires = new Date(Date.now() + 5 * 60 * 1000);
  await query(
    `INSERT INTO password_resets (retailer_id, code_hash, expires_at)
     VALUES ($1,$2,$3)`,
    [rows[0].id, codeHash, expires],
  );
  const body = { ok: true, expiresAt: expires.toISOString() };
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
