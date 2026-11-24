import crypto from 'node:crypto';
import { query } from '../db.js';
import { fail } from '../middleware/error.js';
import { insertMiniLines } from '../demo-seed.js';
import { attachMinis, loadWallet } from '../utils/tx.js';

export async function submitAeps(req, res) {
  const body = req.body || {};
  const svc = String(body.svc || 'cw');
  const bank = String(body.bank || '');
  const amount = Number(body.amount || 0);
  const aadhaar4 = String(body.aadhaar4 || '').replace(/\D/g, '').slice(-4);
  const mobile4 = String(body.mobile4 || '').replace(/\D/g, '').slice(-4);
  if (!bank) throw fail(400, 'invalid', 'Choose a bank');
  if (svc === 'cw' && (amount < 100 || amount > 10000)) {
    throw fail(400, 'invalid_amount', 'Amount must be between 100 and 10000');
  }
  if (aadhaar4.length !== 4 || mobile4.length !== 4) {
    throw fail(400, 'invalid', 'Masked customer identifiers required');
  }

  await new Promise((r) => setTimeout(r, 800));

  const outcome = String(body.outcome || 'success');
  let status = 'success';
  let reason = null;
  let unknown = false;
  let bal = null;
  if (outcome === 'failed') {
    status = 'failed';
    reason = String(body.failReason || 'insufficient');
  } else if (outcome === 'pending') {
    status = 'pending';
  } else if (outcome === 'network') {
    status = 'pending';
    unknown = true;
  } else {
    bal = Math.round((2500 + Math.random() * 24000) * 100) / 100;
  }

  const now = new Date();
  const stamp = now.toISOString().slice(2, 10).replace(/-/g, '');
  const ref = `AP${stamp}${crypto.randomInt(100000, 999999)}`;
  const rrn = String(crypto.randomInt(1e11, 1e12));
  let earn = 0;
  let credited = false;
  if (status === 'success' && svc === 'cw') {
    earn = 5;
    credited = true;
    await query(
      `UPDATE retailers
          SET wallet_aeps = wallet_aeps + $2,
              wallet_earn = wallet_earn + $3
        WHERE id = $1`,
      [req.user.id, amount, earn],
    );
  } else if (status === 'success') {
    credited = true;
  }

  await query(
    `INSERT INTO transactions (
       retailer_id, occurred_at, service, amount, bank_id, aadhaar4, mobile4,
       status, ref, rrn, reason, cust_bal, unknown, earn, credited
     ) VALUES ($1,now(),$2,$3,$4,$5,$6,$7,$8,$9,$10,$11,$12,$13,$14)`,
    [
      req.user.id,
      svc,
      svc === 'cw' ? amount : 0,
      bank,
      aadhaar4,
      mobile4,
      status,
      ref,
      rrn,
      reason,
      bal,
      unknown,
      earn,
      credited,
    ],
  );
  const { rows } = await query('SELECT * FROM transactions WHERE ref = $1', [ref]);
  if (svc === 'ms' && rows[0]) await insertMiniLines(rows[0].id, now);
  res.status(201).json({
    tx: (await attachMinis(rows))[0],
    wallet: await loadWallet(req.user.id),
  });
}
