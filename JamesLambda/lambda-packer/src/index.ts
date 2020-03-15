import {getDependencies} from './dependency';
import glob from 'glob';
import {zipFiles} from './zipper';

export function run() {
  const dependencies = getDependencies();
  const files = [
    ...dependencies,
    ...glob.sync('dist/**/*.js', {nodir: true})
  ];
  zipFiles(files, 'lambda.zip');
}
