import nodemailer from 'nodemailer';
import { config } from './config.js';

function transport() {
  if (!config.smtpHost) return null;
  return nodemailer.createTransport({
    host: config.smtpHost,
    port: config.smtpPort,
    secure: config.smtpPort === 465,
    auth:
      config.smtpUser && config.smtpPass
        ? { user: config.smtpUser, pass: config.smtpPass }
        : undefined,
  });
}

function maskEmail(email) {
  const v = String(email || '');
  const at = v.indexOf('@');
  if (at < 1) return 'your email';
  const name = v.slice(0, at);
  const domain = v.slice(at);
  const shown = name.length <= 2 ? `${name[0] || ''}*` : `${name.slice(0, 2)}***`;
  return `${shown}${domain}`;
}

export { maskEmail };

export async function sendOtpEmail({ to, code, purpose = 'login' }) {
  const subject =
    purpose === 'reset'
      ? 'angoothaPe password reset code'
      : 'angoothaPe login verification code';
  const text = `Your ${purpose === 'reset' ? 'password reset' : 'login'} code is ${code}. It expires in 5 minutes. Do not share this code.`;
  const html = `<p>Your ${purpose === 'reset' ? 'password reset' : 'login'} code is <strong>${code}</strong>.</p><p>It expires in 5 minutes. Do not share this code.</p>`;

  const tx = transport();
  if (tx && to) {
    await tx.sendMail({
      from: config.mailFrom,
      to,
      subject,
      text,
      html,
    });
    return { sent: true, to };
  }
  console.log(`[mail] ${subject} → ${to || '(no email)'}: ${code}`);
  return { sent: false, to };
}
