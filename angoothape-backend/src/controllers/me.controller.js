import argon2 from 'argon2';
import { query } from '../db.js';
import { fail } from '../middleware/error.js';
import { seedDemoRetailer } from '../demo-seed.js';
import { maskMobile, recordRequest } from '../requests.js';
import { attachMinis, money } from '../utils/tx.js';

export async function getMe(req, res) {
  const u = req.user;
  const [accounts, settlements, tickets, tx] = await Promise.all([
    query(
      `SELECT id, bank_id AS bank, last4, holder, ifsc, status, is_primary AS "primary", note
         FROM bank_accounts WHERE retailer_id = $1 ORDER BY created_at`,
      [u.id],
    ),
    query(
      `SELECT public_id AS id, created_at AS t, amount AS amt, acct_bank AS acct, status, utr, note
         FROM settlements WHERE retailer_id = $1 ORDER BY created_at DESC`,
      [u.id],
    ),
    query(
      `SELECT public_id AS id, created_at AS t, type, status, message AS msg, ref
         FROM tickets WHERE retailer_id = $1 ORDER BY created_at DESC`,
      [u.id],
    ),
    query(
      `SELECT * FROM transactions WHERE retailer_id = $1 ORDER BY occurred_at DESC LIMIT 80`,
      [u.id],
    ),
  ]);
  res.json({
    retailer: {
      id: u.partner_id,
      name: u.name,
      shop: u.shop,
      city: u.city,
      mobile: u.mobile_mask,
      mobileFull: u.mobile || '',
      role: u.role,
      distributor: u.distributor,
    },
    prefs: {
      lang: u.lang || 'en',
      dark: Boolean(u.dark),
      scale: Number(u.text_scale || 1),
      deviceState: u.device_state || 'ready',
    },
    wallet: {
      main: money(u.wallet_main),
      aeps: money(u.wallet_aeps),
      earn: money(u.wallet_earn),
    },
    accounts: accounts.rows,
    settlements: settlements.rows.map((s) => ({
      ...s,
      amt: Number(s.amt),
    })),
    tickets: tickets.rows,
    tx: await attachMinis(tx.rows),
  });
}

export async function updateMe(req, res) {
  const name = String(req.body?.name || '').trim();
  const shop = String(req.body?.shop || '').trim();
  const city = String(req.body?.city || '').trim();
  const mobile = String(req.body?.mobile || '').replace(/\D/g, '');
  if (!name || !shop || !city) throw fail(400, 'invalid', 'Fill name, shop and city');
  if (!/^[6-9]\d{9}$/.test(mobile)) {
    throw fail(400, 'invalid', 'Enter a valid 10-digit mobile');
  }
  const { rows } = await query(
    `UPDATE retailers
        SET name = $2, shop = $3, city = $4, mobile = $5, mobile_mask = $6
      WHERE id = $1
      RETURNING partner_id AS id, name, shop, city, mobile_mask AS mobile, mobile AS "mobileFull",
                role, distributor`,
    [req.user.id, name, shop, city, mobile, maskMobile(mobile)],
  );
  res.json({ retailer: rows[0] });
}

export async function updatePreferences(req, res) {
  const lang = req.body?.lang === 'hi' ? 'hi' : 'en';
  const dark = Boolean(req.body?.dark);
  const scale = Number(req.body?.scale) === 1.15 ? 1.15 : 1;
  await query(
    `UPDATE retailers SET lang = $2, dark = $3, text_scale = $4 WHERE id = $1`,
    [req.user.id, lang, dark, scale],
  );
  res.json({ prefs: { lang, dark, scale } });
}

export async function changePassword(req, res) {
  const current = String(req.body?.current || '');
  const nextPw = String(req.body?.next || '');
  if (nextPw.length < 8) {
    throw fail(400, 'invalid', 'New password must be at least 8 characters');
  }
  const { rows } = await query(
    'SELECT password_hash FROM retailers WHERE id = $1',
    [req.user.id],
  );
  const ok = await argon2.verify(rows[0].password_hash, current).catch(() => false);
  if (!ok) throw fail(401, 'invalid', 'Current password is wrong');
  const hash = await argon2.hash(nextPw, { type: argon2.argon2id });
  await query('UPDATE retailers SET password_hash = $2 WHERE id = $1', [
    req.user.id,
    hash,
  ]);
  await recordRequest(req.user.id, 'password_change', {});
  res.json({ ok: true });
}

export async function resetDemo(req, res) {
  if (req.user.partner_id !== 'AP100245') {
    throw fail(403, 'forbidden', 'Demo reset is only for the sample retailer');
  }
  await seedDemoRetailer(req.user.id);
  res.json({ ok: true });
}
