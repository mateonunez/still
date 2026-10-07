import { pageMetadata } from '@/content/site';
import { Article, type ArticleContent } from '@/features/support/article';

const content: ArticleContent = {
  title: 'A quieter screen. A clear boundary.',
  description:
    'How the Still website and current native development app handle privacy, authentication and local preferences.',
  eyebrow: 'PRIVACY · OCTOBER 7, 2026',
  lead: 'Still is being built around local preferences and system-owned authentication.',
  sections: [
    {
      title: 'Plugin sources stay explicit.',
      text: 'Native plugins read only the sources you configure: selected GitHub/Vercel resources through their separately authenticated CLIs, a selected local calendar with permission, local Spotify playback with Automation permission, system metrics, local clocks/timers and explicitly registered tasks. Weather sends your chosen coordinates to Open-Meteo. Titles for calendar and Spotify remain hidden unless enabled. Installing or discovering a module grants no source access.',
    },
    {
      title: 'On this website.',
      text: 'The production website uses Vercel Web Analytics to understand aggregate visits, pages and referring sites, with device/browser and approximate location information. Vercel describes this service as cookie-free, using a temporary visitor hash rather than cross-site personal identifiers. Still removes query strings and fragments from page-view URLs before sending them. No custom events, session replay or native-app telemetry are added. Local development and preview deployments do not load this integration. Local fonts are served with the site; hosting also involves ordinary request processing and logs. There is no account, email signup, payment form or advertising tracker.',
    },
    {
      title: 'In the development app.',
      text: 'The current app stores appearance, inactivity and selected sources locally. It reads elapsed input time when inactivity activation is enabled, without recording what you type. It does not capture desktop screenshots during normal use. Explicit developer probes can write local diagnostic receipts.',
    },
    {
      title: 'Authentication belongs to macOS.',
      text: 'Touch ID and Mac-password authentication are handled by the system. Still does not receive or store the account password in a custom form.',
    },
    {
      title: 'Agent information is optional.',
      text: 'The development app can connect account quota through your installed Codex client or Claude Code status line. Activity requires separate opt-in local hooks. Their input may transiently contain prompts and tool content; the native helper discards that content, stores only anonymous event states and does not open referenced transcripts. Attention signals are temporary, not verified pending approvals. Decisions remain in the original client; Codex hook trust stays under your control.',
    },
    {
      title: 'Local packages have a clear boundary.',
      text: 'Importing a template or metadata package does not connect a source. Still validates its manifest, renders approved cards and runs no package code. A local metadata producer must be started separately and retains its own system permissions. Disabling it in Still removes its connection and displayed facts; it does not revoke that external program’s system access. The public catalog documents native modules and SDK resources; it has no account, submission or purchase flow. Experimental app previews and source are public on GitHub.',
    },
  ],
};
export const metadata = pageMetadata('Privacy and system authentication', content.description, '/privacy');
export default function Page() {
  return <Article content={content} />;
}
