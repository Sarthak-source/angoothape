import { generateSecret, generateSync, generateURI, verifySync } from 'otplib';
import QRCode from 'qrcode';

const ISSUER = 'angoothaPe';

export function newTotpSecret() {
  return generateSecret();
}

export function totpUri(account, secret) {
  return generateURI({ secret, issuer: ISSUER, label: account });
}

export async function totpQrDataUrl(account, secret) {
  return QRCode.toDataURL(totpUri(account, secret), {
    margin: 1,
    width: 220,
    errorCorrectionLevel: 'M',
  });
}

export function totpOk(token, secret) {
  if (!secret || !/^\d{6}$/.test(String(token || ''))) return false;
  try {
    const result = verifySync({
      secret,
      token: String(token).trim(),
      epochTolerance: 90,
    });
    return Boolean(result?.valid);
  } catch {
    return false;
  }
}

export function totpNow(secret) {
  if (!secret) return null;
  return generateSync({ secret });
}
