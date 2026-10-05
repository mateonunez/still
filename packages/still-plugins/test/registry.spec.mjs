import assert from 'node:assert/strict';
import { randomUUID } from 'node:crypto';
import { mkdir, mkdtemp, readFile, realpath, rm, symlink, writeFile } from 'node:fs/promises';
import { tmpdir } from 'node:os';
import { join } from 'node:path';
import { test } from 'node:test';
import { configureLocal, ids, install, regularJSON } from '../src/registry.mjs';
import { publishTask, runTask } from '../src/task.mjs';

test('ten plugins install without overriding user configuration; local preset is explicit', async () => {
  const root = await realpath(await mkdtemp(join(tmpdir(), 'still-plugins-')));
  try {
    await install(root);
    assert.equal(ids.length, 10);
    const path = join(root, 'world-clock/configuration.json'),
      value = await regularJSON(path);
    value.settings.clocks = [{ name: 'Home', timeZone: 'UTC' }];
    await writeFile(path, JSON.stringify(value));
    await install(root);
    assert.equal((await regularJSON(path)).settings.clocks[0].name, 'Home');
    await configureLocal(root, { projectId: 'prj_test', orgId: 'team_test' });
    assert.equal((await regularJSON(path)).settings.clocks.length, 3);
    const configs = await Promise.all(ids.map((id) => regularJSON(join(root, id, 'configuration.json'))));
    assert.equal(configs.filter((row) => row.enabled).length, 10);
    assert.equal(configs.filter((row) => row.visible).length, 4);
  } finally {
    await rm(root, { recursive: true });
  }
});
test('installer rejects unknown IDs and symbolic links', async () => {
  const parent = await realpath(await mkdtemp(join(tmpdir(), 'still-unsafe-')));
  try {
    await assert.rejects(install(parent, ['../escape']));
    const link = join(parent, 'link');
    await symlink(parent, link);
    await assert.rejects(install(link));
    await mkdir(join(parent, 'agents'));
    await symlink(join(parent, 'elsewhere'), join(parent, 'agents/configuration.json'));
    await assert.rejects(install(parent, ['agents']));
  } finally {
    await rm(parent, { recursive: true });
  }
});
test('task wrapper executes a real command, reports success/failure, and never persists stdout', async () => {
  const root = await realpath(await mkdtemp(join(tmpdir(), 'still-task-'))),
    connectionID = randomUUID().toUpperCase();
  try {
    await writeFile(join(root, 'connection.json'), JSON.stringify({ protocolVersion: 2, connectionID }));
    assert.equal(
      await runTask(['run', '--root', root, '--label', 'Success', '--', process.execPath, '-e', 'process.exit(0)']),
      0,
    );
    assert.equal((await regularJSON(join(root, 'snapshot.json'))).tasks[0].state, 'completed');
    assert.equal(
      await runTask(['run', '--root', root, '--label', 'Failure', '--', process.execPath, '-e', 'process.exit(7)']),
      7,
    );
    assert.equal(
      (await regularJSON(join(root, 'snapshot.json'))).tasks.find((row) => row.label === 'Failure').state,
      'failed',
    );
    assert.equal((await readFile(join(root, 'snapshot.json'), 'utf8')).includes('process.exit'), false);
    await writeFile(join(root, 'connection.json'), JSON.stringify({ protocolVersion: 2, connectionID: randomUUID() }));
    assert.equal(await publishTask(root, connectionID, 'Old', 'working', new Date().toISOString()), false);
  } finally {
    await rm(root, { recursive: true });
  }
});
test('concurrent producers retain separate task labels and monotonic revisions', async () => {
  const root = await realpath(await mkdtemp(join(tmpdir(), 'still-concurrent-'))),
    connectionID = randomUUID();
  try {
    await writeFile(join(root, 'connection.json'), JSON.stringify({ protocolVersion: 2, connectionID }));
    const start = new Date().toISOString();
    await Promise.all(['A', 'B', 'C', 'D'].map((label) => publishTask(root, connectionID, label, 'working', start)));
    const value = await regularJSON(join(root, 'snapshot.json'));
    assert.equal(value.tasks.length, 4);
    assert.equal(value.revision, 4);
    await assert.rejects(publishTask(root, connectionID, 'E', 'working', start));
    await publishTask(root, connectionID, 'A', 'completed', start);
    const mixed = await regularJSON(join(root, 'snapshot.json'));
    assert.ok(Date.parse(mixed.expiresAt) > Date.parse(mixed.tasks.find((row) => row.label === 'A').expiresAt));
    mixed.tasks.find((row) => row.label === 'A').expiresAt = new Date(Date.now() - 1000).toISOString();
    await writeFile(join(root, 'snapshot.json'), JSON.stringify(mixed));
    await publishTask(root, connectionID, 'B', 'working', start);
    assert.equal(
      (await regularJSON(join(root, 'snapshot.json'))).tasks.some((row) => row.label === 'A'),
      false,
    );
  } finally {
    await rm(root, { recursive: true });
  }
});
