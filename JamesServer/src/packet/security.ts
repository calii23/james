import { closeSync, existsSync, openSync, readFileSync, writeSync } from 'fs';
import { createHmac, randomBytes } from 'crypto';
import { config } from '../config';

interface Device {
  counter: number;
  secret: Buffer; // length 32 bytes
}

export interface RegisteredDevice extends Device {
  deviceId: number;
}

// the device id is the index in the array
const devices: Device[] = [];
let writeFd: number;

export function loadDevices() {
  if (existsSync(config.devicesDatabase)) {
    const data = readFileSync(config.devicesDatabase);
    let offset = 0;
    while (data.length > offset) {
      const counter = data.readUInt32BE(offset);
      const secret = data.slice(offset + 4, offset + 36);
      devices.push({
        counter,
        secret
      });
      offset += 36;
    }
  }

  writeFd = openSync(config.devicesDatabase, 'a');
  process.on('beforeExit', () => closeSync(writeFd));
}

export function verifyPacketSignature(deviceId: number, counter: number, message: Buffer, signature: Buffer): boolean {
  if (deviceId >= devices.length)
    return false;
  const device = devices[deviceId];
  if (device.counter > counter)
    return false;

  const hmac = createHmac('SHA256', device.secret);
  hmac.update(message);
  const calculatedSignature = hmac.digest();

  if (signature.compare(calculatedSignature) !== 0)
    return false;

  device.counter = counter + 1;
  const counterData = Buffer.alloc(4);
  counterData.writeUInt32BE(device.counter);
  writeSync(writeFd, counterData, deviceId * 36);

  return true;
}

export function registerNewDevice(): RegisteredDevice {
  const device: RegisteredDevice = {
    deviceId: devices.length,
    counter: 0,
    secret: randomBytes(32)
  };
  devices.push(device);

  const data = Buffer.alloc(36);
  device.secret.copy(data, 4);
  writeSync(writeFd, data, device.deviceId * 36);

  return device;
}
