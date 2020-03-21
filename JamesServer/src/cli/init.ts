import { writeFileSync } from 'fs';
import { resolve } from 'path';
import { checkWritable } from '../utils/utils';
import { Config } from '../config';
import prompts = require('prompts');

export function initConfig(configPath: string): void {
  if (!checkWritable(configPath)) {
    console.error(`${configPath}: file is not writable`);
    process.exit(-1);
  }

  prompts([
    {
      type: 'text',
      name: 'devicesDatabase',
      message: 'Where to store the device list?',
      initial: '/etc/james/devices.db',
      validate: devicesDatabase => !checkWritable(devicesDatabase) ? 'File is not writable!' : true
    },
    {
      type: 'number',
      name: 'port',
      min: 0x0,
      max: 0xffff,
      message: 'On which port should the server listen?',
      initial: 3294
    },
    {
      type: 'text',
      name: 'host',
      message: 'On which host should the server bind?',
      initial: '0.0.0.0'
    },
    {
      type: 'text',
      name: 'apnTopic',
      message: 'What\'s the bundle identifier of the app?',
      initial: 'de.schelbach.maximilian.JamesApp'
    },
    {
      type: 'confirm',
      name: 'apnProduction',
      message: 'Is your app in production?'
    },
    {
      type: 'text',
      name: 'apnTeamId',
      message: 'What\'s your team ID (look in the apple developer console)? ',
      validate: apnTeamId => apnTeamId.length === 10
    },
    {
      type: 'text',
      name: 'apnKeyId',
      message: 'What\'s the key ID of the APN key?',
      validate: apnKeyId => apnKeyId.length === 10
    },
    {
      type: 'text',
      name: 'apnKey',
      message: 'Where is your APN key located?',
      initial: '/etc/james/AuthKey.p8',
      validate: apnKey => !!apnKey
    }
  ])
    .then(answers => {
      if (!answers.apnKey)
        return;

      const config: Config = {
        devicesDatabase: resolve(answers.devicesDatabase),
        port: answers.port,
        host: answers.host,
        apn: {
          topic: answers.apnTopic,
          production: answers.apnProduction,
          teamId: answers.apnTeamId,
          keyId: answers.apnKeyId,
          key: resolve(answers.apnKey)
        }
      };

      writeFileSync(configPath, JSON.stringify(config));
    });
}
