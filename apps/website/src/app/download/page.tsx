import { pageMetadata } from '@/content/site';
import { Article, type ArticleContent } from '@/features/support/article';

const content: ArticleContent = {
  title: 'Coming into focus.',
  description: 'Still is in development. Learn about the planned direct macOS app download and current availability.',
  eyebrow: 'AVAILABILITY',
  lead: 'Still is being built as a real native Mac app. It is not publicly available yet.',
  sections: [
    {
      title: 'A considered first release.',
      text: 'We’re testing system authentication, desktop coverage, accessibility and day-to-day behavior before a public download. Current development evidence comes from an Apple Silicon Mac on macOS 26; a supported macOS and hardware matrix has not been announced.',
    },
    {
      title: 'Direct to your Mac.',
      text: 'The plan is a signed, notarized app download outside the Mac App Store. Homebrew will be considered after the normal installation path is verified. No installer, purchase or working Homebrew command is available today.',
    },
    {
      title: 'Keep an eye on the field notes.',
      text: 'The changelog documents what is being refined. Pricing, release timing and final compatibility are still undecided.',
    },
  ],
};
export const metadata = pageMetadata('Download and availability', content.description, '/download');
export default function Page() {
  return <Article content={content} />;
}
