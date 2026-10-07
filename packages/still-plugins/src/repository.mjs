import { spawn } from 'node:child_process';
import { mkdir, mkdtemp, readdir, rm, stat, writeFile } from 'node:fs/promises';
import { tmpdir } from 'node:os';
import { dirname, join, resolve } from 'node:path';
import { fileURLToPath } from 'node:url';

export class RepositoryError extends Error {
  constructor(code) {
    super(code);
    this.code = code;
  }
}
function hasControls(value) {
  return [...value].some((char) => char.codePointAt(0) < 32 || char.codePointAt(0) === 127);
}
export function repositoryURL(value) {
  let url;
  try {
    url = new URL(value);
  } catch {
    throw new RepositoryError('invalidRepositoryURL');
  }
  if (
    url.protocol !== 'https:' ||
    url.username ||
    url.password ||
    url.search ||
    url.hash ||
    !url.hostname ||
    !url.pathname ||
    url.pathname === '/' ||
    /[\s\\]/u.test(value) ||
    hasControls(value)
  ) {
    throw new RepositoryError('invalidRepositoryURL');
  }
  return url.href;
}
export function repositoryRef(value = 'HEAD') {
  if (
    value.length > 256 ||
    !/^[A-Za-z0-9][A-Za-z0-9._/-]*$/.test(value) ||
    value.includes('..') ||
    value.includes('//') ||
    value.endsWith('/') ||
    value.endsWith('.lock') ||
    value.split('/').some((part) => part.startsWith('.'))
  )
    throw new RepositoryError('invalidRepositoryRef');
  return value;
}

// Output and elapsed bounds apply to every child; fetched disk size is sampled, not a hard network quota.
export function run(command, args, { cwd, env, timeout = 30000, limit = 4 * 1024 * 1024, monitor } = {}) {
  return new Promise((resolveResult, reject) => {
    const child = spawn(command, args, {
      cwd,
      env,
      detached: process.platform !== 'win32',
      stdio: ['ignore', 'pipe', 'pipe'],
    });
    let size = 0,
      failure,
      polling = false,
      finished = false;
    const chunks = [];
    const stop = (code) => {
      if (failure || finished) return;
      failure = new RepositoryError(code);
      try {
        process.kill(process.platform === 'win32' ? child.pid : -child.pid, 'SIGKILL');
      } catch {
        child.kill('SIGKILL');
      }
    };
    child.stdout.on('data', (data) => {
      size += data.length;
      if (size > limit) stop('outputLimit');
      else chunks.push(data);
    });
    child.stderr.on('data', (data) => {
      size += data.length;
      if (size > limit) stop('outputLimit');
    });
    const timer = setTimeout(() => stop('timeout'), timeout);
    const interval = monitor
      ? setInterval(async () => {
          if (polling || failure) return;
          polling = true;
          try {
            await monitor();
          } catch {
            stop('repositorySizeLimit');
          } finally {
            polling = false;
          }
        }, 100)
      : undefined;
    child.on('error', () => {
      finished = true;
      clearTimeout(timer);
      clearInterval(interval);
      reject(new RepositoryError('toolUnavailable'));
    });
    child.on('close', (code) => {
      finished = true;
      clearTimeout(timer);
      clearInterval(interval);
      if (failure) reject(failure);
      else resolveResult({ code, stdout: Buffer.concat(chunks) });
    });
  });
}

export function gitEnvironment(root) {
  return {
    PATH: process.env.PATH,
    HOME: root,
    XDG_CONFIG_HOME: root,
    LANG: 'C',
    LC_ALL: 'C',
    GIT_CONFIG_NOSYSTEM: '1',
    GIT_CONFIG_GLOBAL: '/dev/null',
    GIT_TERMINAL_PROMPT: '0',
    GIT_ASKPASS: '/usr/bin/false',
    GIT_LFS_SKIP_SMUDGE: '1',
  };
}
export function gitArguments(root, args) {
  return [
    '-c',
    `core.hooksPath=${join(root, 'no-hooks')}`,
    '-c',
    'credential.helper=',
    '-c',
    'protocol.allow=never',
    '-c',
    'protocol.https.allow=always',
    '-c',
    'http.followRedirects=false',
    '-c',
    'http.sslVerify=true',
    '-c',
    'fetch.fsckObjects=true',
    '-c',
    'gc.auto=0',
    '-c',
    'maintenance.auto=false',
    ...args,
  ];
}
async function diskBound(root, limit = 64 * 1024 * 1024) {
  let bytes = 0,
    files = 0;
  async function walk(path) {
    for (const entry of await readdir(path, { withFileTypes: true })) {
      const child = join(path, entry.name);
      if (++files > 10000) throw new RepositoryError('repositorySizeLimit');
      if (entry.isDirectory()) await walk(child);
      else {
        try {
          bytes += (await stat(child)).size;
        } catch (error) {
          if (error.code !== 'ENOENT') throw error;
        }
        if (bytes > limit) throw new RepositoryError('repositorySizeLimit');
      }
    }
  }
  await walk(root);
}
function safePath(path, components = 8, bytes = 256) {
  const parts = path.split('/');
  if (
    Buffer.byteLength(path) > bytes ||
    parts.length > components ||
    parts.some((part) => !part || part === '.' || part === '..') ||
    path.includes('\\') ||
    hasControls(path)
  ) {
    throw new RepositoryError('unsafeTree');
  }
}

// Reads raw Git objects; no checkout, textconv, attributes, filters or executable payloads.
export async function materialize(git, commit, destination, basePath) {
  const raw = await git(['ls-tree', '-r', '-t', '-z', '--full-tree', commit]);
  let decoded;
  try {
    decoded = new TextDecoder('utf8', { fatal: true }).decode(raw);
  } catch {
    throw new RepositoryError('unsafeTree');
  }
  const rows = decoded.split('\0').filter(Boolean);
  if (rows.length > 10000) throw new RepositoryError('treeLimit');
  let entries = new Map(
    rows.map((row) => {
      const tab = row.indexOf('\t'),
        [mode, type, oid] = row.slice(0, tab).split(' ');
      if (tab < 0 || !/^[a-f0-9]{40,64}$/.test(oid)) throw new RepositoryError('unsafeTree');
      return [row.slice(tab + 1), { mode, type, oid }];
    }),
  );
  if (basePath !== undefined) {
    safePath(basePath);
    let ancestor = '';
    for (const part of basePath.split('/')) {
      ancestor = ancestor ? `${ancestor}/${part}` : part;
      if (entries.get(ancestor)?.type !== 'tree') throw new RepositoryError('unsafeTree');
    }
    entries = new Map(
      [...entries]
        .filter(([path]) => path.startsWith(`${basePath}/`))
        .map(([path, entry]) => [path.slice(basePath.length + 1), entry]),
    );
  }
  const blob = async (path, limit) => {
    const entry = entries.get(path);
    if (entry?.mode !== '100644' || entry.type !== 'blob') throw new RepositoryError('unsafeTree');
    const size = Number((await git(['cat-file', '-s', entry.oid])).toString('utf8').trim());
    if (!Number.isSafeInteger(size) || size < 0 || size > limit) throw new RepositoryError('packageSizeLimit');
    const content = await git(['cat-file', 'blob', entry.oid]);
    if (content.length !== size) throw new RepositoryError('unsafeTree');
    return content;
  };
  let packages;
  if (basePath?.endsWith('.stillplugin')) {
    packages = [''];
  } else if (entries.has('still.plugins.json')) {
    const data = await blob('still.plugins.json', 32768);
    let index;
    try {
      index = JSON.parse(data);
    } catch {
      throw new RepositoryError('invalidIndex');
    }
    if (
      !Array.isArray(index.packages) ||
      index.packages.length > 32 ||
      !index.packages.every((path) => typeof path === 'string')
    ) {
      throw new RepositoryError('invalidIndex');
    }
    packages = index.packages;
    for (const path of packages) {
      safePath(path);
      if (!path.endsWith('.stillplugin')) throw new RepositoryError('unsafeTree');
    }
    await writeFile(join(destination, 'still.plugins.json'), data, { mode: 0o600 });
  } else {
    const plugins = entries.get('plugins');
    if (plugins && plugins.type !== 'tree') throw new RepositoryError('unsafeTree');
    packages = [...entries]
      .filter(([path, entry]) => entry.type === 'tree' && /^(?:plugins\/)?[^/]+\.stillplugin$/.test(path))
      .map(([path]) => path);
    if (packages.length > 32) throw new RepositoryError('treeLimit');
  }
  let count = 0,
    total = 0;
  for (const path of new Set(packages)) {
    if (path) safePath(path);
    let ancestor = '';
    for (const part of path ? path.split('/') : []) {
      ancestor = ancestor ? `${ancestor}/${part}` : part;
      if (entries.has(ancestor) && entries.get(ancestor).type !== 'tree') throw new RepositoryError('unsafeTree');
    }
    const children = [...entries].filter(([name]) => !path || name.startsWith(`${path}/`));
    if (!children.length) continue; // Native discovery reports missing packages rather than creating empty compatible entries.
    for (const [name, entry] of children) {
      safePath(name, 9, 272);
      if (entry.type === 'tree') throw new RepositoryError('unsafeTree');
      if (++count > 96) throw new RepositoryError('treeLimit');
      const content = await blob(name, name.split('/').at(-1) === 'manifest.json' ? 32768 : 65536);
      total += content.length;
      if (total > 6 * 1024 * 1024) throw new RepositoryError('packageSizeLimit');
      const output = join(destination, name);
      await mkdir(dirname(output), { recursive: true, mode: 0o700 });
      await writeFile(output, content, { mode: 0o600, flag: 'wx' });
    }
  }
}

export async function nativeInspect(path) {
  const packagePath = fileURLToPath(new URL('../../StillPluginKit', import.meta.url));
  const result = await run(
    'swift',
    ['run', '--package-path', packagePath, 'still-plugin', 'inspect', resolve(path), '--json'],
    { timeout: 60000 },
  );
  let report;
  try {
    report = JSON.parse(result.stdout);
  } catch {
    throw new RepositoryError('validatorUnavailable');
  }
  if (![0, 1].includes(result.code)) throw new RepositoryError('validatorUnavailable');
  return { code: result.code, report: { compatible: false, ...report } };
}

export async function inspectRepository(source, { ref, path, inspector = nativeInspect } = {}) {
  if (path !== undefined) safePath(path);
  if (!source.includes('://')) {
    if (ref !== undefined) throw new RepositoryError('refRequiresHTTPS');
    return inspector(resolve(source, path ?? '.'));
  }
  const url = repositoryURL(source),
    requestedRef = repositoryRef(ref);
  const root = await mkdtemp(join(tmpdir(), 'still-repository-'));
  const repository = join(root, 'objects.git'),
    tree = join(root, path?.endsWith('.stillplugin') ? 'package.stillplugin' : 'tree');
  const deadline = Date.now() + 90000;
  try {
    await mkdir(tree, { mode: 0o700 });
    await mkdir(join(root, 'no-hooks'), { mode: 0o700 });
    const env = gitEnvironment(root);
    const git = async (args) => {
      const timeout = Math.min(30000, deadline - Date.now());
      if (timeout <= 0) throw new RepositoryError('timeout');
      const result = await run('git', gitArguments(root, args), { cwd: root, env, timeout });
      if (result.code !== 0) throw new RepositoryError('gitReadFailed');
      return result.stdout;
    };
    await git(['init', '--bare', '--template=', repository]);
    const fetch = await run(
      'git',
      gitArguments(root, [
        '--git-dir',
        repository,
        'fetch',
        '--depth=1',
        '--no-tags',
        '--no-recurse-submodules',
        '--no-write-fetch-head',
        url,
        `${requestedRef}:refs/still/inspected`,
      ]),
      { cwd: root, env, monitor: () => diskBound(repository) },
    );
    if (fetch.code !== 0) throw new RepositoryError('fetchFailed');
    await diskBound(repository);
    const objectGit = (args) => git(['--git-dir', repository, ...args]);
    const commit = (await objectGit(['rev-parse', '--verify', 'refs/still/inspected^{commit}']))
      .toString('utf8')
      .trim();
    if (!/^[a-f0-9]{40,64}$/.test(commit)) throw new RepositoryError('invalidCommit');
    await materialize(objectGit, commit, tree, path);
    const result = await inspector(tree);
    return {
      ...result,
      report: { ...result.report, source: { url, requestedRef, resolvedCommit: commit, packageRoot: path ?? '.' } },
    };
  } finally {
    await rm(root, { recursive: true, force: true });
  }
}
