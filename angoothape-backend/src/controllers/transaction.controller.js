import { query } from '../db.js';
import { fail } from '../middleware/error.js';
import { attachMinis, loadWallet } from '../utils/tx.js';

export async function listTransactions(req, res) {
  const qtext = String(req.query.q || '').trim().toLowerCase();
  const status = String(req.query.status || 'all');
  const svc = String(req.query.svc || 'all');
  const days = Number(req.query.range || 30);
  const params = [req.user.id];
  const where = ['retailer_id = $1'];
  if (status !== 'all') {
    params.push(status);
    where.push(`status = $${params.length}`);
  }
  if (svc !== 'all') {
    params.push(svc);
    where.push(`service = $${params.length}`);
  }
  if (days <= 1) {
    where.push(`occurred_at::date = CURRENT_DATE`);
  } else {
    params.push(days);
    where.push(`occurred_at >= now() - make_interval(days => $${params.length})`);
  }
  if (qtext) {
    params.push(`%${qtext}%`);
    const i = params.length;
    where.push(
      `(lower(ref) LIKE $${i} OR lower(rrn) LIKE $${i} OR aadhaar4 LIKE $${i} OR mobile4 LIKE $${i} OR lower(bank_id) LIKE $${i})`,
    );
  }
  const { rows } = await query(
    `SELECT * FROM transactions WHERE ${where.join(' AND ')}
     ORDER BY occurred_at DESC LIMIT 200`,
    params,
  );
  res.json({ tx: await attachMinis(rows) });
}

export async function getTransaction(req, res) {
  const { rows } = await query(
    `SELECT * FROM transactions WHERE retailer_id = $1 AND ref = $2`,
    [req.user.id, req.params.ref],
  );
  if (!rows[0]) throw fail(404, 'not_found', 'Transaction not found');
  res.json({ tx: (await attachMinis(rows))[0] });
}

export async function checkTransaction(req, res) {
  const { rows } = await query(
    `SELECT * FROM transactions WHERE retailer_id = $1 AND ref = $2`,
    [req.user.id, req.params.ref],
  );
  const tx = rows[0];
  if (!tx) throw fail(404, 'not_found', 'Transaction not found');
  if (tx.status !== 'pending') {
    return res.json({ tx: (await attachMinis([tx]))[0] });
  }
  const checks = tx.checks + 1;
  const resolveAs = String(req.body?.resolve || 'success');
  const stillPending = !tx.unknown && checks < 2;
  if (stillPending) {
    await query(`UPDATE transactions SET checks = $2 WHERE id = $1`, [
      tx.id,
      checks,
    ]);
    tx.checks = checks;
    return res.json({ tx: (await attachMinis([tx]))[0], stillPending: true });
  }
  let status = resolveAs === 'failed' ? 'failed' : 'success';
  let reason = status === 'failed' ? 'timeout' : null;
  let bal =
    status === 'success'
      ? Math.round((2500 + Math.random() * 24000) * 100) / 100
      : null;
  let earn = tx.earn;
  let credited = tx.credited;
  if (status === 'success' && tx.service === 'cw' && !credited) {
    earn = 5;
    credited = true;
    await query(
      `UPDATE retailers
          SET wallet_aeps = wallet_aeps + $2,
              wallet_earn = wallet_earn + $3
        WHERE id = $1`,
      [req.user.id, tx.amount, earn],
    );
  }
  await query(
    `UPDATE transactions
        SET status = $2, unknown = false, checks = $3, reason = $4,
            cust_bal = $5, earn = $6, credited = $7
      WHERE id = $1`,
    [tx.id, status, checks, reason, bal, earn, credited],
  );
  const fresh = await query('SELECT * FROM transactions WHERE id = $1', [tx.id]);
  res.json({
    tx: (await attachMinis(fresh.rows))[0],
    wallet: await loadWallet(req.user.id),
  });
}
