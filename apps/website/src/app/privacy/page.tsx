import { pageMetadata } from '@/content/site';
import { Article, type ArticleContent } from '@/features/support/article';

const content: ArticleContent = {
  title: 'A quieter screen. A clear boundary.',
  description:
    'How the Still website and current native development app handle privacy, authentication and local preferences.',
  eyebrow: 'PRIVACY · OCTOBER 4, 2026',
  lead: 'Still is being built around local preferences and system-owned authentication.',
  sections: [
    {
      title: 'On this website.',
      text: 'This site has no account, email signup, payment form or advertising analytics. Local fonts are served with the site. Hosting on Vercel involves ordinary request processing and hosting logs; visiting a website is not anonymous to its hosting provider.',
    },
    {
      title: 'In the development app.',
      text: 'The current app stores appearance and inactivity preferences locally. It reads elapsed input time when inactivity activation is enabled, without recording what you type. It does not collect agent conversations, desktop screenshots or activity content. Explicit developer probes can write local diagnostic receipts.',
    },
    {
      title: 'Authentication belongs to macOS.',
      text: 'Touch ID and Mac-password authentication are handled by the system. Still does not receive or store the account password in a custom form.',
    },
    {
      title: 'Future capabilities need new decisions.',
      text: 'Agent awareness is future scope, intended for optional status and usage metadata. No provider integration is active. Privacy information will be updated as real product behavior changes.',
    },
  ],
};
export const metadata = pageMetadata('Privacy and system authentication', content.description, '/privacy');
export default function Page() {
  return <Article content={content} />;
}
