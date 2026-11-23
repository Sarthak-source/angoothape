import { query } from './db.js';
import {
  banks,
  faqs,
  issues,
  futureServices,
  miniTemplate,
  deviceGuides,
  deviceFaqs,
  failReasons,
} from './catalog-data.js';

function refFor(i, at) {
  const d = at.toISOString().slice(2, 10).replace(/-/g, '');
  return `AP${d}${String(148211 + i)}`;
}

function rrn(i) {
  return String(900000000000 + i);
}

export async function seedCatalog() {
  await query('DELETE FROM future_services');
  await query('DELETE FROM issue_types');
  await query('DELETE FROM faqs');
  await query('DELETE FROM banks');
  for (let i = 0; i < banks.length; i++) {
    const b = banks[i];
    await query(
      `INSERT INTO banks (id, name, short, color, popular, ifsc_prefix, sort)
       VALUES ($1,$2,$3,$4,$5,$6,$7)`,
      [b.id, b.name, b.short, b.color, b.popular, b.ifscPrefix, i],
    );
  }
  for (const lang of Object.keys(faqs)) {
    for (let i = 0; i < faqs[lang].length; i++) {
      const item = faqs[lang][i];
      await query(
        `INSERT INTO faqs (lang, sort, question, answer) VALUES ($1,$2,$3,$4)`,
        [lang, i, item[0], item[1]],
      );
    }
  }
  for (const lang of Object.keys(issues)) {
    for (let i = 0; i < issues[lang].length; i++) {
      await query(
        `INSERT INTO issue_types (lang, sort, label) VALUES ($1,$2,$3)`,
        [lang, i, issues[lang][i]],
      );
    }
  }
  for (const lang of Object.keys(futureServices)) {
    for (let i = 0; i < futureServices[lang].length; i++) {
      const [id, label] = futureServices[lang][i];
      await query(
        `INSERT INTO future_services (id, lang, sort, label) VALUES ($1,$2,$3,$4)`,
        [id, lang, i, label],
      );
    }
  }
  await query('DELETE FROM device_guides');
  await query('DELETE FROM device_faqs');
  await query('DELETE FROM fail_reasons');
  for (const [platform, langs] of Object.entries(deviceGuides)) {
    for (const [lang, steps] of Object.entries(langs)) {
      for (let i = 0; i < steps.length; i++) {
        await query(
          `INSERT INTO device_guides (platform, lang, sort, body) VALUES ($1,$2,$3,$4)`,
          [platform, lang, i, steps[i]],
        );
      }
    }
  }
  for (const [lang, items] of Object.entries(deviceFaqs)) {
    for (let i = 0; i < items.length; i++) {
      await query(
        `INSERT INTO device_faqs (lang, sort, question, answers) VALUES ($1,$2,$3,$4)`,
        [lang, i, items[i].q, JSON.stringify(items[i].a)],
      );
    }
  }
  for (const [id, langs] of Object.entries(failReasons)) {
    for (const [lang, copy] of Object.entries(langs)) {
      await query(
        `INSERT INTO fail_reasons (id, lang, text, next) VALUES ($1,$2,$3,$4)`,
        [id, lang, copy.text, copy.next],
      );
    }
  }
}

async function insertMini(transactionId, at) {
  for (let i = 0; i < miniTemplate.length; i++) {
    const line = miniTemplate[i];
    const day = new Date(at);
    day.setDate(day.getDate() - line.daysAgo);
    await query(
      `INSERT INTO mini_statement_lines (transaction_id, sort, label, occurred_on, amount)
       VALUES ($1,$2,$3,$4,$5)`,
      [transactionId, i, line.label, day.toISOString().slice(0, 10), line.amount],
    );
  }
}

export async function seedDemoRetailer(rid) {
  await query('DELETE FROM transactions WHERE retailer_id = $1', [rid]);
  await query('DELETE FROM settlements WHERE retailer_id = $1', [rid]);
  await query('DELETE FROM bank_accounts WHERE retailer_id = $1', [rid]);
  await query('DELETE FROM tickets WHERE retailer_id = $1', [rid]);

  await query(
    `UPDATE retailers SET
       name = $2, shop = $3, city = $4, mobile_mask = $5, role = $6, distributor = $7,
       wallet_main = $8, wallet_aeps = $9, wallet_earn = $10
     WHERE id = $1`,
    [
      rid,
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
  await query(
    `UPDATE retailers SET mobile = '9876543521', lang = 'en', dark = false, text_scale = 1, device_state = 'ready'
      WHERE id = $1`,
    [rid],
  );
  await query(
    `INSERT INTO devices (retailer_id, model, rd_ready)
     VALUES ($1,'L1 RD fingerprint scanner (demo)', true)
     ON CONFLICT (retailer_id) DO UPDATE SET model = EXCLUDED.model, rd_ready = true`,
    [rid],
  );

  const now = Date.now();
  const rows = [
    { ago: 36 * 60e3, amt: 2000, svc: 'cw', bank: 'pnb', a4: '7712', m4: '8841', status: 'success', bal: 14230.55 },
    { ago: 84 * 60e3, amt: 0, svc: 'be', bank: 'sbi', a4: '1094', m4: '2207', status: 'success', bal: 3810 },
    { ago: 132 * 60e3, amt: 5000, svc: 'cw', bank: 'bob', a4: '6630', m4: '5512', status: 'failed', reason: 'insufficient' },
    { ago: 186 * 60e3, amt: 1500, svc: 'cw', bank: 'cbi', a4: '2281', m4: '9930', status: 'pending' },
    { ago: 4 * 3600e3, amt: 3000, svc: 'cw', bank: 'ubi', a4: '5547', m4: '1176', status: 'success', bal: 22104.1 },
    { ago: 26 * 3600e3, amt: 1000, svc: 'cw', bank: 'sbi', a4: '9018', m4: '4420', status: 'success', bal: 6620 },
    { ago: 29 * 3600e3, amt: 0, svc: 'ms', bank: 'cnb', a4: '3375', m4: '6608', status: 'success', bal: 11250.4 },
    { ago: 31 * 3600e3, amt: 2500, svc: 'cw', bank: 'ib', a4: '4402', m4: '7781', status: 'failed', reason: 'bio' },
    { ago: 51 * 3600e3, amt: 500, svc: 'cw', bank: 'boi', a4: '8126', m4: '3349', status: 'success', bal: 1890.75 },
    { ago: 73 * 3600e3, amt: 4000, svc: 'cw', bank: 'pnb', a4: '6619', m4: '2290', status: 'success', bal: 30410 },
    { ago: 102 * 3600e3, amt: 2000, svc: 'cw', bank: 'ippb', a4: '7058', m4: '8014', status: 'success', bal: 9055.2 },
    { ago: 146 * 3600e3, amt: 1000, svc: 'cw', bank: 'bupb', a4: '1563', m4: '5576', status: 'success', bal: 4400 },
    { ago: 12 * 86400e3, amt: 3500, svc: 'cw', bank: 'sbi', a4: '2947', m4: '6631', status: 'success', bal: 17880 },
    { ago: 19 * 86400e3, amt: 1000, svc: 'cw', bank: 'aryb', a4: '8833', m4: '1029', status: 'success', bal: 2600 },
  ];

  let pendingRef = null;
  for (let i = 0; i < rows.length; i++) {
    const r = rows[i];
    const at = new Date(now - r.ago);
    const earn = r.status === 'success' && r.svc === 'cw' ? 5 : 0;
    const inserted = await query(
      `INSERT INTO transactions (
         retailer_id, occurred_at, service, amount, bank_id, aadhaar4, mobile4,
         status, ref, rrn, reason, cust_bal, credited, earn
       ) VALUES ($1,$2,$3,$4,$5,$6,$7,$8,$9,$10,$11,$12,true,$13)
       RETURNING id, ref`,
      [
        rid,
        at,
        r.svc,
        r.amt,
        r.bank,
        r.a4,
        r.m4,
        r.status,
        refFor(i, at),
        rrn(i),
        r.reason ?? null,
        r.bal ?? null,
        earn,
      ],
    );
    if (r.status === 'pending') pendingRef = inserted.rows[0].ref;
    if (r.svc === 'ms') await insertMini(inserted.rows[0].id, at);
  }

  await query(
    `INSERT INTO bank_accounts (retailer_id, bank_id, last4, holder, ifsc, status, is_primary, note)
     VALUES
       ($1,'sbi','4521','RAVI SHARMA','SBIN0001876','active', true, NULL),
       ($1,'hdfc','0912','SHARMA GENERAL STORE','HDFC0002231','pending', false, NULL),
       ($1,'cnb','7781','R SHARMA','CNRB0004410','rejected', false, 'Name on account does not match KYC name.')`,
    [rid],
  );

  await query(
    `INSERT INTO settlements (retailer_id, public_id, amount, acct_bank, status, utr, note, created_at)
     VALUES
       ($1,'ST-10441',4000,'sbi','processing',NULL,NULL, now() - interval '2 hours'),
       ($1,'ST-10432',12000,'sbi','settled','SBIN226110987',NULL, now() - interval '22 hours'),
       ($1,'ST-10419',8500,'sbi','settled','SBIN226108874',NULL, now() - interval '2 days'),
       ($1,'ST-10398',3000,'cnb','reversed',NULL,'Account details rejected by bank. Amount returned to AEPS balance.', now() - interval '5 days')`,
    [rid],
  );

  await query(
    `INSERT INTO tickets (retailer_id, public_id, type, status, message, ref, created_at)
     VALUES ($1,'SR-20871','Pending transaction','In review','Customer says cash not received, status pending.', $2, now() - interval '2 days')`,
    [rid, pendingRef],
  );
}
