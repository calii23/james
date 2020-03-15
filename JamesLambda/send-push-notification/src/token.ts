import SecretsManager from 'aws-sdk/clients/secretsmanager';
import {decode, sign} from 'jsonwebtoken';

const SecretId = process.env.APN_CREDENTIAL_SECRET_ID!;

interface ApnCredentialsSecret {
  /**
   * base64 encoded p8 file
   */
  privateKey: string;
  keyId: string;
  teamId: string;
  token: string;
}

interface ApnTokenPayload {
  iss: string;
  iat: number;
}

function currentJwtTime(): number {
  return Math.floor(Date.now() / 1000);
}

function generateToken({privateKey, keyId, teamId}: ApnCredentialsSecret): string {
  const decodedPrivateKey = Buffer.from(privateKey, 'base64').toString();
  const tokenPayload: ApnTokenPayload = {
    iss: teamId,
    iat: currentJwtTime()
  };
  return sign(JSON.stringify(tokenPayload), decodedPrivateKey, {algorithm: 'ES256', keyid: keyId});
}

async function updateToken(credentials: ApnCredentialsSecret, manager: SecretsManager): Promise<string> {
  const token = generateToken(credentials);
  const newCredentials = {
    ...credentials,
    token
  };
  await manager.updateSecret({
    SecretId,
    SecretString: JSON.stringify(newCredentials)
  }).promise();
  return token;
}

export async function getToken(): Promise<string> {
  const manager = new SecretsManager();
  const secretResult = await manager.getSecretValue({SecretId}).promise();

  const credentials = JSON.parse(secretResult.SecretString!) as ApnCredentialsSecret;
  const {token} = credentials;

  if (token) {
    const tokenPayload = decode(token) as ApnTokenPayload;
    const age = currentJwtTime() - tokenPayload.iat;
    // if older than one hour
    if (age > 60 * 60) {
      return await updateToken(credentials, manager);
    }
    return token;
  }

  return await updateToken(credentials, manager);
}
