#!/usr/bin/env node
/**
 * Generates docs/Angoothape-API.postman_collection.json
 * Run: npm run postman
 */

import { mkdirSync, writeFileSync } from 'fs';
import { dirname, join } from 'path';
import { fileURLToPath } from 'url';

const __dirname = dirname(fileURLToPath(import.meta.url));
const OUT = join(__dirname, '../docs/Angoothape-API.postman_collection.json');

/** @typedef {{ name: string, method: string, path: string, auth?: boolean, body?: object, query?: Record<string,string>, description?: string, test?: string[] }} Endpoint */

/** @type {{ name: string, description?: string, item: Endpoint[] }[]} */
const modules = [
  {
    name: '0. Health',
    description: 'Process liveness. No auth.',
    item: [{ name: 'Health', method: 'GET', path: '/health', auth: false }],
  },
  {
    name: '1. Auth',
    description:
      'MFA login: password → authenticator PIN → email OTP. JWT is issued only after both.\nDemo seed: AP100245 / Demo@123.\nSet DEV_RETURN_OTP=1 so Login/Resend return `otp` and `totp` for Postman.\nAfter Verify OTP, send `Authorization: Bearer {{authToken}}` (cookie `ap_token` also works).',
    item: [
      {
        name: 'Login',
        method: 'POST',
        path: '/auth/login',
        auth: false,
        body: { partnerId: '{{partnerId}}', password: '{{password}}' },
        test: [
          'const j = pm.response.json();',
          "const cid = (j.mfa && j.mfa.challengeId) || j.challengeId;",
          "if (cid) pm.collectionVariables.set('challengeId', String(cid));",
          "if (j.otp) pm.collectionVariables.set('otp', j.otp);",
          "if (j.totp) pm.collectionVariables.set('totp', j.totp);",
        ],
      },
      {
        name: 'Verify TOTP',
        method: 'POST',
        path: '/auth/totp',
        auth: false,
        body: {
          partnerId: '{{partnerId}}',
          totp: '{{totp}}',
          challengeId: '{{challengeId}}',
        },
      },
      {
        name: 'Verify OTP',
        method: 'POST',
        path: '/auth/otp',
        auth: false,
        body: {
          partnerId: '{{partnerId}}',
          otp: '{{otp}}',
          challengeId: '{{challengeId}}',
        },
        test: [
          'const j = pm.response.json();',
          "if (j.token) pm.collectionVariables.set('authToken', j.token);",
        ],
      },
      {
        name: 'Resend OTP',
        method: 'POST',
        path: '/auth/resend',
        auth: false,
        body: { partnerId: '{{partnerId}}' },
        test: [
          'const j = pm.response.json();',
          "const cid = (j.mfa && j.mfa.challengeId) || j.challengeId;",
          "if (cid) pm.collectionVariables.set('challengeId', String(cid));",
          "if (j.otp) pm.collectionVariables.set('otp', j.otp);",
        ],
      },
      {
        name: 'Forgot password',
        method: 'POST',
        path: '/auth/forgot',
        auth: false,
        body: { partnerId: '{{partnerId}}' },
        test: [
          'const j = pm.response.json();',
          "if (j.otp) pm.collectionVariables.set('otp', j.otp);",
        ],
      },
      {
        name: 'Forgot confirm',
        method: 'POST',
        path: '/auth/forgot/confirm',
        auth: false,
        body: {
          partnerId: '{{partnerId}}',
          otp: '{{otp}}',
          password: '{{password}}',
        },
      },
      { name: 'Logout', method: 'POST', path: '/auth/logout', auth: false },
    ],
  },
  {
    name: '2. Catalog',
    item: [{ name: 'Get catalog', method: 'GET', path: '/catalog', auth: false }],
  },
  {
    name: '3. Join / onboarding',
    item: [
      {
        name: 'Create eKYC',
        method: 'POST',
        path: '/join/ekyc',
        auth: false,
        body: { pan: 'ABCDE1234F' },
        test: [
          'const j = pm.response.json();',
          "const id = j.ekyc?.id;",
          "if (id) pm.collectionVariables.set('ekycId', id);",
        ],
      },
      {
        name: 'Submit application',
        method: 'POST',
        path: '/join',
        auth: false,
        body: {
          role: 'retailer',
          ekycId: '{{ekycId}}',
          fields: { name: 'Ravi Sharma', shop: 'Sharma General Store' },
          docs: {},
        },
        test: [
          'const j = pm.response.json();',
          "const id = j.application?.id;",
          "if (id) pm.collectionVariables.set('applicationId', id);",
        ],
      },
      {
        name: 'Approve application',
        method: 'POST',
        path: '/join/{{applicationId}}/approve',
        auth: false,
      },
    ],
  },
  {
    name: '4. Me',
    item: [
      { name: 'Get me', method: 'GET', path: '/api/me' },
      {
        name: 'Update me',
        method: 'PATCH',
        path: '/api/me',
        body: {
          name: 'Ravi Sharma',
          shop: 'Sharma General Store',
          city: 'Aminabad, Lucknow, UP',
          mobile: '9876543521',
        },
      },
      {
        name: 'Update preferences',
        method: 'PATCH',
        path: '/api/me/preferences',
        body: { lang: 'en', dark: false, scale: 1 },
      },
      {
        name: 'Change password',
        method: 'POST',
        path: '/api/me/password',
        body: { current: '{{password}}', next: '{{password}}' },
      },
      { name: 'Demo reset', method: 'POST', path: '/api/demo/reset' },
    ],
  },
  {
    name: '5. Transactions',
    item: [
      {
        name: 'List transactions',
        method: 'GET',
        path: '/api/transactions',
        query: { q: '', status: 'all', svc: 'all', range: '30' },
        test: [
          'const j = pm.response.json();',
          'const first = Array.isArray(j.tx) ? j.tx[0] : null;',
          "if (first?.ref) pm.collectionVariables.set('txRef', first.ref);",
        ],
      },
      { name: 'Get transaction', method: 'GET', path: '/api/transactions/{{txRef}}' },
      {
        name: 'Check pending transaction',
        method: 'POST',
        path: '/api/transactions/{{txRef}}/check',
        body: { resolve: 'success' },
      },
    ],
  },
  {
    name: '6. AePS',
    item: [
      {
        name: 'Submit AePS',
        method: 'POST',
        path: '/api/aeps',
        body: {
          svc: 'cw',
          bank: 'sbi',
          amount: 500,
          aadhaar4: '1234',
          mobile4: '3521',
          outcome: 'success',
        },
        test: [
          'const j = pm.response.json();',
          "const ref = j.tx?.ref;",
          "if (ref) pm.collectionVariables.set('txRef', ref);",
        ],
      },
    ],
  },
  {
    name: '7. Wallet',
    item: [
      {
        name: 'Create settlement',
        method: 'POST',
        path: '/api/settlements',
        body: { amount: 1000 },
      },
      {
        name: 'Add bank account',
        method: 'POST',
        path: '/api/accounts',
        body: {
          holder: 'RAVI SHARMA',
          acct: '123456789012',
          acct2: '123456789012',
          ifsc: 'SBIN0001234',
        },
      },
      {
        name: 'Wallet top-up',
        method: 'POST',
        path: '/api/wallet/topup',
        body: { amount: 500 },
      },
    ],
  },
  {
    name: '8. Tickets',
    item: [
      {
        name: 'Create ticket',
        method: 'POST',
        path: '/api/tickets',
        body: { type: 'txn', message: 'Need help with a transaction', ref: '{{txRef}}' },
      },
    ],
  },
  {
    name: '9. Device',
    item: [
      { name: 'Get device', method: 'GET', path: '/api/device' },
      { name: 'Test device', method: 'POST', path: '/api/device/test' },
      {
        name: 'Patch device state',
        method: 'PATCH',
        path: '/api/device',
        body: { state: 'paired' },
      },
      {
        name: 'Device request',
        method: 'POST',
        path: '/api/device/requests',
        body: { kind: 'replace' },
      },
    ],
  },
  {
    name: '10. Receipts & exports',
    item: [
      {
        name: 'Receipt action',
        method: 'POST',
        path: '/api/receipts/{{txRef}}/actions',
        body: { kind: 'share' },
      },
      {
        name: 'Create export',
        method: 'POST',
        path: '/api/exports',
        body: { range: '30', format: 'csv' },
      },
    ],
  },
];

/** @param {Endpoint} ep */
function buildRequest(ep) {
  const needsAuth = ep.auth !== false;
  const headers = [{ key: 'Content-Type', value: 'application/json' }];
  if (needsAuth) {
    headers.push({ key: 'Authorization', value: 'Bearer {{authToken}}' });
  }

  const pathParts = ep.path.replace(/^\//, '').split('/');
  const url = {
    raw: `{{baseUrl}}${ep.path}`,
    host: ['{{baseUrl}}'],
    path: pathParts,
  };

  if (ep.query) {
    url.query = Object.entries(ep.query).map(([key, value]) => ({ key, value }));
    const qs = new URLSearchParams(ep.query).toString();
    url.raw = `{{baseUrl}}${ep.path}?${qs}`;
  }

  const req = {
    method: ep.method,
    header: headers,
    url,
  };

  if (ep.body && ['POST', 'PUT', 'PATCH', 'DELETE'].includes(ep.method)) {
    req.body = { mode: 'raw', raw: JSON.stringify(ep.body, null, 2) };
  }

  if (ep.description) req.description = ep.description;

  const item = { name: ep.name, request: req };
  if (ep.test?.length) {
    item.event = [
      {
        listen: 'test',
        script: { type: 'text/javascript', exec: ep.test },
      },
    ];
  }
  return item;
}

function buildFolder(mod) {
  return {
    name: mod.name,
    description: mod.description,
    item: mod.item.map((ep) => buildRequest(ep)),
  };
}

const collection = {
  info: {
    name: 'angoothaPe — Backend API',
    _postman_id: 'angoothape-backend-api-v1',
    description:
      'REST API for angoothaPe retailer backend.\n\n**Setup**\n1. Set `baseUrl` (default `http://localhost:8080`)\n2. Seed: `npm run seed` (demo `AP100245` / `Demo@123`)\n3. Run **Login** then **Verify OTP** (MFA). With `DEV_RETURN_OTP=1`, OTP and `authToken` are saved automatically.\n\n**Auth:** JWT via `Authorization: Bearer {{authToken}}` or cookie `ap_token`. Token is not issued until OTP succeeds.',
    schema: 'https://schema.getpostman.com/json/collection/v2.1.0/collection.json',
  },
  variable: [
    { key: 'baseUrl', value: 'http://localhost:8080' },
    { key: 'partnerId', value: 'AP100245' },
    { key: 'password', value: 'Demo@123' },
    { key: 'otp', value: '' },
    { key: 'totp', value: '' },
    { key: 'authToken', value: '' },
    { key: 'challengeId', value: '' },
    { key: 'ekycId', value: '' },
    { key: 'applicationId', value: '' },
    { key: 'txRef', value: '' },
  ],
  item: modules.map(buildFolder),
};

mkdirSync(dirname(OUT), { recursive: true });
writeFileSync(OUT, `${JSON.stringify(collection, null, 2)}\n`);
const n = modules.reduce((acc, m) => acc + m.item.length, 0);
console.log(`Postman collection written to ${OUT}`);
console.log(`  ${modules.length} folders, ${n} requests`);
