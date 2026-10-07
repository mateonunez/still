export const developerSections = [
  {
    title: 'MIT licensed. Ready to build on.',
    text: 'Still’s original code, schemas and starter resources use the MIT license. Preserve the copyright and license notice when sharing copies. Bundled fonts retain their own licenses. Source and experimental app previews are public on GitHub; package publication is separate.',
  },
  {
    title: 'Two extension paths.',
    text: 'The ten native plugins are reviewed, compiled modules shipped with Still. Their catalog/configuration uses schema version 2. The public local SDK uses declarative schema/protocol version 1 for metadata and Porcelain templates. The native screen supports Porcelain and Glass, while the v1 imported-template contract remains Porcelain-only. These contracts are different; a manifest does not install executable code. Still does not run imported packages or start a metadata producer.',
  },
  {
    title: 'Start with a small package.',
    text: 'Create a folder ending in .stillplugin with manifest.json. Optional README.md and LICENSE are the only other accepted files. Use your own unique reverse-domain ID. Choose kind metadata with local providers, or kind template with supported Codex/Claude provider cards. Templates support porcelain with corner or rail; custom canvas positioning is currently native-module only. No scripts, assets, credentials, actions or private fields belong in the package.',
  },
  {
    title: 'Import first. Connect separately.',
    text: 'In the development app, choose Settings → Plugins → Import package. Importing does not grant access. Enable a local metadata source explicitly, then Show inbox to find its host-issued connection.json. Start your producer separately with the permissions you choose. Still does not launch, sandbox or stop it.',
  },
  {
    title: 'Publish a bounded snapshot.',
    text: 'Read the current connection identity. Atomically replace snapshot.json with a full protocol-v1 snapshot: pluginID, connectionID, increasing positive revision, observedAt, expiresAt, isSample and facts. Maximum 64 KiB and four unique declared widget facts. Revision stays within JavaScript’s safe integer range. ISO 8601 expiry is at most five minutes, with five seconds of future skew. The schemas define the exact fields.',
  },
  {
    title: 'Keep source data out of the contract.',
    text: 'Quota facts contain one or two usage windows; activity facts contain an anonymous state and count from 0 to 64. States are working, attentionRequested, completed, interrupted, failed and unknown. No prompts, conversations, command text, file paths, transcript references, credentials or raw errors are accepted. Attention is advisory, never an approval decision or verified pending count.',
  },
  {
    title: 'Expiry and revocation are part of the API.',
    text: 'Every snapshot replaces all prior facts; facts: [] clears them. Re-reading a revision does not extend freshness. Invalid input clears displayed facts. Disconnect removes the host connection and snapshot; re-enable and app restart rotate the UUID. Producers must reread it. Suspension clears data. Revocation stops consumption, not the external producer’s OS permissions.',
  },
  {
    title: 'A sample stays a sample.',
    text: 'The downloadable publisher below sends a 60-second sample and exits; it does not observe a real agent. Sample cards remain visibly labelled. Real sources must use isSample: false only when backed by actual provider evidence. Test malformed/oversized data, old revisions, expiry, reconnect, empty snapshots and disconnect before sharing a package.',
  },
  {
    title: 'Repository-first, without a central gatekeeper.',
    text: 'The next extension path is repository-based discovery and reviewed installation from Settings or the CLI. A compatible package should not need a public catalog listing first. The plan separates installation, configuration and source access, records the exact source commit, and makes compatibility failures readable for people and agents. This flow is in development; the current SDK still uses local declarative imports. Skills, Codex and Claude package formats are not automatically Still-compatible.',
  },
  {
    title: 'Distribution and updates.',
    text: 'The public catalog documents built-in modules; it is not a remote installer. The experimental app is distributed through GitHub Releases; the workspace CLI and validator are available from source, not as published npm packages. No working npx or Homebrew installation command is advertised. Community submissions, package upgrades and automatic app/plugin updates are not available. Initial beta updates will use an explicit manual replacement flow once signed artifacts exist.',
  },
] as const;
export const developerIntro =
  'A small, declarative contract for local metadata and Porcelain templates. Readable by people. Precise enough for agents.';
