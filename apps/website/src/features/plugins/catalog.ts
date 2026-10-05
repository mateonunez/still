import manifests from './native-manifests.json';

type Details = { summary: string; source: string; setup: string; privacy: string; category: string };
const details: Record<string, Details> = {
  agents: {
    summary: 'Codex and Claude, together. Account quota and optional activity at a glance.',
    source: 'Installed Codex and Claude Code clients.',
    setup:
      'Enable Agents. Discover installed clients, then connect quota and activity separately in Settings → Agents. Codex hooks require client trust.',
    privacy:
      'No conversations or credentials. Hooks discard prompt/tool content and store anonymous, expiring states. Attention is advisory; decisions stay in the original client.',
    category: 'Work',
  },
  'build-watch': {
    summary: 'A quiet glance at your latest GitHub workflow.',
    source: 'GitHub through your installed, authenticated gh CLI.',
    setup: 'Choose a repository as owner/name. Sign in with gh separately, then save and refresh.',
    privacy: 'Reads workflow status for your selected repository. No source code, logs or tokens are copied.',
    category: 'Work',
  },
  'deploy-watch': {
    summary: 'Know when your latest Vercel deployment is ready.',
    source: 'Vercel through your installed, authenticated CLI.',
    setup: 'Choose project ID, team ID and optional scope. Sign in with Vercel separately, then save and refresh.',
    privacy: 'Reads selected deployment status. No deployment logs or tokens are copied.',
    category: 'Work',
  },
  'task-watch': {
    summary: 'Follow the commands you explicitly choose to share.',
    source: 'Local tasks registered by a separate command wrapper.',
    setup:
      'Enable Task Watch. A separately started producer reads the host-issued connection and publishes protocol-v2 receipts. The workspace wrapper is not published on npm.',
    privacy:
      'Only a chosen label, state and optional progress. Still does not capture command text, stdout or stderr, or discover arbitrary processes.',
    category: 'Work',
  },
  'mac-pulse': {
    summary: 'CPU, memory pressure and power. Just the essentials.',
    source: 'Native read-only macOS system metrics.',
    setup: 'Choose which metrics to display. No external account or OS permission prompt is required.',
    privacy: 'No process names, window titles or recorded input.',
    category: 'Your Mac',
  },
  'next-up': {
    summary: 'Your next event, from a calendar you choose.',
    source: 'Native macOS EventKit.',
    setup:
      'Grant calendar access explicitly and select a calendar. Event titles are hidden unless you choose to show them.',
    privacy: 'Reads your selected calendar locally. OS access and the selected calendar are separate choices.',
    category: 'Everyday',
  },
  'world-clock': {
    summary: 'A few places that matter to you.',
    source: 'Local macOS time-zone data.',
    setup: 'Choose up to three city labels and IANA time zones, such as Europe/Rome. Save your settings.',
    privacy: 'No location access or network connection.',
    category: 'Everyday',
  },
  'quiet-timer': {
    summary: 'A little time to step away, without a loud countdown.',
    source: 'A local timer.',
    setup:
      'Choose a duration from 1 to 240 minutes. Start or stop from plugin settings; disabling the plugin clears the timer.',
    privacy: 'No account or network. It does not unlock Still automatically.',
    category: 'Everyday',
  },
  weather: {
    summary: 'The weather where you want to be.',
    source: 'Open-Meteo during local, non-commercial evaluation.',
    setup:
      'Choose a city label and coordinates. A licensed commercial endpoint must be selected before a commercial release.',
    privacy: 'Coordinates are sent to the weather provider. Still does not request device location.',
    category: 'Everyday',
  },
  spotify: {
    summary: 'A little room for what is playing.',
    source: 'Your running local Spotify app, through native Apple Events.',
    setup:
      'Open Spotify and allow Automation explicitly in Settings → Plugins. Track and artist titles stay hidden unless enabled.',
    privacy: 'Read-only playback. No Spotify web login, listening history or playback controls.',
    category: 'Everyday',
  },
};

export const plugins = manifests.map((manifest) => {
  const description = details[manifest.slug];
  if (!description) throw new Error(`Missing public plugin documentation: ${manifest.slug}`);
  return { ...manifest, ...description };
});
export const catalog = {
  catalogVersion: 1,
  updatedAt: '2026-10-05',
  appAvailability: 'development-preview',
  installation: 'Built into Still. Enable and configure each source in Settings → Plugins. No public app download yet.',
  communityPublishing: false,
  automaticUpdates: false,
  plugins,
};
