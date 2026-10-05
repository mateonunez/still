import Link from 'next/link';
import { pageMetadata, site } from '@/content/site';
import { Preview } from '@/features/home/preview';

export const metadata = pageMetadata('Still — A calm privacy screen for Mac', site.description, '/');
const benefits = [
  [
    '01',
    'A quieter kind of screen.',
    'Warm porcelain. Deep burgundy. A little breathing room, in light or dark. Beautiful enough to leave on.',
  ],
  [
    '02',
    'Made to feel like your Mac.',
    'A native menu-bar app, with system-owned Touch ID and Mac-password authentication. Familiar, intentional, yours.',
  ],
  [
    '03',
    'Step away on your terms.',
    'Show Still when you choose, or after inactivity. Your Mac and display stay awake while covered. System-owned authentication brings you back.',
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
            Step away.
            <br />
            <em>Stay in flow.</em>
          </h1>
          <p className="hero-description">
            A beautiful screen for the moments between.
            <br className="desktop-break" /> Cover your desktop. Let the day breathe.
          </p>
          <div className="hero-actions">
            <a className="button-primary" href="#preview">
              Explore Still <span aria-hidden="true">↓</span>
            </a>
            <Link className="text-link" href="/how-it-works">
              Meet the idea <span aria-hidden="true">↗</span>
            </Link>
          </div>
          <p className="hero-footnote">Native macOS. Thoughtfully private. In development.</p>
        </div>
        <div className="hero-aside">
          <div className="orb" aria-hidden="true" />
          <p className="aside-caption">
            A pause for your screen.
            <br />
            Room for everything else.
          </p>
          <span className="aside-index" aria-hidden="true">
            STILL / 001
          </span>
        </div>
      </section>
      <Preview />
      <section className="intro">
        <p className="eyebrow">LESS NOISE. MORE INTENTION.</p>
        <h2>
          Your desktop doesn’t
          <br />
          always need an audience.
        </h2>
        <p>
          Still is a visual privacy curtain: an elegant surface over your desktop, with an intentional return. It
          doesn’t pause your apps itself, and it doesn’t replace the macOS security lock.
        </p>
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
      <section className="closing">
        <p className="eyebrow">A SMALL APP. A CONSIDERED BEGINNING.</p>
        <h2>
          Still is coming
          <br />
          <em>into focus.</em>
        </h2>
        <p>We’re refining the native experience, one thoughtful detail at a time.</p>
        <Link className="button-primary" href="/changelog">
          Follow the field notes <span aria-hidden="true">↗</span>
        </Link>
        <p className="closing-note">Porcelain first. Agent awareness and more themes, later.</p>
      </section>
    </main>
  );
}
