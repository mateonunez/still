import { readFile, writeFile } from 'node:fs/promises';

const tokens = JSON.parse(await readFile(new URL('../design/tokens.json', import.meta.url), 'utf8'));
const roles = {
  ink: 'textPrimary', muted: 'textSecondary', surface: 'surface', line: 'border',
  accent: 'accent', bg: 'background', 'on-accent': 'onAccent', 'accent-hover': 'accentHover',
  panel: 'activitySurface', 'panel-ink': 'activityText', 'panel-muted': 'activitySecondary', focus: 'focus'
};
const css = [
  '/* Generated from design/tokens.json. Run node scripts/generate-brand-css.mjs. */',
  `:root { --still-burgundy: ${tokens.light.accent}; }`,
  ...['light', 'dark'].map(mode => {
    const selector = mode === 'light' ? '.porcelain' : '.porcelain.dark';
    return `${selector} {\n${Object.entries(roles).map(([name, role]) => `  --${name}: ${tokens[mode][role]};`).join('\n')}\n}`;
  })
].join('\n\n');
await writeFile(new URL('../prototypes/assets/still-tokens.css', import.meta.url), `${css}\n`);
console.log('Generated Still light/dark CSS from design/tokens.json.');
