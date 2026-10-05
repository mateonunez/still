import { lstat, mkdir, readFile, rename, writeFile } from 'node:fs/promises';
import { homedir } from 'node:os';
import { dirname, join } from 'node:path';
import { fileURLToPath } from 'node:url';

export const catalogRoot = fileURLToPath(new URL('../../../plugins/mateonunez/', import.meta.url));
export const defaultRoot = join(homedir(), 'Library/Application Support/Still/native-plugins');
export const ids = [
  'agents',
  'build-watch',
  'deploy-watch',
  'task-watch',
  'mac-pulse',
  'next-up',
  'world-clock',
  'quiet-timer',
  'weather',
  'spotify',
];
export async function regularJSON(path, limit = 16384) {
  const metadata = await lstat(path);
  if (!metadata.isFile() || metadata.isSymbolicLink() || metadata.size > limit)
    throw new Error('Unsafe or oversized plugin file');
  return JSON.parse(await readFile(path, 'utf8'));
}
export async function safeDirectory(path) {
  const parent = dirname(path);
  if (parent !== path) await safeDirectory(parent);
  try {
    const metadata = await lstat(path);
    if (!metadata.isDirectory() || metadata.isSymbolicLink()) throw new Error('Unsafe plugin directory');
  } catch (error) {
    if (error.code !== 'ENOENT') throw error;
    await mkdir(path, { mode: 0o700 });
  }
}
export async function atomicJSON(path, object) {
  try {
    await regularJSON(path);
  } catch (error) {
    if (error.code !== 'ENOENT') throw error;
  }
  const temporary = `${path}.${crypto.randomUUID()}.tmp`;
  await writeFile(temporary, `${JSON.stringify(object, null, 2)}\n`, { mode: 0o600, flag: 'wx' });
  await rename(temporary, path);
}
export function settings() {
  return {
    repository: '',
    projectID: '',
    teamID: '',
    scope: '',
    city: '',
    latitude: 0,
    longitude: 0,
    clocks: [{ name: 'Local', timeZone: Intl.DateTimeFormat().resolvedOptions().timeZone }],
    timerMinutes: 10,
    calendarID: '',
    showTitles: false,
    showCPU: true,
    showMemory: true,
    showBattery: true,
    showCompletedTasks: true,
    spotifyAuthorized: false,
  };
}
export async function install(root, selected = ids) {
  if (!selected.length || selected.some((id) => !ids.includes(id))) throw new Error('Unknown native plugin');
  await safeDirectory(root);
  for (const id of selected) {
    const manifest = await regularJSON(join(catalogRoot, id, 'plugin.json'));
    if (
      manifest.schemaVersion !== 2 ||
      manifest.id !== `co.mateonunez.still.${id}` ||
      manifest.publisher !== 'mateonunez' ||
      manifest.runtime !== 'native-builtin'
    )
      throw new Error('Invalid native manifest');
    await safeDirectory(join(root, id));
    await atomicJSON(join(root, id, 'plugin.json'), manifest);
    try {
      await regularJSON(join(root, id, 'configuration.json'));
    } catch (error) {
      if (error.code !== 'ENOENT') throw error;
      await atomicJSON(join(root, id, 'configuration.json'), {
        schemaVersion: 2,
        plugin: id,
        enabled: false,
        visible: false,
        settings: settings(),
      });
    }
  }
}
export async function configureLocal(root, project) {
  for (const id of ids) {
    const path = join(root, id, 'configuration.json'),
      config = await regularJSON(path);
    if (config.schemaVersion !== 2 || config.plugin !== id) throw new Error('Invalid existing configuration');
    config.enabled = true;
    config.visible = ['agents', 'mac-pulse', 'world-clock', 'spotify'].includes(id);
    if (id === 'build-watch') config.settings.repository = 'mateonunez/still';
    if (id === 'deploy-watch') {
      config.settings.projectID = project.projectId;
      config.settings.teamID = project.orgId;
      config.settings.scope = 'mmateonunez';
    }
    if (id === 'weather') {
      config.settings.city = 'Milan';
      config.settings.latitude = 45.4642;
      config.settings.longitude = 9.19;
    }
    if (id === 'world-clock')
      config.settings.clocks = [
        { name: 'Milan', timeZone: 'Europe/Rome' },
        { name: 'New York', timeZone: 'America/New_York' },
        { name: 'Tokyo', timeZone: 'Asia/Tokyo' },
      ];
    config.settings.timerMinutes = 10;
    await atomicJSON(path, config);
  }
}
