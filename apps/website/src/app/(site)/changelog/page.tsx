import { pageMetadata } from '@/content/site';
import { Article, type ArticleContent } from '@/features/support/article';

const content: ArticleContent = {
  title: 'Small steps. Thoughtful details.',
  description:
    'Still development field notes: Porcelain, native authentication, inactivity and current desktop coverage work.',
  eyebrow: 'FIELD NOTES · OCTOBER 5, 2026',
  lead: 'A public notebook for an app taking shape. Development progress is not a release announcement.',
  sections: [
    {
      title: 'Porcelain, in light and dark.',
      text: 'The initial direction pairs warm porcelain and deep plum with burgundy accents, Instrument Serif display typography and native system controls. More themes remain an idea for later.',
    },
    {
      title: 'A native beginning.',
      text: 'The local app includes a menu-bar mark, manual curtain, system-owned Touch ID and Mac-password fallback, and optional inactivity activation. Native macOS 26 glass controls are being refined with accessibility fallbacks.',
    },
    {
      title: 'A simpler product surface.',
      text: 'The local app now keeps the Mac awake automatically while its curtain is active, releasing that request when you return. Display sleep remains under macOS control. Independent timed awake controls remain retained and hidden.',
    },
    {
      title: 'The desktop edge cases.',
      text: 'Mission Control and trackpad desktop transitions remain open findings. Testing these real native gestures is a priority before describing coverage as reliable. No public native release is available.',
    },
  ],
};
export const metadata = pageMetadata('Changelog and development field notes', content.description, '/changelog');
export default function Page() {
  return <Article content={content} />;
}
