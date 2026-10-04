import { readFile } from 'node:fs/promises';

const tokens = JSON.parse(await readFile(new URL('../design/tokens.json', import.meta.url), 'utf8'));
const luminance = hex => {
  const channels = [1, 3, 5].map(offset => Number.parseInt(hex.slice(offset, offset + 2), 16) / 255);
  const linear = channels.map(value => value <= 0.04045 ? value / 12.92 : ((value + 0.055) / 1.055) ** 2.4);
  return linear.reduce((sum, value, i) => sum + value * [0.2126, 0.7152, 0.0722][i], 0);
};
const pairs = [
  ['textPrimary', 'background', 4.5], ['textSecondary', 'background', 4.5],
  ['textPrimary', 'surface', 4.5], ['textSecondary', 'surface', 4.5],
  ['onAccent', 'accent', 4.5], ['onAccent', 'accentHover', 4.5],
  ['activityText', 'activitySurface', 4.5], ['activitySecondary', 'activitySurface', 4.5],
  ['focus', 'background', 3], ['focus', 'surface', 3],
  ['accent', 'background', 3], ['accent', 'surface', 3],
  ['onAccent', 'textSecondary', 3]
];
let failed = false;
for (const mode of ['light', 'dark']) {
  for (const [foreground, background, minimum] of pairs) {
    const [low, high] = [luminance(tokens[mode][foreground]), luminance(tokens[mode][background])].sort((a, b) => a - b);
    const ratio = (high + 0.05) / (low + 0.05);
    const passes = ratio >= minimum;
    console.log(`${passes ? 'PASS' : 'FAIL'} ${mode}: ${foreground} / ${background} = ${ratio.toFixed(2)}:1 (min ${minimum})`);
    if (!passes) failed = true;
  }
}
if (failed) process.exitCode = 1;
