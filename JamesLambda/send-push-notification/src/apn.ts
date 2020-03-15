import {getToken} from './token';
import {connect, constants} from 'http2';

const {HTTP2_HEADER_METHOD, HTTP2_METHOD_POST, HTTP2_HEADER_PATH, HTTP2_HEADER_AUTHORIZATION, HTTP2_HEADER_CONTENT_TYPE} = constants;

export async function sendPushNotification(deviceIds: string[], wifi: string, type: 0 | 1 | 2): Promise<void> {
  const token = await getToken();
  const client = connect(process.env.APN_SERVER!);
  const content = JSON.stringify({
    aps: {
      'content-available': 1
    },
    type,
    wifi
  });

  try {
    await Promise.all(deviceIds.map(deviceId =>
      new Promise<void>((resolve, reject) => {
        const request = client.request({
          [HTTP2_HEADER_METHOD]: HTTP2_METHOD_POST,
          [HTTP2_HEADER_PATH]: '/3/device/' + deviceId,
          [HTTP2_HEADER_CONTENT_TYPE]: 'application/json',
          [HTTP2_HEADER_AUTHORIZATION]: `bearer ${token}`,
          'apns-topic': process.env.APN_TOPIC,
          'apns-push-type': 'background'
        });
        request.setEncoding('utf8');
        request.write(content);
        request.end();

        request.on('error', reject);
        request.on('end', resolve);
      })));
  } finally {
    client.close();
  }
}
