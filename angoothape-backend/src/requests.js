import { query } from './db.js';

export function maskMobile(value) {
  const d = String(value || '').replace(/\D/g, '');
  if (d.length < 5) return value || '';
  return `${d.slice(0, 2)}•••••${d.slice(-3)}`;
}

export async function recordRequest(retailerId, kind, payload = {}) {
  const inserted = await query(
    `INSERT INTO service_requests (retailer_id, kind, payload)
     VALUES ($1,$2,$3)
     RETURNING id, kind, status, created_at`,
    [retailerId || null, kind, JSON.stringify(payload)],
  );
  return inserted.rows[0];
}
