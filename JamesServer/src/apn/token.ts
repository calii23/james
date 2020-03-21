import { sign } from 'jsonwebtoken';
import { config } from '../config';
import { readFileSync } from 'fs';

let token: string | null = null;
let tokenExpire = 0;

let privateKey: Buffer | null = null;

interface ApnTokenPayload {
  iss: string;
  iat: number;
}

function currentJwtTime(): number {
  return Math.floor(Date.now() / 1000);
}

function generateToken(): string {
  if (!privateKey) {
    privateKey = readFileSync(config.apn.key);
  }

  const tokenPayload: ApnTokenPayload = {
    iss: config.apn.teamId,
    iat: currentJwtTime()
  };
  return sign(JSON.stringify(tokenPayload), privateKey, { algorithm: 'ES256', keyid: config.apn.keyId });
}

export function getToken(): string {
  if (!token || tokenExpire < Date.now() + 2000) {
    token = generateToken();
    tokenExpire = Date.now() + 3600000;
  }

  return token;
}
