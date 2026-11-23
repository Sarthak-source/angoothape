import { Router } from 'express';
import crypto from 'node:crypto';
import { query } from '../db.js';
import { requireAuth } from '../middleware/auth.js';
import { fail } from '../middleware/error.js';
import { miniTemplate } from '../catalog-data.js';
import { seedDemoRetailer } from '../demo-seed.js';

export const sessionRouter = Router();
sessionRouter.use(requireAuth);

function money(v) {
  return Number(v);
}

function mapTx(row, mini = []) {
  return {
    ref: row.ref,
    rrn: row.rrn,
    t: row.occurred_at,
    svc: row.service,
    amt: Number(row.amount),
    bank: row.bank_id,
    aadhaar4: row.aadhaar4,
    mobile4: row.mobile4,
    status: row.status,
    reason: row.reason,
    bal: row.cust_bal == null ? null : money(row.cust_bal),
    unknown: row.unknown,
    earn: money(row.earn),
    checks: row.checks,
    credited: row.credited,
    mini,
  };
}

async function attachMinis(txRows) {
  if (!txRows.length) return txRows.map((row) => mapTx(row));
  const ids = txRows.map((r) => r.id);
  const { rows } = await query(
    `SELECT transaction_id, sort, label, occurred_on::text AS occurred_on, amount
       FROM mini_statement_lines
      WHERE transaction_id = ANY($1::uuid[])
      ORDER BY sort`,
    [ids],
  );
  const byTx = new Map();
  for (const line of rows) {
    const list = byTx.get(line.transaction_id) || [];
    list.push({
      label: line.label,
      date: line.occurred_on,
      amount: Number(line.amount),
    });
    byTx.set(line.transaction_id, list);
  }
  return txRows.map((row) => mapTx(row, byTx.get(row.id) || []));
}

async function insertMini(transactionId, at = new Date()) {
  for (let i = 0; i < miniTemplate.length; i++) {
    const line = miniTemplate[i];
    const day = new Date(at);
    day.setDate(day.getDate() - line.daysAgo);
    await query(
      `INSERT INTO mini_statement_lines (transaction_id, sort, label, occurred_on, amount)
       VALUES ($1,$2,$3,$4,$5)`,
      [transactionId, i, line.label, day.toISOString().slice(0, 10), line.amount],
    );
  }
}

sessionRouter.get('/me', async (req, res, next) => {
  try {
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
        role: u.role,
        distributor: u.distributor,
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
  } catch (err) {
    next(err);
  }
});

sessionRouter.get('/transactions', async (req, res, next) => {
  try {
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
  } catch (err) {
    next(err);
  }
});

sessionRouter.get('/transactions/:ref', async (req, res, next) => {
  try {
    const { rows } = await query(
      `SELECT * FROM transactions WHERE retailer_id = $1 AND ref = $2`,
      [req.user.id, req.params.ref],
    );
    if (!rows[0]) throw fail(404, 'not_found', 'Transaction not found');
    res.json({ tx: (await attachMinis(rows))[0] });
  } catch (err) {
    next(err);
  }
});

sessionRouter.post('/demo/reset', async (req, res, next) => {
  try {
    if (req.user.partner_id !== 'AP100245') {
      throw fail(403, 'forbidden', 'Demo reset is only for the sample retailer');
    }
    await seedDemoRetailer(req.user.id);
    res.json({ ok: true });
  } catch (err) {
    next(err);
  }
});

sessionRouter.post('/aeps', async (req, res, next) => {
  try {
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
    const { rows } = await query('SELECT * FROM transactions WHERE ref = $1', [
      ref,
    ]);
    if (svc === 'ms' && rows[0]) await insertMini(rows[0].id, now);
    const { rows: w } = await query(
      'SELECT wallet_main, wallet_aeps, wallet_earn FROM retailers WHERE id = $1',
      [req.user.id],
    );
    res.status(201).json({
      tx: (await attachMinis(rows))[0],
      wallet: {
        main: money(w[0].wallet_main),
        aeps: money(w[0].wallet_aeps),
        earn: money(w[0].wallet_earn),
      },
    });
  } catch (err) {
    next(err);
  }
});

sessionRouter.post('/transactions/:ref/check', async (req, res, next) => {
  try {
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
    const fresh = await query('SELECT * FROM transactions WHERE id = $1', [
      tx.id,
    ]);
    const { rows: w } = await query(
      'SELECT wallet_main, wallet_aeps, wallet_earn FROM retailers WHERE id = $1',
      [req.user.id],
    );
    res.json({
      tx: (await attachMinis(fresh.rows))[0],
      wallet: {
        main: money(w[0].wallet_main),
        aeps: money(w[0].wallet_aeps),
        earn: money(w[0].wallet_earn),
      },
    });
  } catch (err) {
    next(err);
  }
});

sessionRouter.post('/settlements', async (req, res, next) => {
  try {
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
    const w = await query(
      'SELECT wallet_main, wallet_aeps, wallet_earn FROM retailers WHERE id = $1',
      [req.user.id],
    );
    res.status(201).json({
      settlement: { ...inserted.rows[0], amt: Number(inserted.rows[0].amt) },
      wallet: {
        main: money(w.rows[0].wallet_main),
        aeps: money(w.rows[0].wallet_aeps),
        earn: money(w.rows[0].wallet_earn),
      },
    });
  } catch (err) {
    next(err);
  }
});

sessionRouter.post('/accounts', async (req, res, next) => {
  try {
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
    const map = {
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
    const bank = map[ifsc.slice(0, 4)] || 'sbi';
    const inserted = await query(
      `INSERT INTO bank_accounts (retailer_id, bank_id, last4, holder, ifsc, status)
       VALUES ($1,$2,$3,$4,$5,'pending')
       RETURNING id, bank_id AS bank, last4, holder, ifsc, status, is_primary AS "primary", note`,
      [req.user.id, bank, acct.slice(-4), holder, ifsc],
    );
    res.status(201).json({ account: inserted.rows[0] });
  } catch (err) {
    next(err);
  }
});

sessionRouter.post('/tickets', async (req, res, next) => {
  try {
    const type = String(req.body?.type || '').trim();
    const message = String(req.body?.message || '').trim();
    const ref = String(req.body?.ref || '').trim() || null;
    if (!type || message.length < 10) {
      throw fail(400, 'invalid', 'Choose a type and describe the issue');
    }
    const count = await query(
      'SELECT count(*)::int AS n FROM tickets WHERE retailer_id = $1',
      [req.user.id],
    );
    const publicId = `SR-${20900 + count.rows[0].n}`;
    const inserted = await query(
      `INSERT INTO tickets (retailer_id, public_id, type, status, message, ref)
       VALUES ($1,$2,$3,'Open',$4,$5)
       RETURNING public_id AS id, created_at AS t, type, status, message AS msg, ref`,
      [req.user.id, publicId, type, message, ref],
    );
    res.status(201).json({ ticket: inserted.rows[0] });
  } catch (err) {
    next(err);
  }
});
