import { pageMetadata } from '@/content/site';
import { Article, type ArticleContent } from '@/features/support/article';

const content: ArticleContent = {
  title: 'A little help, when you need it.',
  description:
    'Still support: development status, system authentication, sleep behavior and known Mission Control/desktop transition limits.',
  eyebrow: 'SUPPORT',
  lead: 'Still is in development. These are the questions shaping the first release.',
  sections: [
    {
      title: 'Is Still a security lock?',
      text: 'No. It is a visual privacy curtain with an intentional authenticated return. It cannot provide OS-lock guarantees, and Mission Control or desktop gestures can expose windows in the current preview. Use the macOS security lock for security-sensitive situations.',
    },
    {
      title: 'Will every task keep running?',
      text: 'Still does not suspend applications itself. Whether a task continues depends on the app, network and macOS energy behavior. The current product UI does not expose keep-awake controls.',
    },
    {
      title: 'What if Touch ID isn’t available?',
      text: 'The intended fallback is system-owned Mac-password authentication. Exact behavior depends on hardware and system capability, and is still undergoing native acceptance testing.',
    },
    {
      title: 'Can I download it now?',
      text: 'A public app download is not available. The local development preview is being tested before signing, notarization and distribution. Compatibility and pricing will be published with a verified release.',
    },
  ],
};
export const metadata = pageMetadata('Support and known limitations', content.description, '/support');
export default function Page() {
  return <Article content={content} />;
}
