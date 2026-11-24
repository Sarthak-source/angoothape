import { query } from '../db.js';

export function money(v) {
  return Number(v);
}

export function walletFrom(row) {
  return {
    main: money(row.wallet_main),
    aeps: money(row.wallet_aeps),
    earn: money(row.wallet_earn),
  };
}

export async function loadWallet(retailerId) {
  const { rows } = await query(
    'SELECT wallet_main, wallet_aeps, wallet_earn FROM retailers WHERE id = $1',
    [retailerId],
  );
  return walletFrom(rows[0]);
}

export function mapTx(row, mini = []) {
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

export async function attachMinis(txRows) {
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
