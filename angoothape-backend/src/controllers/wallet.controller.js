import { query } from '../db.js';
import { fail } from '../middleware/error.js';
import { recordRequest } from '../requests.js';
import { loadWallet, money } from '../utils/tx.js';

const IFSC_BANKS = {
  SBIN: 'sbi',
  HDFC: 'hdfc',
  PUNB: 'pnb',
  BARB: 'bob',
  BKID: 'boi',
  UBIN: 'ubi',
  CNRB: 'cnb',
  CBIN: 'cbi',
  IDIB: 'ib',
  ICIC: 'icici',
  UTIB: 'axis',
  KKBK: 'kotak',
};

export async function createSettlement(req, res) {
  const amount = Number(req.body?.amount || 0);
  const { rows } = await query(
    'SELECT wallet_aeps FROM retailers WHERE id = $1',
    [req.user.id],
  );
  const aeps = money(rows[0].wallet_aeps);
  if (amount < 100 || amount > aeps) {
    throw fail(400, 'invalid_amount', 'Enter a valid settlement amount');
  }
  const count = await query(
    'SELECT count(*)::int AS n FROM settlements WHERE retailer_id = $1',
    [req.user.id],
  );
  const publicId = `ST-${10450 + count.rows[0].n}`;
  await query('UPDATE retailers SET wallet_aeps = wallet_aeps - $2 WHERE id = $1', [
    req.user.id,
    amount,
  ]);
  const inserted = await query(
    `INSERT INTO settlements (retailer_id, public_id, amount, acct_bank, status)
     VALUES ($1,$2,$3,'sbi','processing')
     RETURNING public_id AS id, created_at AS t, amount AS amt, acct_bank AS acct, status, utr, note`,
    [req.user.id, publicId, amount],
  );
  res.status(201).json({
    settlement: { ...inserted.rows[0], amt: Number(inserted.rows[0].amt) },
    wallet: await loadWallet(req.user.id),
  });
}

export async function addAccount(req, res) {
  const holder = String(req.body?.holder || '').trim().toUpperCase();
  const acct = String(req.body?.acct || '').replace(/\D/g, '');
  const acct2 = String(req.body?.acct2 || '').replace(/\D/g, '');
  const ifsc = String(req.body?.ifsc || '')
    .trim()
    .toUpperCase();
  if (!holder) throw fail(400, 'invalid', 'Enter the name');
  if (!/^\d{9,18}$/.test(acct)) {
    throw fail(400, 'invalid', 'Enter a 9–18 digit account number');
  }
  if (acct !== acct2) throw fail(400, 'invalid', 'Account numbers do not match');
  if (!/^[A-Z]{4}0[A-Z0-9]{6}$/.test(ifsc)) {
    throw fail(400, 'invalid', 'Enter a valid IFSC');
  }
  const bank = IFSC_BANKS[ifsc.slice(0, 4)] || 'sbi';
  const inserted = await query(
    `INSERT INTO bank_accounts (retailer_id, bank_id, last4, holder, ifsc, status)
     VALUES ($1,$2,$3,$4,$5,'pending')
     RETURNING id, bank_id AS bank, last4, holder, ifsc, status, is_primary AS "primary", note`,
    [req.user.id, bank, acct.slice(-4), holder, ifsc],
  );
  res.status(201).json({ account: inserted.rows[0] });
}

export async function topupWallet(req, res) {
  const amount = Number(req.body?.amount || 0);
  if (amount < 100 || amount > 50000) {
    throw fail(400, 'invalid_amount', 'Enter an amount between 100 and 50000');
  }
  await query(
    'UPDATE retailers SET wallet_main = wallet_main + $2 WHERE id = $1',
    [req.user.id, amount],
  );
  await recordRequest(req.user.id, 'wallet_topup', { amount });
  res.status(201).json({ wallet: await loadWallet(req.user.id) });
}
