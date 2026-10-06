import { readFileSync, writeFileSync } from 'node:fs';

const tokens = JSON.parse(readFileSync(new URL('../design/tokens.json', import.meta.url), 'utf8'));
const roles = {
  background: 'background',
  surface: 'surface',
  primary: 'textPrimary',
  secondary: 'textSecondary',
  accent: 'accent',
  onAccent: 'onAccent',
  focus: 'focus',
};
const properties = Object.keys(roles)
  .map((role) => `    let ${role}: Color`)
  .join('\n');
const palette = (mode, source = tokens) =>
  Object.entries(roles)
    .map(([role, token]) => {
      const value = source[mode][token].slice(1);
      return `        ${role}: Color(red: ${parseInt(value.slice(0, 2), 16)} / 255.0, green: ${parseInt(value.slice(2, 4), 16)} / 255.0, blue: ${parseInt(value.slice(4, 6), 16)} / 255.0)`;
    })
    .join(',\n');
writeFileSync(
  new URL('../apps/macos/Sources/Still/PorcelainPalette.swift', import.meta.url),
  `// Generated from design/tokens.json by scripts/generate-native-tokens.mjs.\nimport SwiftUI\n\nstruct PorcelainPalette {\n${properties}\n\n    static let light = PorcelainPalette(\n${palette('light')}\n    )\n\n    static let dark = PorcelainPalette(\n${palette('dark')}\n    )\n\n    static let glassLight = PorcelainPalette(\n${palette('light', tokens.glass)}\n    )\n\n    static let glassDark = PorcelainPalette(\n${palette('dark', tokens.glass)}\n    )\n}\n`,
);
