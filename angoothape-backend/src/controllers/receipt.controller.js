import { query } from '../db.js';
import { fail } from '../middleware/error.js';
import { recordRequest } from '../requests.js';

export async function receiptAction(req, res) {
  const kind = String(req.body?.kind || '');
  if (!['print', 'share', 'download'].includes(kind)) {
    throw fail(400, 'invalid', 'Unknown receipt action');
  }
  const tx = await query(
    'SELECT ref FROM transactions WHERE retailer_id = $1 AND ref = $2',
    [req.user.id, req.params.ref],
  );
  if (!tx.rows[0]) throw fail(404, 'not_found', 'Transaction not found');
  const row = await recordRequest(req.user.id, `receipt_${kind}`, {
    ref: req.params.ref,
  });
  res.status(201).json({ request: row });
}

export async function createExport(req, res) {
  const row = await recordRequest(req.user.id, 'export', {
    range: req.body?.range || '30',
    format: req.body?.format || 'csv',
  });
  res.status(201).json({ request: row });
}
