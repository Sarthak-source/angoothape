import { Router } from 'express';
import { query } from '../db.js';

export const catalogRouter = Router();

function mapBank(row) {
  return {
    id: row.id,
    name: row.name,
    short: row.short,
    color: Number(row.color),
    popular: row.popular,
    ifscPrefix: row.ifsc_prefix,
  };
}

catalogRouter.get('/', async (_req, res, next) => {
  try {
    const [banks, faqs, issues, services] = await Promise.all([
      query('SELECT * FROM banks ORDER BY sort, id'),
      query('SELECT lang, sort, question, answer FROM faqs ORDER BY lang, sort'),
      query('SELECT lang, sort, label FROM issue_types ORDER BY lang, sort'),
      query(
        'SELECT id, lang, sort, label FROM future_services ORDER BY lang, sort',
      ),
    ]);
    const faqsByLang = { en: [], hi: [] };
    for (const row of faqs.rows) {
      (faqsByLang[row.lang] ||= []).push({
        q: row.question,
        a: row.answer,
      });
    }
    const issuesByLang = { en: [], hi: [] };
    for (const row of issues.rows) {
      (issuesByLang[row.lang] ||= []).push(row.label);
    }
    const futureByLang = { en: [], hi: [] };
    for (const row of services.rows) {
      (futureByLang[row.lang] ||= []).push({ id: row.id, label: row.label });
    }
    res.json({
      banks: banks.rows.map(mapBank),
      faqs: faqsByLang,
      issues: issuesByLang,
      futureServices: futureByLang,
    });
  } catch (err) {
    next(err);
  }
});
