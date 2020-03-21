import { readFileSync } from 'fs';

export interface Config {
  devicesDatabase: string;
  port: number;
  host: string;
  apn: {
    topic: string;
    production: boolean;
    teamId: string;
    keyId: string;
    key: string;
  }
}

export let config!: Config;

export function loadConfig(file: string): void {
  try {
    config = JSON.parse(readFileSync(file).toString());
  } catch (e) {
    console.error(`${file}: ${e.message}`);
    process.exit(-1);
  }
}
