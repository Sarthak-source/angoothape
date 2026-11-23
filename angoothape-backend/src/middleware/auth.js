import jwt from 'jsonwebtoken';
import { config } from '../config.js';
import { query } from '../db.js';
import { fail } from './error.js';

export function signToken(retailer) {
  return jwt.sign(
    { sub: retailer.id, partnerId: retailer.partner_id },
    config.jwtSecret,
    { expiresIn: config.jwtExpires },
  );
}

export function setAuthCookie(res, token) {
  res.cookie(config.cookieName, token, {
    httpOnly: true,
    sameSite: 'lax',
    secure: !config.isDev,
    maxAge: 12 * 60 * 60 * 1000,
    path: '/',
  });
}

export function clearAuthCookie(res) {
  res.clearCookie(config.cookieName, { path: '/' });
}

export async function requireAuth(req, _res, next) {
  try {
    const header = req.headers.authorization || '';
    const bearer = header.startsWith('Bearer ') ? header.slice(7) : '';
    const token = bearer || req.cookies?.[config.cookieName];
    if (!token) throw fail(401, 'unauthenticated', 'Sign in required');
    let payload;
    try {
      payload = jwt.verify(token, config.jwtSecret);
    } catch {
      throw fail(401, 'unauthenticated', 'Session expired');
    }
    const { rows } = await query(
      `SELECT id, partner_id, name, shop, city, mobile_mask, mobile, role, distributor,
              wallet_main, wallet_aeps, wallet_earn, lang, dark, text_scale, device_state
         FROM retailers WHERE id = $1`,
      [payload.sub],
    );
    if (!rows[0]) throw fail(401, 'unauthenticated', 'Sign in required');
    req.user = rows[0];
    next();
  } catch (err) {
    next(err);
  }
}
