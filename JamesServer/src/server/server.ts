import { config } from '../config';
import { startUdpServer } from '../utils/udp';
import { parsePacket } from '../packet/packet';
import { sendPushNotification } from '../apn/apn';

export function startServer() {
  startUdpServer(config.port, config.host, packetData => {
    const packet = parsePacket(packetData);
    if (!packet)
      return;

    sendPushNotification(packet.deviceTokens, packet.wifi, packet.type);
  });
}
