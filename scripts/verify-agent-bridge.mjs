import assert from 'node:assert/strict';
import { spawnSync } from 'node:child_process';
import { mkdtemp, readFile, rm, writeFile } from 'node:fs/promises';
import { tmpdir } from 'node:os';
import { join, resolve } from 'node:path';
import { performance } from 'node:perf_hooks';

const executable = resolve(process.argv[2] ?? 'out/Still-preview.app/Contents/MacOS/StillAgentBridge');
const directory = await mkdtemp(join(tmpdir(), 'still-hook-probe-'));
const timings = [];
try {
  await writeFile(join(directory, 'activity-salt'), 'test-only-salt', { mode: 0o600 });
  const event = (name) => ({
    session_id: 'PRIVATE-session',
    hook_event_name: name,
    prompt: 'PRIVATE-prompt',
    tool_input: { command: 'PRIVATE-command' },
    transcript_path: 'PRIVATE-path',
  });
  const invoke = (name, provider = 'codex', agentID) => {
    const start = performance.now();
    const result = spawnSync(executable, [provider, '--test-directory', directory], {
      input: JSON.stringify({ ...event(name), ...(agentID ? { agent_id: agentID } : {}) }),
      encoding: 'utf8',
      timeout: 1500,
    });
    timings.push(performance.now() - start);
    assert.equal(result.status, 0);
    assert.equal(result.stderr, '');
    return result;
  };
  invoke('PermissionRequest');
  await assert.rejects(readFile(join(directory, 'activity/codex.json')), { code: 'ENOENT' });
  await writeFile(join(directory, 'activity-codex-enabled'), 'enabled', { mode: 0o600 });
  const read = async () => JSON.parse(await readFile(join(directory, 'activity/codex.json'), 'utf8'));
  assert.equal(invoke('PermissionRequest').stdout.trim(), '{}');
  assert.equal((await read()).records[0].state, 'attentionRequested');
  assert.ok(!JSON.stringify(await read()).includes('PRIVATE'));
  invoke('PostToolUse');
  assert.equal((await read()).records[0].state, 'working');
  invoke('Stop');
  assert.equal((await read()).records[0].state, 'completed');
  invoke('SessionEnd');
  assert.deepEqual((await read()).records, []);
  invoke('PreToolUse', 'codex', 'PRIVATE-child-one');
  invoke('PreToolUse', 'codex', 'PRIVATE-child-two');
  assert.equal((await read()).records.length, 2);
  invoke('SessionEnd');
  assert.deepEqual((await read()).records, []);
  await writeFile(join(directory, 'activity-claude-enabled'), 'enabled', { mode: 0o600 });
  assert.equal(invoke('PostToolUseFailure', 'claude').stdout, '');
  const claude = JSON.parse(await readFile(join(directory, 'activity/claude.json'), 'utf8'));
  assert.equal(claude.records[0].state, 'failed');
  assert.ok(!JSON.stringify(claude).includes('PRIVATE'));
  for (let i = 0; i < 5; i++) invoke('PreToolUse');
  await rm(join(directory, 'activity-codex-enabled'));
  const previous = await readFile(join(directory, 'activity/codex.json'), 'utf8');
  invoke('PermissionRequest');
  assert.equal(await readFile(join(directory, 'activity/codex.json'), 'utf8'), previous);
  assert.ok(Math.max(...timings) < 1000);
  console.log(
    JSON.stringify(
      {
        kind: 'native-agent-helper-contract',
        checks: {
          explicitEnablement: true,
          advisoryStateOnly: true,
          contentNotPersisted: true,
          progressSupersedesSignal: true,
          stopAndSessionEnd: true,
          sessionEndClearsChildAgents: true,
          claudeFailureAndSilentOutput: true,
          revocation: true,
          noDecisionOutput: true,
          underHookTimeout: true,
        },
        helperInvocations: timings.length,
        maxMilliseconds: Math.round(Math.max(...timings)),
        meanMilliseconds: Math.round(timings.reduce((a, b) => a + b, 0) / timings.length),
        boundary: 'Synthetic hook stdin; not live client trust, delivery or approval acceptance.',
      },
      null,
      2,
    ),
  );
} finally {
  await rm(directory, { recursive: true, force: true });
}
