import { spawn } from 'node:child_process';
import { mkdir, realpath, stat } from 'node:fs/promises';
import { relative, resolve, sep } from 'node:path';
import { setTimeout as delay } from 'node:timers/promises';
import { fileURLToPath } from 'node:url';

export const root = fileURLToPath(new URL('../', import.meta.url));
export { delay };

export async function outputDirectory(name) {
  const base = resolve(root, 'out');
  const destination = resolve(root, name);
  const inside = (parent, child) => {
    const suffix = relative(parent, child);
    return suffix !== '..' && !suffix.startsWith(`..${sep}`) && !suffix.startsWith(sep);
  };
  if (!inside(base, destination)) throw new Error('Probe output must stay inside out/');
  await mkdir(base, { recursive: true });
  let ancestor = destination;
  while (true) {
    try {
      await stat(ancestor);
      break;
    } catch (error) {
      if (error.code !== 'ENOENT') throw error;
      ancestor = resolve(ancestor, '..');
    }
  }
  if (!inside(await realpath(base), await realpath(ancestor)))
    throw new Error('Probe output escapes out/ through a symlink');
  await mkdir(destination, { recursive: true });
  return destination;
}

export async function waitForFile(path, timeout = 12_000) {
  const deadline = performance.now() + timeout;
  while (performance.now() < deadline) {
    try {
      await stat(path);
      return;
    } catch (error) {
      if (error.code !== 'ENOENT') throw error;
    }
    await delay(100);
  }
  throw new Error(`No receipt produced within ${timeout / 1000}s: ${path}`);
}

export function ownedProcess(command, args, stdio = 'ignore') {
  const child = spawn(command, args, { stdio });
  const done = new Promise((resolve) => {
    child.once('error', (error) => resolve({ error }));
    child.once('close', (code, signal) => resolve({ code, signal }));
  });
  return {
    child,
    done,
    running: () => child.exitCode === null && child.signalCode === null && child.pid !== undefined,
  };
}

export async function stop(process) {
  if (!process?.running()) return;
  process.child.kill('SIGTERM');
  let timer;
  const terminated = await Promise.race([
    process.done.then(() => true),
    new Promise((resolve) => {
      timer = setTimeout(() => resolve(false), 5000);
    }),
  ]);
  clearTimeout(timer);
  if (!terminated && process.running()) {
    process.child.kill('SIGKILL');
    await process.done;
  }
}

export async function commandOutput(command, args, timeout = 5000) {
  const process = ownedProcess(command, args, ['ignore', 'pipe', 'ignore']);
  const chunks = [];
  let bytes = 0;
  let excessive = false;
  process.child.stdout.on('data', (chunk) => {
    bytes += chunk.length;
    if (bytes > 2 * 1024 * 1024) {
      excessive = true;
      process.child.kill('SIGTERM');
    } else chunks.push(chunk);
  });
  let timedOut = false;
  const timer = setTimeout(() => {
    timedOut = true;
    process.child.kill('SIGTERM');
  }, timeout);
  try {
    const result = await Promise.race([process.done, delay(timeout + 1000, { timedOut: true }, { ref: false })]);
    if (timedOut || result.timedOut) throw new Error(`${command} timed out`);
    if (excessive) throw new Error(`${command} output exceeded limit`);
    if (result.error) throw result.error;
    if (result.code !== 0) throw new Error(`${command} exited ${result.code}`);
    return Buffer.concat(chunks).toString('utf8');
  } finally {
    clearTimeout(timer);
    await stop(process);
  }
}
