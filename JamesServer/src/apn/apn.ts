import { getToken } from './token';
import { ClientHttp2Session, connect, constants } from 'http2';
import { config } from '../config';

const { HTTP2_HEADER_METHOD, HTTP2_METHOD_POST, HTTP2_HEADER_PATH, HTTP2_HEADER_AUTHORIZATION, HTTP2_HEADER_CONTENT_TYPE } = constants;

let client: ClientHttp2Session | null = null;

function ensureConnected(): void {
  if (!client || client.closed || client.destroyed) {
    client = connect(config.apn.production ? 'https://api.push.apple.com' : 'https://api.sandbox.push.apple.com');
  }
}

export function sendPushNotification(deviceIds: string[], wifi: string, type: 0 | 1 | 2): void {
  ensureConnected();
  const token = getToken();
  const content = JSON.stringify({
    aps: {
      'content-available': 1
    },
    type,
    wifi
  });

  deviceIds.forEach(deviceId => {
    const request = client!.request({
      [HTTP2_HEADER_METHOD]: HTTP2_METHOD_POST,
      [HTTP2_HEADER_PATH]: '/3/device/' + deviceId,
      [HTTP2_HEADER_CONTENT_TYPE]: 'application/json',
      [HTTP2_HEADER_AUTHORIZATION]: `bearer ${token}`,
      'apns-topic': config.apn.topic,
      'apns-push-type': 'background'
    });
    request.setEncoding('utf8');
    request.write(content);
    request.end();
  });
}
