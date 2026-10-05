#!/usr/bin/env node
import { spawn } from 'node:child_process';
import { mkdir, rm } from 'node:fs/promises';
import { join, resolve } from 'node:path';
import { setTimeout as delay } from 'node:timers/promises';
import { parseArgs } from 'node:util';
import { atomicJSON, defaultRoot, regularJSON, safeDirectory } from './registry.mjs';

export async function publishTask(root, connectionID, label, state, startedAt) {
  await safeDirectory(root);
  const lock = join(root, '.producer-lock');
  let acquired = false;
  for (let attempt = 0; attempt < 20; attempt++) {
    try {
      await mkdir(lock, { mode: 0o700 });
      acquired = true;
      break;
    } catch (error) {
      if (error.code !== 'EEXIST') throw error;
      await delay(25);
    }
  }
  if (!acquired) throw new Error('Task Watch producer is busy; retry after checking its lock');
  try {
    const connection = await regularJSON(join(root, 'connection.json'));
    if (connection.protocolVersion !== 2 || connection.connectionID !== connectionID) return false;
    let previous;
    try {
      previous = await regularJSON(join(root, 'snapshot.json'));
    } catch (error) {
      if (error.code !== 'ENOENT') throw error;
    }
    const now = new Date(),
      old =
        previous?.connectionID === connectionID && Date.parse(previous.expiresAt) > now.getTime() ? previous.tasks : [];
    if (!Array.isArray(old)) throw new Error('Invalid task snapshot');
    const rows = old.filter(
      (row) => row.label !== label && Date.parse(row.expiresAt ?? previous.expiresAt) > now.getTime(),
    );
    if (rows.length >= 4) throw new Error('Task Watch supports four concurrent task labels');
    if (
      state === 'working' &&
      old.some((row) => row.label === label && row.state === 'working' && row.startedAt !== startedAt)
    )
      throw new Error('This task label is already running; choose another');
    const expiresAt = new Date(now.getTime() + (state === 'working' ? 120000 : 30000))
      .toISOString()
      .replace(/\.\d{3}Z$/, 'Z');
    rows.push({ label, state, startedAt, expiresAt });
    const revision = previous?.connectionID === connectionID ? previous.revision + 1 : 1;
    if (!Number.isSafeInteger(revision)) throw new Error('Task revision exhausted; reconnect Task Watch');
    await atomicJSON(join(root, 'snapshot.json'), {
      protocolVersion: 2,
      connectionID,
      revision,
      observedAt: now.toISOString().replace(/\.\d{3}Z$/, 'Z'),
      expiresAt: new Date(Math.max(...rows.map((row) => Date.parse(row.expiresAt ?? previous.expiresAt))))
        .toISOString()
        .replace(/\.\d{3}Z$/, 'Z'),
      tasks: rows,
    });
    return true;
  } finally {
    await rm(lock, { recursive: true });
  }
}

export async function runTask(argv) {
  const separator = argv.indexOf('--');
  if (separator < 0) throw new Error('Usage: still-task run --label Build -- <command> [arguments...]');
  const { values, positionals } = parseArgs({
    args: argv.slice(0, separator),
    allowPositionals: true,
    options: { label: { type: 'string' }, root: { type: 'string' } },
  });
  const label = values.label;
  if (
    positionals[0] !== 'run' ||
    !label ||
    label.length > 64 ||
    /[\p{Cc}\u202a-\u202e\u2066-\u2069]/u.test(label) ||
    !label.trim()
  )
    throw new Error('Choose a plain task label of 1–64 characters');
  const [command, ...arguments_] = argv.slice(separator + 1);
  if (!command) throw new Error('A command is required');
  const root = resolve(values.root ?? join(defaultRoot, 'task-watch'));
  const { connectionID } = await regularJSON(join(root, 'connection.json'));
  if (!/^[0-9a-f-]{36}$/i.test(connectionID)) throw new Error('Start Still and enable Task Watch first');
  const startedAt = new Date().toISOString().replace(/\.\d{3}Z$/, 'Z');
  if (!(await publishTask(root, connectionID, label, 'working', startedAt)))
    throw new Error('Task connection was revoked');
  // Deliberately inherit stdout/stderr: no command output is captured or sent to Still.
  const child = spawn(command, arguments_, { stdio: 'inherit', shell: false });
  const heartbeat = setInterval(() => {
    publishTask(root, connectionID, label, 'working', startedAt).catch(() => {});
  }, 45000);
  const forward = (signal) => child.kill(signal);
  const onInterrupt = () => forward('SIGINT'),
    onTerminate = () => forward('SIGTERM');
  process.on('SIGINT', onInterrupt);
  process.on('SIGTERM', onTerminate);
  const outcome = await new Promise((resolve_) => {
    child.once('error', () => resolve_({ code: 1, signal: null }));
    child.once('exit', (code, signal) => resolve_({ code, signal }));
  });
  clearInterval(heartbeat);
  process.off('SIGINT', onInterrupt);
  process.off('SIGTERM', onTerminate);
  await publishTask(
    root,
    connectionID,
    label,
    outcome.signal ? 'canceled' : outcome.code === 0 ? 'completed' : 'failed',
    startedAt,
  ).catch(() => {});
  return outcome.code ?? 1;
}
if (process.argv[1] && import.meta.url === new URL(`file://${resolve(process.argv[1])}`).href) {
  try {
    process.exitCode = await runTask(process.argv.slice(2));
  } catch (error) {
    console.error(error.message);
    process.exitCode = 1;
  }
}
