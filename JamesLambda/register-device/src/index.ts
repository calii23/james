import {sendPushNotification, validateDeviceToken} from 'send-push-notification';

interface RegisterDeviceRequest {
  wifi: string;
  deviceIds: string[];
  alreadyRegistered: boolean;
}

export async function handler(event: { body: string }): Promise<{ statusCode: number; body: string }> {
  let request: any;
  try {
    request = JSON.parse(event.body);
  } catch (e) {
    return {statusCode: 400, body: 'Invalid JSON!'};
  }
  if (!isRequest(request)) return {statusCode: 400, body: 'Invalid request!'};
  try {
    await sendPushNotification(request.deviceIds, request.wifi, request.alreadyRegistered ? 2 : 1);
  } catch (e) {
    return {statusCode: 500, body: 'Could not send push notification!'};
  }

  return {statusCode: 200, body: 'OK'};
}

function isRequest(x: any): x is RegisterDeviceRequest {
  const keys = Object.keys(x);
  if (keys.length !== 3) return false;
  if (!keys.every(key => ['wifi', 'deviceIds', 'alreadyRegistered'].includes(key))) return false;

  return typeof x.wifi === 'string' && x.wifi.length && Array.isArray(x.deviceIds) && x.deviceIds.length &&
    x.deviceIds.every(validateDeviceToken) && typeof x.alreadyRegistered === 'boolean';
}
