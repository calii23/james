import { verifyPacketSignature } from './security';

const MAGIC_NUMBER = 0x1A0E4DE7;
type PacketType = 0 | 1 | 2;

export interface Packet {
  type: PacketType;
  deviceTokens: string[];
  wifi: string;
}

export function parsePacket(data: Buffer): Packet | null {
  // when a packet is smaller than 74 bytes, it cannot be valid
  // because not all required fields can be given
  if (data.length < 76)
    return null;

  let offset = 0;

  // check the magic number
  if (data.readUInt32BE(offset) !== MAGIC_NUMBER)
    return null;

  offset += 4;

  const type = ((data.readUInt8(offset) & 0xC0) >> 6) as PacketType;
  const deviceId = data.readUInt16BE(offset) & 0xFFF;
  offset += 2;

  const wifiLength = data.readUInt16BE(offset);
  offset += 2;

  if (data.length < offset + wifiLength + 1)
    return null;

  const wifi = data.toString('utf8', offset, offset + wifiLength);
  offset += wifiLength;

  const counter = data.readUInt32BE(offset);
  offset += 4;

  let deviceTokenCount: number;
  if (type === 0) {
    deviceTokenCount = data.readUInt8(offset++);
    if (!deviceTokenCount)
      return null;
  } else {
    deviceTokenCount = 1;
  }

  // verify the length of the packet: read data + device tokens + signature
  if (data.length !== offset + (deviceTokenCount * 32) + 32)
    return null;

  const deviceTokens = new Array(deviceTokenCount).fill(undefined).map(() => {
    const token = readDeviceToken(data, offset);
    offset += 32;
    return token;
  });

  if (!verifyPacketSignature(deviceId, counter, data.slice(0, offset), data.slice(offset)))
    return null;

  return {
    type,
    deviceTokens,
    wifi
  };
}

function readDeviceToken(data: Buffer, offset: number): string {
  return data.toString('hex', offset, offset + 32);
}
