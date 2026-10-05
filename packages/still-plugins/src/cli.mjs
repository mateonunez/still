#!/usr/bin/env node
import { join, resolve } from 'node:path';
import { fileURLToPath } from 'node:url';
import { parseArgs } from 'node:util';
import { catalogRoot, configureLocal, defaultRoot, ids, install, regularJSON } from './registry.mjs';

try {
  const { values, positionals } = parseArgs({
    allowPositionals: true,
    options: { all: { type: 'boolean' }, root: { type: 'string' }, 'configure-local': { type: 'boolean' } },
  });
  const root = resolve(values.root ?? defaultRoot);
  if (positionals[0] === 'list') {
    for (const id of ids) {
      const manifest = await regularJSON(join(catalogRoot, id, 'plugin.json'));
      console.log(`${manifest.id} · ${manifest.name} · ${manifest.version}`);
    }
  } else if (positionals[0] === 'add' && positionals[1] === 'mateonunez') {
    const selected = values.all ? ids : positionals.slice(2);
    await install(root, selected);
    if (values['configure-local']) {
      if (!values.all) throw new Error('Local preset requires --all');
      const project = await regularJSON(fileURLToPath(new URL('../../../.vercel/project.json', import.meta.url)));
      if (project.projectName !== 'still') throw new Error('Local preset requires the personal Still project');
      await configureLocal(root, project);
    }
    console.log(
      `Installed ${selected.length} mateonunez native plugins. Existing configuration is preserved unless --configure-local is explicit.`,
    );
  } else {
    throw new Error('Usage: still-plugins list | add mateonunez <plugin...> [--all] [--configure-local] [--root path]');
  }
} catch (error) {
  console.error(error.message);
  process.exitCode = 1;
}
