import { Router } from 'express';
import crypto from 'node:crypto';
import { query } from '../db.js';
import { fail } from '../middleware/error.js';

export const joinRouter = Router();

function mapApp(row) {
  return {
    id: row.public_id,
    role: row.role,
    status: row.status,
    createdAt: row.created_at,
  };
}

joinRouter.post('/', async (req, res, next) => {
  try {
    const role = String(req.body?.role || 'retailer').trim();
    const fields = req.body?.fields && typeof req.body.fields === 'object'
      ? req.body.fields
      : {};
    const docs = req.body?.docs && typeof req.body.docs === 'object'
      ? req.body.docs
      : {};
    if (!['retailer', 'distributor', 'super'].includes(role)) {
      throw fail(400, 'invalid', 'Choose a role');
    }
    const publicId = `APP-26-${crypto.randomInt(100000, 999999)}`;
    const inserted = await query(
      `INSERT INTO applications (public_id, role, payload, status)
       VALUES ($1,$2,$3,'submitted')
       RETURNING public_id, role, status, created_at`,
      [publicId, role, JSON.stringify({ fields, docs })],
    );
    res.status(201).json({ application: mapApp(inserted.rows[0]) });
  } catch (err) {
    next(err);
  }
});

joinRouter.post('/:id/approve', async (req, res, next) => {
  try {
    const { rows } = await query(
      `UPDATE applications SET status = 'approved'
        WHERE public_id = $1
        RETURNING public_id, role, status, created_at`,
      [req.params.id],
    );
    if (!rows[0]) throw fail(404, 'not_found', 'Application not found');
    res.json({ application: mapApp(rows[0]) });
  } catch (err) {
    next(err);
  }
});
