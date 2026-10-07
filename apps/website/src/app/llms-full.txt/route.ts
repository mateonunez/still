import { developerIntro, developerSections } from '@/features/developers/content';
import { plugins } from '@/features/plugins/catalog';
export const dynamic = 'force-static';
export function GET() {
  const text = [
    `# Still — Developer and agent guide`,
    `Native macOS visual privacy curtain, not the macOS security lock. Public MIT source and experimental preview at https://github.com/mateonunez/still/releases/tag/v0.1.0-preview.2. Ad-hoc signed, not notarized; no guaranteed supported hardware matrix.`,
    developerIntro,
    '## Preview setup and feedback\nhttps://meet-still.app/start\nhttps://github.com/mateonunez/still/issues/new?template=preview-feedback.yml\nReport observed results separately from untested cases. Keep credentials, conversations and private screenshots out of public reports.',
    ...developerSections.map((section) => `## ${section.title}\n${section.text}`),
    `## Resources\nhttps://meet-still.app/sdk/plugin-manifest-v1.schema.json\nhttps://meet-still.app/sdk/plugin-snapshot-v1.schema.json\nhttps://meet-still.app/sdk/local-signals/manifest.json\nhttps://meet-still.app/sdk/porcelain-rail/manifest.json\nhttps://meet-still.app/sdk/publish-sample.mjs\nhttps://meet-still.app/plugins/catalog.json\nhttps://meet-still.app/license\nhttps://meet-still.app/sdk/LICENSE`,
    `## Native collection`,
    ...plugins.map(
      (plugin) =>
        `### ${plugin.name}\n${plugin.summary}\nSource: ${plugin.source}\nSetup: ${plugin.setup}\nPrivacy: ${plugin.privacy}`,
    ),
  ].join('\n\n');
  return new Response(`${text}\n`, { headers: { 'Content-Type': 'text/plain; charset=utf-8' } });
}
