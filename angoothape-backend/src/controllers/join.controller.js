import crypto from 'node:crypto';
import { query } from '../db.js';
import { fail } from '../middleware/error.js';

function mapApp(row) {
  return {
    id: row.public_id,
    role: row.role,
    status: row.status,
    createdAt: row.created_at,
  };
}

export async function createEkyc(req, res) {
  const pan = String(req.body?.pan || '')
    .trim()
    .toUpperCase();
  if (!/^[A-Z]{5}[0-9]{4}[A-Z]$/.test(pan)) {
    throw fail(400, 'invalid', 'Enter a valid PAN');
  }
  const publicId = `EKYC-${crypto.randomInt(100000, 999999)}`;
  const inserted = await query(
    `INSERT INTO ekyc_checks (public_id, pan, verified)
     VALUES ($1,$2,true)
     RETURNING public_id AS id, verified`,
    [publicId, pan],
  );
  res.status(201).json({ ekyc: inserted.rows[0] });
}

export async function createApplication(req, res) {
  const role = String(req.body?.role || 'retailer').trim();
  const fields =
    req.body?.fields && typeof req.body.fields === 'object' ? req.body.fields : {};
  const docs =
    req.body?.docs && typeof req.body.docs === 'object' ? req.body.docs : {};
  if (!['retailer', 'distributor', 'super'].includes(role)) {
    throw fail(400, 'invalid', 'Choose a role');
  }
  const publicId = `APP-26-${crypto.randomInt(100000, 999999)}`;
  const inserted = await query(
    `INSERT INTO applications (public_id, role, payload, status)
     VALUES ($1,$2,$3,'submitted')
     RETURNING public_id, role, status, created_at`,
    [
      publicId,
      role,
      JSON.stringify({ fields, docs, ekycId: req.body?.ekycId || null }),
    ],
  );
  res.status(201).json({ application: mapApp(inserted.rows[0]) });
}

export async function approveApplication(req, res) {
  const { rows } = await query(
    `UPDATE applications SET status = 'approved'
      WHERE public_id = $1
      RETURNING public_id, role, status, created_at`,
    [req.params.id],
  );
  if (!rows[0]) throw fail(404, 'not_found', 'Application not found');
  res.json({ application: mapApp(rows[0]) });
}
