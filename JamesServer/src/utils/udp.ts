import { createSocket } from 'dgram';

export function startUdpServer(port: number, address: string, callback: (packet: Buffer) => void): void {
  const socket = createSocket('udp4');
  socket.addListener('message', msg => callback(msg));
  socket.bind(port, address);
}
