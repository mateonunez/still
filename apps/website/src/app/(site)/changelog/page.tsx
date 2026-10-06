import { pageMetadata } from '@/content/site';
import { Article, type ArticleContent } from '@/features/support/article';

const content: ArticleContent = {
  title: 'Small steps. Thoughtful details.',
  description:
    'Still development field notes: Porcelain, native authentication, inactivity and current desktop coverage work.',
  eyebrow: 'FIELD NOTES · OCTOBER 6, 2026',
  lead: 'A public notebook for an app taking shape. Development progress is not a release announcement.',
  sections: [
    {
      title: 'One voice. An MIT foundation.',
      text: 'The product story now centers on “A little space to step away.” The website explains the everyday workflow, keeps beta availability clear and publishes the MIT license alongside font notices. Compatibility targets include macOS 14+ and both architectures; real older-system and Intel acceptance remain open. The beta is being prepared for end users, not a fixed small cohort.',
    },
    {
      title: 'Ten native plugins. One quiet screen.',
      text: 'The development app now includes the mateonunez collection: Agents, Build Watch, Deploy Watch, Task Watch, Mac Pulse, Next Up, World Clock, Quiet Timer, Weather and Spotify. Each source has its own configuration. Spotify playback has been confirmed in the native candidate; broader source, permission and failure cases remain under acceptance.',
    },
    {
      title: 'Make room, across the screen.',
      text: 'A full-screen editor positions the clock and native widgets, with adaptive Grid, continuous Free placement and saved layouts. General, Appearance, Agents and Plugins now share one Settings window. Collision handling, varied display geometries and accessibility still need refinement.',
    },
    {
      title: 'A public foundation for builders.',
      text: 'The website now documents the native collection, publishes versioned declarative schemas and starter resources, and shares a plain-text guide for agents. This is a catalog and local SDK, not community publishing or remote executable installation.',
    },
    {
      title: 'A small library. A clear contract.',
      text: 'The development app now has a unified General, Appearance, Agents and Plugins Settings window. Local declarative packages use a versioned manifest and validated metadata; templates never connect a source. A developer validator and starter packages are prepared. Still renders the cards and runs no imported code; a hosted marketplace remains future scope.',
    },
    {
      title: 'Optional agent signals.',
      text: 'Native Codex and Claude account-quota sources are available in the local candidate. Separate opt-in hooks project anonymous activity states, with client trust and real event delivery still under acceptance. Attention is advisory; approval decisions stay in the original client. First-activation Touch ID and gesture exposure remain open native findings.',
    },
    {
      title: 'Porcelain, in light and dark.',
      text: 'The initial direction pairs warm porcelain and deep plum with burgundy accents, Instrument Serif display typography and native system controls. Glass is now the second official native theme, with Still-owned scenery and within-window content materials. Both themes support light and dark appearances; physical material and accessibility acceptance remain in progress.',
    },
    {
      title: 'A native beginning.',
      text: 'The local app includes a menu-bar mark, manual curtain, system-owned Touch ID and Mac-password fallback, and optional inactivity activation. Native macOS 26 glass controls are being refined with accessibility fallbacks.',
    },
    {
      title: 'A simpler product surface.',
      text: 'The local app now keeps the Mac awake automatically while its curtain is active, releasing that request when you return. The display also stays awake during idle coverage; explicit sleep and system overrides remain available. Independent timed awake controls remain retained and hidden.',
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
