import { pageMetadata } from '@/content/site';
import { Article, type ArticleContent } from '@/features/support/article';

const content: ArticleContent = {
  title: 'Your next pause starts here.',
  description:
    'Still beta availability: a native Mac privacy screen with configurable widgets and MIT-licensed code. Direct download is being prepared; no public installer yet.',
  eyebrow: 'AVAILABILITY',
  lead: 'An end-user beta is being prepared. There is no public app download yet.',
  sections: [
    {
      title: 'Made for the people who use it.',
      text: 'The beta will bring Porcelain and Glass, ten optional native plugins and a full-screen editor to end users. We’re testing screen coverage, recovery, accessibility and installation before making a download available. There is no announced release date.',
    },
    {
      title: 'Updates, deliberately.',
      text: 'Initial beta updates are planned as explicit manual replacements of a verified signed app, preserving local settings. Automatic app and plugin updates are deferred. Versioned release notes and compatibility will accompany each available build.',
    },
    {
      title: 'A broad target. Tested compatibility.',
      text: 'We’re targeting macOS 14 and later on Apple Silicon and Intel. Intel compilation has passed, while native runtime checks so far come from Apple Silicon on macOS 26. Each release will list its tested combinations; the target is not a supported-hardware guarantee.',
    },
    {
      title: 'Direct to your Mac.',
      text: 'The plan is a signed, notarized app download outside the Mac App Store. Homebrew will be considered after the normal installation path is verified. No installer, purchase or working Homebrew command is available today.',
    },
    {
      title: 'MIT licensed. Still in development.',
      text: 'Original code and documentation use the MIT license. The source repository remains private during development, and fonts retain their own licenses. Follow the changelog for progress; download access, release timing and final compatibility are still being prepared.',
    },
  ],
};
export const metadata = pageMetadata('Download and availability', content.description, '/download');
export default function Page() {
  return <Article content={content} />;
}
