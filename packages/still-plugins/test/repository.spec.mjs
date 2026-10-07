import assert from 'node:assert/strict';
import { execFileSync } from 'node:child_process';
import { mkdir, mkdtemp, readFile, rm, symlink, writeFile } from 'node:fs/promises';
import { tmpdir } from 'node:os';
import { join } from 'node:path';
import { test } from 'node:test';
import { fileURLToPath } from 'node:url';
import {
  gitArguments,
  gitEnvironment,
  inspectRepository,
  materialize,
  repositoryRef,
  repositoryURL,
  run,
} from '../src/repository.mjs';

test('HTTPS locators and references reject credentials, transport helpers and option/ref injection', () => {
  assert.equal(repositoryURL('https://example.org/team/plugins.git'), 'https://example.org/team/plugins.git');
  for (const value of [
    'http://example.org/repo',
    'ssh://host/repo',
    'https://user:secret@host/repo',
    'https://host/repo?token=secret',
    'https://host/repo#branch',
    'ext::evil',
    'https://host/',
  ]) {
    assert.throws(() => repositoryURL(value), { code: 'invalidRepositoryURL' });
  }
  for (const ref of ['--upload-pack=evil', 'HEAD:other', '../escape', 'main..branch', 'foo.lock', 'branch//name']) {
    assert.throws(() => repositoryRef(ref), { code: 'invalidRepositoryRef' });
  }
  assert.equal(repositoryRef('refs/tags/v1.0.0'), 'refs/tags/v1.0.0');
  assert.equal(repositoryRef(), 'HEAD');
});
test('Git isolation omits inherited credentials/config and disallows redirects/alternate transports', () => {
  const env = gitEnvironment('/isolated');
  assert.equal(env.HOME, '/isolated');
  assert.equal(env.GIT_CONFIG_GLOBAL, '/dev/null');
  assert.equal(env.GIT_TERMINAL_PROMPT, '0');
  assert.equal(env.GIT_CONFIG_COUNT, undefined);
  assert.equal(env.SSH_AUTH_SOCK, undefined);
  const args = gitArguments('/isolated', ['fetch']);
  for (const value of [
    'credential.helper=',
    'protocol.allow=never',
    'protocol.https.allow=always',
    'http.followRedirects=false',
    'http.sslVerify=true',
  ])
    assert.ok(args.includes(value));
});
test('child processes stop on timeout and output limits without leaking stderr', async () => {
  await assert.rejects(run(process.execPath, ['-e', 'setInterval(()=>{},1000)'], { timeout: 100 }), {
    code: 'timeout',
  });
  await assert.rejects(run(process.execPath, ['-e', 'process.stdout.write("x".repeat(2048))'], { limit: 1024 }), {
    code: 'outputLimit',
  });
  const result = await run(process.execPath, [
    '-e',
    'process.stderr.write("private"); process.stdout.write("{}"); process.exitCode=1',
  ]);
  assert.equal(result.code, 1);
  assert.equal(result.stdout.toString(), '{}');
});
async function fixture(body) {
  const root = await mkdtemp(join(tmpdir(), 'still-git-test-'));
  const repo = join(root, 'repo'),
    destination = join(root, 'tree');
  await mkdir(repo);
  await mkdir(destination);
  const git = (args) =>
    execFileSync('git', ['-C', repo, ...args], {
      env: {
        ...gitEnvironment(root),
        GIT_AUTHOR_NAME: 'Fixture',
        GIT_AUTHOR_EMAIL: 'fixture@example.invalid',
        GIT_COMMITTER_NAME: 'Fixture',
        GIT_COMMITTER_EMAIL: 'fixture@example.invalid',
      },
    });
  git(['init', '--template=', '--quiet']);
  try {
    await body({
      root,
      repo,
      destination,
      git,
      commit: () => {
        git(['add', '.']);
        git(['commit', '--quiet', '-m', 'Fixture']);
        return git(['rev-parse', 'HEAD']).toString().trim();
      },
    });
  } finally {
    await rm(root, { recursive: true, force: true });
  }
}
test('immutable object projection includes only selected packages and preserves the original commit after edits', async () => {
  await fixture(async ({ repo, destination, git, commit }) => {
    await mkdir(join(repo, 'custom/A.stillplugin'), { recursive: true });
    await writeFile(
      join(repo, 'still.plugins.json'),
      JSON.stringify({ schemaVersion: 1, packages: ['custom/A.stillplugin'] }),
    );
    await writeFile(join(repo, 'custom/A.stillplugin/manifest.json'), '{"original":true}');
    await writeFile(join(repo, 'unrelated.txt'), 'unrelated private-looking content');
    const pinned = commit();
    await writeFile(join(repo, 'custom/A.stillplugin/manifest.json'), '{"changed":true}');
    await materialize(async (args) => git(args), pinned, destination);
    assert.equal(await readFile(join(destination, 'custom/A.stillplugin/manifest.json'), 'utf8'), '{"original":true}');
    await assert.rejects(readFile(join(destination, 'unrelated.txt')));
  });
});
test('Git object projection rejects package symlinks, executable modes and index traversal', async () => {
  for (const kind of ['symlink', 'executable', 'traversal'])
    await fixture(async ({ repo, destination, git, commit }) => {
      await mkdir(join(repo, 'A.stillplugin'));
      const path = join(repo, 'A.stillplugin/manifest.json');
      if (kind === 'symlink') await symlink('../secret', path);
      else await writeFile(path, '{}', { mode: kind === 'executable' ? 0o755 : 0o600 });
      await writeFile(
        join(repo, 'still.plugins.json'),
        JSON.stringify({ schemaVersion: 1, packages: [kind === 'traversal' ? '../A.stillplugin' : 'A.stillplugin'] }),
      );
      const pinned = commit();
      await assert.rejects(
        materialize(async (args) => git(args), pinned, destination),
        { code: 'unsafeTree' },
      );
    });
});
test('local inspection delegates to native validation without resolving a network ref', async () => {
  let observed;
  const result = await inspectRepository('examples/plugins', {
    inspector: async (path) => {
      observed = path;
      return { code: 0, report: { compatible: true, actionsTaken: [] } };
    },
  });
  assert.match(observed, /examples\/plugins$/);
  assert.deepEqual(result.report.actionsTaken, []);
  await assert.rejects(inspectRepository('examples/plugins', { ref: 'main' }), { code: 'refRequiresHTTPS' });
});

test('subdirectory and single-package selection project the same immutable commit', async () => {
  await fixture(async ({ repo, destination, git, commit, root }) => {
    await mkdir(join(repo, 'examples/A.stillplugin'), { recursive: true });
    await writeFile(join(repo, 'examples/A.stillplugin/manifest.json'), '{}');
    const pinned = commit();
    await materialize(async (args) => git(args), pinned, destination, 'examples');
    assert.equal(await readFile(join(destination, 'A.stillplugin/manifest.json'), 'utf8'), '{}');
    const single = join(root, 'single.stillplugin');
    await mkdir(single);
    await materialize(async (args) => git(args), pinned, single, 'examples/A.stillplugin');
    assert.equal(await readFile(join(single, 'manifest.json'), 'utf8'), '{}');
    await assert.rejects(
      materialize(async (args) => git(args), pinned, single, '../escape'),
      { code: 'unsafeTree' },
    );
  });
});
test('Git projection rejects oversized blobs and never follows package submodules', async () => {
  await fixture(async ({ repo, destination, git, commit }) => {
    await mkdir(join(repo, 'A.stillplugin'));
    await writeFile(join(repo, 'A.stillplugin/manifest.json'), 'x'.repeat(32769));
    const pinned = commit();
    await assert.rejects(
      materialize(async (args) => git(args), pinned, destination),
      { code: 'packageSizeLimit' },
    );
    await writeFile(join(repo, 'A.stillplugin/manifest.json'), '{}');
    git(['add', '.']);
    git(['update-index', '--add', '--cacheinfo', `160000,${pinned},A.stillplugin/nested`]);
    git(['commit', '--quiet', '-m', 'Submodule fixture']);
    const submoduleCommit = git(['rev-parse', 'HEAD']).toString().trim();
    await assert.rejects(
      materialize(async (args) => git(args), submoduleCommit, destination),
      { code: 'unsafeTree' },
    );
  });
});
test('CLI structured failures remain parseable and omit auth-bearing input', async () => {
  const result = await run(process.execPath, [
    fileURLToPath(new URL('../src/cli.mjs', import.meta.url)),
    'inspect',
    'https://user:secret@example.invalid/repo',
    '--json',
  ]);
  assert.equal(result.code, 1);
  const report = JSON.parse(result.stdout);
  assert.equal(report.compatible, false);
  assert.equal(report.error, 'invalidRepositoryURL');
  assert.deepEqual(report.actionsTaken, []);
  assert.equal(result.stdout.toString().includes('secret'), false);
});
