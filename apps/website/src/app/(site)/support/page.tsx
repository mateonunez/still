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
      title: 'How do I set up a plugin?',
      text: 'Open Settings → Plugins, enable a module, configure its source and choose Show on curtain. Sources requiring OS access request it explicitly. Enabled and visible are separate: you can preview a connected source without placing it on your curtain. Agent quota and activity connect separately in Settings → Agents.',
    },
    {
      title: 'What makes a useful beta report?',
      text: 'Include app version, macOS version, hardware/display arrangement, the affected plugin and a short reproduction with expected and actual results. Distinguish missing data, permission refusal and stale data. Omit account credentials, conversations, raw client logs and private project or event details.',
    },
    {
      title: 'Is Still a security lock?',
      text: 'No. It is a visual privacy curtain with an intentional authenticated return. It cannot provide OS-lock guarantees, and Mission Control or desktop gestures can expose windows in the current preview. Use the macOS security lock for security-sensitive situations.',
    },
    {
      title: 'Will every task keep running?',
      text: 'Still prevents idle system sleep while its curtain is active. Still also prevents idle display sleep while covered; manual Sleep, lid closure and system overrides remain available. Task progress also depends on the application and network.',
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
