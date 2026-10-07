import { pageMetadata } from '@/content/site';
import { Article, type ArticleContent } from '@/features/support/article';

const content: ArticleContent = {
  title: 'A little help, when you need it.',
  description:
    'Still support: development status, system authentication, sleep behavior and known Mission Control/desktop transition limits.',
  eyebrow: 'SUPPORT',
  lead: 'Trying the experimental preview? Start with setup, source permissions and the known limits.',
  links: [
    { label: 'Get started', href: '/start' },
    {
      label: 'Share preview feedback',
      href: 'https://github.com/mateonunez/still/issues/new?template=preview-feedback.yml',
    },
    { label: 'Report a bug', href: 'https://github.com/mateonunez/still/issues/new?template=bug.yml' },
  ],
  sections: [
    {
      title: 'How do I set up a plugin?',
      text: 'Open Settings → Plugins, enable a module, configure its source and choose Show on curtain. Sources requiring OS access request it explicitly. Enabled and visible are separate: you can preview a connected source without placing it on your curtain. Agent quota and activity connect separately in Settings → Agents.',
    },
    {
      title: 'What makes a useful preview report?',
      text: 'Include app version, macOS version, hardware/display arrangement, the affected plugin and a short reproduction with expected and actual results. Distinguish missing data, permission refusal and stale data. Omit account credentials, conversations, raw client logs and private project or event details.',
    },
    {
      title: 'Is Still a security lock?',
      text: 'No. It is a visual privacy curtain with an intentional authenticated return. It cannot provide OS-lock guarantees, and Mission Control or desktop gestures can expose windows in the current preview. Use the macOS security lock for security-sensitive situations.',
    },
    {
      title: 'Will every task keep running?',
      text: 'Still requests that the Mac and display stay awake while covered; prolonged screen-saver and awake behavior still need real acceptance checks. Manual Sleep, lid closure and system overrides remain available. Task progress also depends on the application and network.',
    },
    {
      title: 'What if Touch ID isn’t available?',
      text: 'The intended fallback is system-owned Mac-password authentication. Exact behavior depends on hardware and system capability, and is still undergoing native acceptance testing.',
    },
    {
      title: 'Can I download it now?',
      text: 'An experimental universal preview is available on GitHub Releases, alongside MIT-licensed source. It is ad-hoc signed, not notarized. See /download for checksums, installation and known limits. The signed end-user beta comes later.',
    },
  ],
};
export const metadata = pageMetadata('Support and known limitations', content.description, '/support');
export default function Page() {
  return <Article content={content} />;
}
