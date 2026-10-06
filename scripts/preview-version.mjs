import { readFile } from 'node:fs/promises';
import { resolve } from 'node:path';
import { fileURLToPath } from 'node:url';

export function previewVersion(value) {
  const match = /^(0|[1-9]\d*)\.(0|[1-9]\d*)\.(0|[1-9]\d*)-preview\.([1-9]\d*)$/.exec(value);
  if (!match) throw new Error('Expected MAJOR.MINOR.PATCH-preview.N without leading zeroes');
  if (match.slice(1).some((part) => !Number.isSafeInteger(Number(part))))
    throw new Error('Version component exceeds safe integer range');
  return { version: value, tag: `v${value}`, bundleVersion: match.slice(1, 4).join('.'), build: match[4] };
}

export async function currentPreviewVersion() {
  return previewVersion((await readFile(new URL('../VERSION', import.meta.url), 'utf8')).trim());
}

if (process.argv[1] && resolve(process.argv[1]) === fileURLToPath(import.meta.url)) {
  const result = await currentPreviewVersion();
  const tag = process.argv[2];
  if (tag && tag !== result.tag) throw new Error('Tag does not match VERSION');
  console.log(JSON.stringify(result));
}
