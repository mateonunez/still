#!/usr/bin/env node
import { join, resolve } from 'node:path';
import { fileURLToPath } from 'node:url';
import { parseArgs } from 'node:util';
import { catalogRoot, configureLocal, defaultRoot, ids, install, regularJSON } from './registry.mjs';
import { inspectRepository } from './repository.mjs';

let machineOutput = process.argv.includes('--json');
try {
  const { values, positionals } = parseArgs({
    allowPositionals: true,
    options: {
      all: { type: 'boolean' },
      root: { type: 'string' },
      'configure-local': { type: 'boolean' },
      json: { type: 'boolean' },
      ref: { type: 'string' },
      path: { type: 'string' },
    },
  });
  machineOutput = values.json;
  const root = resolve(values.root ?? defaultRoot);
  if (positionals[0] === 'inspect' && positionals.length === 2) {
    if (values.all || values.root || values['configure-local'])
      throw new Error('Inspection does not accept installation options');
    const { code, report } = await inspectRepository(positionals[1], { ref: values.ref, path: values.path });
    if (values.json) console.log(JSON.stringify(report));
    else {
      if (report.source) console.log(`Source: ${report.source.url} · ${report.source.resolvedCommit}`);
      for (const candidate of report.candidates ?? []) {
        console.log(
          `${candidate.compatible ? 'Compatible' : 'Incompatible'}: ${candidate.path} · ${candidate.manifest?.name ?? candidate.error}`,
        );
      }
      if (report.error) console.log(`Inspection failed: ${report.error}`);
      else if (!report.candidates?.length) console.log('No Still packages found.');
      console.log('Read-only inspection. No package installed or source connected.');
    }
    process.exitCode = code;
  } else if (values.json || values.ref || values.path) {
    throw new Error('--json, --ref and --path currently apply only to inspect');
  } else if (positionals[0] === 'list') {
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
    throw new Error(
      'Usage: still-plugins inspect <local-path|https-repository> [--ref revision] [--path relative-folder] [--json] | list | add mateonunez <plugin...> [--all] [--configure-local] [--root path]',
    );
  }
} catch (error) {
  if (machineOutput)
    console.log(
      JSON.stringify({
        schemaVersion: 1,
        compatible: false,
        error: error.code ?? 'invalidArguments',
        actionsTaken: [],
      }),
    );
  else console.error(error.message);
  process.exitCode = 1;
}
