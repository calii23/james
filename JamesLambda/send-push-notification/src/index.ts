export {sendPushNotification} from './apn';

export function validateDeviceToken(deviceToken: string) {
  return /^[0-9a-f]{64}$/.test(deviceToken);
}
