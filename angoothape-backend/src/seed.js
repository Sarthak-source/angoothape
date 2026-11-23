import argon2 from 'argon2';
import { pool, query } from './db.js';
import { seedCatalog, seedDemoRetailer } from './demo-seed.js';

const DEMO_ID = 'AP100245';
const DEMO_PW = 'Demo@123';

await query('SELECT 1');
await seedCatalog();

const hash = await argon2.hash(DEMO_PW, { type: argon2.argon2id });
const retailer = await query(
  `INSERT INTO retailers (
      partner_id, password_hash, name, shop, city, mobile_mask, role, distributor,
      wallet_main, wallet_aeps, wallet_earn
    ) VALUES ($1,$2,$3,$4,$5,$6,$7,$8,$9,$10,$11)
    ON CONFLICT (partner_id) DO UPDATE SET
      password_hash = EXCLUDED.password_hash
    RETURNING id`,
  [
    DEMO_ID,
    hash,
    'Ravi Sharma',
    'Sharma General Store',
    'Aminabad, Lucknow, UP',
    '98•••••521',
    'Retailer / Franchisee',
    'Verma Distribution (AD20031)',
    18450,
    6500,
    412.5,
  ],
);

await seedDemoRetailer(retailer.rows[0].id);

console.log(`seeded ${DEMO_ID} / ${DEMO_PW}`);
await pool.end();
