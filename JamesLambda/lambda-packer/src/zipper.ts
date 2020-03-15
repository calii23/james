import {createWriteStream, readFileSync} from 'fs';
import archiver from 'archiver';

export function zipFiles(files: string[], output: string): void {
  const outputStream = createWriteStream(output);
  const archive = archiver('zip');
  archive.pipe(outputStream);

  files.forEach(file => archive.append(readFileSync(file), {name: file}));
  archive.append('exports.handler=require(\'./dist\').handler;', {name: 'index.js'});

  archive.finalize();
}
