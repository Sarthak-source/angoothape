import { query } from '../db.js';
import { fail } from '../middleware/error.js';
import { recordRequest } from '../requests.js';

export async function getDevice(req, res) {
  const { rows } = await query(
    'SELECT model, rd_ready, last_tested_at, last_score FROM devices WHERE retailer_id = $1',
    [req.user.id],
  );
  res.json({
    state: req.user.device_state || 'ready',
    device: rows[0] || {
      model: 'L1 RD fingerprint scanner (demo)',
      rd_ready: true,
      last_tested_at: null,
      last_score: null,
    },
  });
}

export async function testDevice(req, res) {
  const score = 78;
  const { rows } = await query(
    `INSERT INTO devices (retailer_id, last_tested_at, last_score, rd_ready)
     VALUES ($1, now(), $2, true)
     ON CONFLICT (retailer_id) DO UPDATE
       SET last_tested_at = now(), last_score = $2, rd_ready = true
     RETURNING model, rd_ready, last_tested_at, last_score`,
    [req.user.id, score],
  );
  res.json({ ok: true, score, device: rows[0] });
}

export async function patchDevice(req, res) {
  const allowed = ['ready', 'disconnected', 'permission'];
  const state = String(req.body?.state || '');
  if (!allowed.includes(state)) throw fail(400, 'invalid', 'Unknown device state');
  await query('UPDATE retailers SET device_state = $2 WHERE id = $1', [
    req.user.id,
    state,
  ]);
  res.json({ state });
}

export async function deviceRequest(req, res) {
  const kind = String(req.body?.kind || '');
  if (!['repair', 'order'].includes(kind)) {
    throw fail(400, 'invalid', 'Unknown device request');
  }
  const row = await recordRequest(req.user.id, `device_${kind}`, req.body || {});
  res.status(201).json({ request: row });
}
