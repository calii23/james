import { networkInterfaces } from 'os';
import { writeFileSync } from 'fs';
import { registerNewDevice } from '../packet/security';
import { config } from '../config';
import { checkWritable, ensureParentDirectoryExists } from '../utils/utils';
import prompts = require('prompts');

export function registerDevice(): void {
  const interfaces = networkInterfaces();
  prompts([
    {
      type: 'text',
      name: 'ssid',
      message: 'What is the SSID of the WiFi the device should connect to?',
      validate: ssid => !ssid ? 'Please enter a SSID!' : true
    },
    {
      type: 'password',
      name: 'password',
      message: 'What is the password of the WiFi?',
      validate: password => password.length < 8 ? 'A WiFi password must be at least 8 characters long!' : true
    },
    {
      type: 'autocomplete',
      name: 'host',
      message: 'To which IP address should the device transmit the events?',
      choices: [
        ...Object.keys(interfaces)
          .map(name => interfaces[name])
          .flatMap(e => e)
          .filter(e => e.family === 'IPv4' && e.address !== '127.0.0.1')
          .map(e => ({ title: e.address, value: e.address })),
        {
          title: 'Custom',
          value: 'custom'
        }
      ]
    },
    {
      type: prev => prev === 'custom' ? 'text' : null,
      name: 'host',
      message: 'To which IP address should the device transmit the events?',
      validate: host => !host ? 'Please enter a host!' : true
    },
    {
      type: 'text',
      name: 'output',
      message: 'Where do you want to save the configuration file?',
      initial: 'config.bin',
      validate: output => !checkWritable(output) ? 'File is not writable!' : true
    }
  ])
    .then(({ ssid, password, host, output }: { ssid: string, password: string, host: string, output: string }) => {
      const device = registerNewDevice();

      let offset = 0;
      const buffer = Buffer.alloc(ssid.length + password.length + host.length + 42);

      offset = buffer.writeUInt16BE(ssid.length, offset);
      offset += buffer.write(ssid, offset);

      offset = buffer.writeUInt16BE(password.length, offset);
      offset += buffer.write(password, offset);

      offset = buffer.writeUInt16BE(host.length, offset);
      offset += buffer.write(host, offset);

      offset = buffer.writeUInt16BE(config.port, offset);

      offset = buffer.writeUInt16BE(device.deviceId, offset);

      device.secret.copy(buffer, offset);

      ensureParentDirectoryExists(output);
      writeFileSync(output, buffer);
    });
}
