import { accessSync, constants, existsSync, mkdirSync } from 'fs';
import { dirname, resolve } from 'path';

export function checkWritable(path: string): boolean {
  if (existsSync(path)) {
    try {
      accessSync(path, constants.W_OK);
      return true;
    } catch (e) {
      return false;
    }
  }

  const fullPath = resolve(path);
  let currentDirectory = dirname(fullPath);
  while (true) {
    try {
      accessSync(currentDirectory, constants.W_OK);
      return true;
    } catch (e) {
    }

    const parent = dirname(currentDirectory);
    if (parent === currentDirectory)
      return false;
    currentDirectory = parent;
  }
}

export function ensureParentDirectoryExists(path: string): void {
  ensureDirectoryExists(dirname(resolve(path)));
}

function ensureDirectoryExists(path: string): void {
  if (existsSync(path))
    return;

  ensureDirectoryExists(dirname(path));
  mkdirSync(path);
}
