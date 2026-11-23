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
    const [banks, faqs, issues, services, guides, deviceFaqs, reasons] =
      await Promise.all([
        query('SELECT * FROM banks ORDER BY sort, id'),
        query('SELECT lang, sort, question, answer FROM faqs ORDER BY lang, sort'),
        query('SELECT lang, sort, label FROM issue_types ORDER BY lang, sort'),
        query(
          'SELECT id, lang, sort, label FROM future_services ORDER BY lang, sort',
        ),
        query(
          'SELECT platform, lang, sort, body FROM device_guides ORDER BY platform, lang, sort',
        ),
        query(
          'SELECT lang, sort, question, answers FROM device_faqs ORDER BY lang, sort',
        ),
        query('SELECT id, lang, text, next FROM fail_reasons'),
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
    const deviceGuides = {};
    for (const row of guides.rows) {
      ((deviceGuides[row.platform] ||= {})[row.lang] ||= []).push(row.body);
    }
    const deviceFaqsByLang = { en: [], hi: [] };
    for (const row of deviceFaqs.rows) {
      (deviceFaqsByLang[row.lang] ||= []).push({
        q: row.question,
        a: Array.isArray(row.answers) ? row.answers : [],
      });
    }
    const failReasons = {};
    for (const row of reasons.rows) {
      (failReasons[row.id] ||= {})[row.lang] = {
        text: row.text,
        next: row.next,
      };
    }
    res.json({
      banks: banks.rows.map(mapBank),
      faqs: faqsByLang,
      issues: issuesByLang,
      futureServices: futureByLang,
      deviceGuides,
      deviceFaqs: deviceFaqsByLang,
      failReasons,
    });
  } catch (err) {
    next(err);
  }
});
