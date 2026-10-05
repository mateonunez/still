import { pageMetadata } from '@/content/site';
import { Article, type ArticleContent } from '@/features/support/article';

const content: ArticleContent = {
  title: 'A little space to step away.',
  description:
    'How Still works: show a native Mac privacy curtain, choose optional inactivity activation, and return with system authentication.',
  eyebrow: 'HOW STILL WORKS',
  lead: 'Show Still. Take your moment. Return when you’re ready.',
  sections: [
    {
      title: 'A curtain, when you choose.',
      text: 'Still lives in the menu bar. Show it manually, or choose a period of inactivity. Porcelain covers the desktop in warm light or deep-plum dark. After returning, a fresh inactivity interval begins.',
    },
    {
      title: 'A familiar way back.',
      text: 'On supported hardware, Still uses system-owned Touch ID. Mac-password fallback happens in macOS authentication UI. Still never asks you to type your Mac password into an app-owned field.',
    },
    {
      title: 'Your Mac stays your Mac.',
      text: 'Still keeps your Mac awake while its curtain is active and releases that request when you return. Your display can still sleep. Still does not change the security-lock policy, prevent manual Sleep or guarantee progress in every application.',
    },
    {
      title: 'Visual privacy has a boundary.',
      text: 'Still is not the macOS security lock. Mission Control and trackpad desktop transitions can expose underlying windows in the development preview. Use the macOS security lock when you need a secure lock; these native coverage cases are still being refined.',
    },
  ],
};
export const metadata = pageMetadata(
  'How Still works: a native Mac privacy screen',
  content.description,
  '/how-it-works',
);
export default function Page() {
  return <Article content={content} />;
}
