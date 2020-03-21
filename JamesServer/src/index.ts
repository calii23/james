import { config, loadConfig } from './config';
import * as yargs from 'yargs';
import { loadDevices } from './packet/security';
import { startServer } from './server/server';
import { initConfig } from './cli/init';
import { registerDevice } from './cli/register';

const noConfig: (...args: any[]) => any = () => {
};

yargs
  .option('config', {
    alias: 'c',
    type: 'string',
    description: 'path to the config file',
    default: '/etc/james/config.json'
  })
  .command(['start', '$0'], 'starts the server', noConfig, args => {
    loadConfig(args.config);
    loadDevices();
    startServer();
  })
  .command('register', 'registers a new device and creates a config', noConfig, args => {
    loadConfig(args.config);
    loadDevices();
    registerDevice();
  })
  .command('init', 'creates a server', noConfig, args => initConfig(args.config))
  .argv;
