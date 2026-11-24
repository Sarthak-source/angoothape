import 'dotenv/config';

function required(name, fallback) {
  const v = process.env[name] ?? fallback;
  if (v === undefined || v === '') {
    throw new Error(`Missing env ${name}`);
  }
  return v;
}

export const config = {
  port: Number(process.env.PORT || 8080),
  env: process.env.NODE_ENV || 'development',
  isDev: (process.env.NODE_ENV || 'development') !== 'production',
  databaseUrl: required(
    'DATABASE_URL',
    'postgres://angoothape:angoothape@localhost:5432/angoothape',
  ),
  jwtSecret: required('JWT_SECRET', 'dev-only-change-me'),
  jwtExpires: process.env.JWT_EXPIRES || '12h',
  cookieName: process.env.COOKIE_NAME || 'ap_token',
  mfaMaxAttempts: Number(process.env.MFA_MAX_ATTEMPTS || 5),
  corsOrigins: (process.env.CORS_ORIGIN || 'http://localhost:8080')
    .split(',')
    .map((s) => s.trim())
    .filter(Boolean),
  devReturnOtp: process.env.DEV_RETURN_OTP === '1',
  smtpHost: process.env.SMTP_HOST || '',
  smtpPort: Number(process.env.SMTP_PORT || 587),
  smtpUser: process.env.SMTP_USER || '',
  smtpPass: process.env.SMTP_PASS || '',
  mailFrom: process.env.MAIL_FROM || 'angoothaPe <noreply@angoothape.local>',
};
