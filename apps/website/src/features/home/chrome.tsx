import Link from 'next/link';
import { Mark } from './mark';

export function Header() {
  return (
    <header className="site-header">
      <Link className="wordmark" href="/" aria-label="Still home">
        <Mark />
        Still<span className="wordmark-dot">.</span>
      </Link>
      <nav aria-label="Main navigation">
        <Link href="/how-it-works">How it works</Link>
        <Link href="/plugins">Plugins</Link>
        <Link href="/developers">Developers</Link>
        <Link className="nav-pill" href="/download">
          In development <span aria-hidden="true">↗</span>
        </Link>
      </nav>
    </header>
  );
}
export function Footer() {
  return (
    <footer className="site-footer">
      <div>
        <Link className="wordmark" href="/" aria-label="Still home">
          <Mark />
          Still<span className="wordmark-dot">.</span>
        </Link>
        <p>Made with care, for the moments between.</p>
        <a href="https://mateonunez.co">A personal project by Mateo Nunez ↗</a>
      </div>
      <nav aria-label="Footer navigation">
        <Link href="/plugins">Plugins</Link>
        <Link href="/developers">Developers</Link>
        <Link href="/support">Support</Link>
        <Link href="/privacy">Privacy</Link>
        <Link href="/changelog">Changelog</Link>
      </nav>
      <span className="footer-note">Native macOS · Coming into focus</span>
    </footer>
  );
}
