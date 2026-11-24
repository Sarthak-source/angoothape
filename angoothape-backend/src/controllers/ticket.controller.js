import { query } from '../db.js';
import { fail } from '../middleware/error.js';

export async function createTicket(req, res) {
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
}
