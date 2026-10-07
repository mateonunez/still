import Link from 'next/link';
import { release } from '@/content/release';
import { pageMetadata, site } from '@/content/site';
import { NativeGallery } from '@/features/home/native-gallery';
import { Preview } from '@/features/home/preview';
import { plugins } from '@/features/plugins/catalog';

export const metadata = pageMetadata('Still — A calm screen and keep-awake app for Mac', site.description, '/');
const benefits = [
  [
    '01',
    'A screen that feels like yours.',
    'Warm Porcelain or softly lit Glass. Light or dark. Arrange your clock and widgets across the screen, with room to breathe.',
  ],
  [
    '02',
    'Keep the Mac awake.',
    'While Still is active, it requests that your Mac and display stay awake. Show it from the menu bar or after a period of inactivity.',
  ],
  [
    '03',
    'A familiar way back.',
    'Return with Touch ID on supported hardware or your Mac password in the system dialog. Authentication stays with macOS.',
  ],
] as const;

export default function Home() {
  const structuredData = {
    '@context': 'https://schema.org',
    '@type': 'WebSite',
    name: site.name,
    url: site.origin,
    description: site.description,
  };
  return (
    <main id="main">
      <script type="application/ld+json">{JSON.stringify(structuredData).replace(/</g, '\\u003c')}</script>
      <section className="hero">
        <div className="hero-copy">
          <p className="eyebrow">
            <span className="status-dot" /> A NATIVE PRIVACY SCREEN FOR MAC
          </p>
          <h1>
            A little space
            <br />
            <em>to step away.</em>
          </h1>
          <p className="hero-description">
            Cover your desktop. Keep your Mac awake.
            <br className="desktop-break" /> Bring only the details you want into view.
          </p>
          <div className="hero-actions">
            <Link className="button-primary" href="/download">
              Try the preview <span aria-hidden="true">↗</span>
            </Link>
            <a className="text-link" href={release.repository}>
              View on GitHub <span aria-hidden="true">↗</span>
            </a>
          </div>
          <p className="hero-footnote">Universal Mac preview · MIT licensed · Not notarized</p>
        </div>
        <div className="hero-aside">
          <div className="orb" aria-hidden="true" />
          <p className="aside-caption">
            A pause for your screen.
            <br />A little of your world in view.
          </p>
          <span className="aside-index" aria-hidden="true">
            STILL / 001
          </span>
        </div>
      </section>
      <Preview />
      <section className="launch-media" aria-labelledby="launch-media-title">
        <p className="eyebrow">THE NATIVE EDITOR, IN VIEW</p>
        <h2 id="launch-media-title">Two themes. Your composition.</h2>
        <video controls preload="none" poster="/media/editor-glass-dark.png" width="1280" height="800">
          <source src="/media/still-showcase.mp4" type="video/mp4" />
          <track kind="captions" src="/media/still-showcase.vtt" srcLang="en" label="English" default />
          <a href="/media/still-showcase.mp4">Download the visual showcase</a>
        </video>
        <p>
          Native SwiftUI view exports from the development build. A visual showcase, not a recording of gestures,
          authentication or live source connections.
        </p>
        <a className="text-link" href="/media/showcase-transcript.txt">
          Read the transcript ↗
        </a>
      </section>
      <NativeGallery />
      <section className="intro">
        <p className="eyebrow">LESS NOISE. MORE INTENTION.</p>
        <h2>
          Your desktop doesn’t
          <br />
          always need an audience.
        </h2>
        <p>
          A build is running. A track is playing. You’re taking a moment. Still gives your desktop a calmer face, with
          just the details you choose. It covers the screen without pausing your apps itself.
        </p>
      </section>
      <section className="workflow" aria-labelledby="workflow-title">
        <div className="workflow-heading">
          <p className="eyebrow">THREE SMALL STEPS</p>
          <h2 id="workflow-title">Make it yours. Then step away.</h2>
        </div>
        <ol>
          <li>
            <span className="benefit-number">01</span>
            <h3>Choose your quiet.</h3>
            <p>Pick a theme. Connect the widgets you need. Arrange them in Grid or Free layout.</p>
          </li>
          <li>
            <span className="benefit-number">02</span>
            <h3>Show Still.</h3>
            <p>Use the menu bar, or let an inactivity interval bring Still into view.</p>
          </li>
          <li>
            <span className="benefit-number">03</span>
            <h3>Come back.</h3>
            <p>Use system authentication to return. Still releases its keep-awake request.</p>
          </li>
        </ol>
      </section>
      <section className="benefits" aria-label="What makes Still different">
        {benefits.map(([number, title, text]) => (
          <article key={number}>
            <span className="benefit-number">{number}</span>
            <h3>{title}</h3>
            <p>{text}</p>
          </article>
        ))}
      </section>
      <section className="product-extensions">
        <p className="eyebrow">YOUR SCREEN. YOUR COMPOSITION.</p>
        <h2>
          A clock. A few essentials.
          <br />
          Room for quiet.
        </h2>
        <p>
          Ten optional native plugins, each with its own settings. Keep an eye on agent quota and recent signals, a
          build, your next event or Spotify playback. Move and resize the modules across your screen.
        </p>
        <div className="product-extension-links">
          {plugins.map((plugin) => (
            <Link key={plugin.id} href={`/plugins/${plugin.slug}`}>
              {plugin.name}
            </Link>
          ))}
        </div>
        <Link className="text-link" href="/plugins">
          Explore the native collection ↗
        </Link>
      </section>
      <section className="home-questions" aria-labelledby="questions-title">
        <p className="eyebrow">A FEW THINGS TO KNOW</p>
        <h2 id="questions-title">Quiet, with clear boundaries.</h2>
        <details>
          <summary>Does Still lock my Mac?</summary>
          <p>
            Still is a visual privacy curtain, not the macOS security lock. Desktop and Mission Control gestures can
            expose windows in the development candidate. Use the system lock when you need to secure your session.
          </p>
        </details>
        <details>
          <summary>Will my work keep running?</summary>
          <p>
            Still does not pause your apps and requests that the Mac stay awake while covered. Task progress depends on
            each app and its connection. Closing the lid, manual Sleep and system overrides remain available.
          </p>
        </details>
        <details>
          <summary>What do the agent widgets read?</summary>
          <p>
            Optional account quota and recent anonymous activity signals from configured Codex and Claude sources. They
            do not display conversations or decide approvals. Connect only what you want.
          </p>
        </details>
        <details>
          <summary>Can I try Still today?</summary>
          <p>
            An experimental preview is available for Apple Silicon and Intel. It is ad-hoc signed and not notarized.{' '}
            <Link href="/download">See availability and compatibility</Link>, or{' '}
            <Link href="/changelog">follow development</Link>.
          </p>
        </details>
      </section>
      <section className="preview-roadmap" aria-labelledby="preview-roadmap-title">
        <p className="eyebrow">BUILT IN THE OPEN</p>
        <h2 id="preview-roadmap-title">A preview with a clear next step.</h2>
        <ol>
          <li>
            <h3>Now · Try and shape it.</h3>
            <p>Two themes, ten native plugins and a configurable screen. Share focused feedback from your Mac.</p>
          </li>
          <li>
            <h3>Next · Make the everyday reliable.</h3>
            <p>
              Refine editor movement, multi-display behavior, authentication and source connections through real
              testing.
            </p>
          </li>
          <li>
            <h3>Then · A smoother way to install.</h3>
            <p>
              Personal Developer ID signing, notarization and clean-install checks before the beta. Automatic updates
              follow a defined release contract.
            </p>
          </li>
        </ol>
        <div className="download-actions">
          <a className="text-link" href={`${release.repository}/issues`}>
            Share preview feedback ↗
          </a>
          <a className="text-link" href={`${release.repository}/blob/main/docs/roadmap.md`}>
            Read the roadmap ↗
          </a>
          <a className="text-link" href="https://mateonunez.co/blog/still-a-little-space-to-step-away/">
            Why I built Still ↗
          </a>
        </div>
      </section>
      <section className="closing">
        <p className="eyebrow">BUILT FOR THE MOMENTS BETWEEN</p>
        <h2>
          Your next pause.
          <br />
          <em>A little more yours.</em>
        </h2>
        <p>Try the experimental preview. Build with the open-source app and developer SDK.</p>
        <Link className="button-primary" href="/download">
          Try the preview <span aria-hidden="true">↗</span>
        </Link>
        <p className="closing-note">Porcelain and Glass · Ten native plugins · MIT licensed</p>
      </section>
    </main>
  );
}
