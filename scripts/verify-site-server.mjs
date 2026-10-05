#!/usr/bin/env node
import { join } from 'node:path';
import { delay, ownedProcess, root, stop } from './probe-support.mjs';

const base = 'http://127.0.0.1:3186';
const server = ownedProcess(process.execPath, [
  join(root, 'apps/website/node_modules/next/dist/bin/next'),
  'start',
  join(root, 'apps/website'),
  '--hostname',
  '127.0.0.1',
  '--port',
  '3186',
]);
try {
  const deadline = performance.now() + 30_000;
  let ready = false;
  while (performance.now() < deadline && server.running()) {
    try {
      ready = (await fetch(base, { signal: AbortSignal.timeout(1000) })).ok;
    } catch {}
    if (ready) break;
    await delay(200);
  }
  if (!ready) throw new Error('Owned website server did not become ready');
  const probe = ownedProcess(process.execPath, [join(root, 'scripts/verify-website.mjs'), base], 'inherit');
  try {
    const result = await probe.done;
    if (result.code !== 0) throw new Error('Website verification failed');
  } finally {
    await stop(probe);
  }
} finally {
  await stop(server);
}
