import { readFile, rename, writeFile } from 'node:fs/promises';
import { join } from 'node:path';

const [directory, state = 'working'] = process.argv.slice(2);
if (!directory || !['working', 'attentionRequested', 'completed', 'interrupted', 'unknown'].includes(state)) {
  throw new Error('Usage: node examples/plugins/publish-sample.mjs <connection-directory> [state]');
}
const connection = JSON.parse(await readFile(join(directory, 'connection.json'), 'utf8'));
if (connection.protocolVersion !== 1 || !connection.capabilities.includes('agentActivity')) {
  throw new Error('Connect a protocol-v1 activity source in Still first');
}
let revision = 0;
try {
  const previous = JSON.parse(await readFile(join(directory, 'snapshot.json'), 'utf8'));
  if (previous.connectionID === connection.connectionID) revision = previous.revision;
} catch (error) {
  if (error.code !== 'ENOENT') throw error;
}
const observed = new Date();
const snapshot = {
  protocolVersion: 1,
  pluginID: connection.pluginID,
  connectionID: connection.connectionID,
  revision: revision + 1,
  observedAt: observed.toISOString(),
  expiresAt: new Date(observed.getTime() + 60_000).toISOString(),
  isSample: true,
  facts: state === 'unknown' ? [] : [{ widgetID: 'signal', kind: 'agentActivity', state, count: 1 }],
};
const staged = join(directory, `.snapshot-${process.pid}.json`);
await writeFile(staged, JSON.stringify(snapshot), { mode: 0o600 });
await rename(staged, join(directory, 'snapshot.json'));
console.log(`Published sample revision ${snapshot.revision}; this is not real agent data.`);
