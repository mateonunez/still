import { site } from '@/content/site';
export const dynamic = 'force-static';
export function GET() {
  return new Response(
    `# Still\n\n> A little space to step away. Native macOS visual privacy curtain, MIT-licensed original code. Source remains private during development; no public app download. Still is not the macOS security lock.\n\n## Product\n- [How it works](${site.origin}/how-it-works)\n- [Availability](${site.origin}/download)\n- [Privacy](${site.origin}/privacy)\n- [Support](${site.origin}/support)\n- [MIT license](${site.origin}/license)\n\n## Extensions\n- [Native plugin catalog](${site.origin}/plugins)\n- [Catalog JSON](${site.origin}/plugins/catalog.json)\n- [Developer SDK](${site.origin}/developers)\n- [Full agent guide](${site.origin}/llms-full.txt)\n\nNo remote package execution, community publishing, automatic updates or approval actions are available.\n`,
    { headers: { 'Content-Type': 'text/plain; charset=utf-8' } },
  );
}
