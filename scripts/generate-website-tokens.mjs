import { readFile, writeFile } from 'node:fs/promises';

const tokens = JSON.parse(await readFile(new URL('../design/tokens.json', import.meta.url), 'utf8'));
const declarations = (mode, source = tokens) =>
  Object.entries(source[mode])
    .map(([role, value]) => `  --${role}: ${value.toLowerCase()};`)
    .join('\n');
await writeFile(
  new URL('../apps/website/src/app/tokens.css', import.meta.url),
  `/* Generated from design/tokens.json. */\n:root {\n${declarations('light')}\n}\n[data-appearance="dark"] {\n${declarations('dark')}\n}\n[data-theme="glass"] {\n${declarations('light', tokens.glass)}\n}\n[data-theme="glass"][data-appearance="dark"] {\n${declarations('dark', tokens.glass)}\n}\n`,
);
