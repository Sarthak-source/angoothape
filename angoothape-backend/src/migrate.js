import fs from 'node:fs';
import path from 'node:path';
import { fileURLToPath } from 'node:url';
import { pool } from './db.js';

const here = path.dirname(fileURLToPath(import.meta.url));
const sql = fs.readFileSync(path.join(here, '../sql/schema.sql'), 'utf8');

const client = await pool.connect();
try {
  await client.query(sql);
  console.log('schema applied');
} finally {
  client.release();
  await pool.end();
}
