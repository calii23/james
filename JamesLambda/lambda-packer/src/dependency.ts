import {readFileSync} from 'fs';
import glob from 'glob';

interface Dependency {
  version: string;
  dev?: true;
  requires?: Record<string, string>;
  dependencies?: Record<string, Dependency>;
}

interface PackageLock {
  dependencies: Record<string, Dependency>;
}

function expandDependency(name: string, dependency: Dependency, base: string, follow?: Record<string, Dependency>): string[] {
  if (dependency.dev) return [];
  if (dependency.requires) {
    if (dependency.dependencies || follow) {
      let depBase: string;
      if (dependency.dependencies) {
        follow = dependency.dependencies;
        depBase = base + name + '/node_modules/';
      } else {
        depBase = base;
      }
      return [
        base + name,
        ...(Object.keys(dependency.requires).flatMap(dep => expandDependency(dep, follow![dep], depBase, follow)))
      ];
    }
  }
  return [base + name];
}

function expandDirectory(path: string): string[] {
  let npmIgnore: string[];
  try {
    npmIgnore = readFileSync(path + '/.npmignore')
      .toString()
      .split('\n')
      .map(e => e.trim())
      .filter(e => !!e);
  } catch (e) {
    npmIgnore = [];
  }
  const ignore = [...npmIgnore, ...npmIgnore.map(e => e + '/**'), '**/*.d.ts', '**/*.md', 'LICENSE'];
  return glob.sync('**', {ignore, cwd: path, nodir: true})
    .map(e => path + '/' + e);
}

export function getDependencies(): string[] {
  const packageLock = JSON.parse(readFileSync('package-lock.json').toString()) as PackageLock;

  const dependencies = Object.keys(packageLock.dependencies);

  return dependencies
    .flatMap(dep => expandDependency(dep, packageLock.dependencies[dep], 'node_modules/'))
    .flatMap(expandDirectory);
}
