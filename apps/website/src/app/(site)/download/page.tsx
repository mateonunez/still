import { release } from '@/content/release';
import { pageMetadata } from '@/content/site';

export const metadata = pageMetadata(
  'Download the experimental preview',
  'Download Still’s universal Mac preview. Open-source under MIT, with Porcelain and Glass, configurable widgets, checksums and explicit compatibility limits.',
  '/download',
);
export default function DownloadPage() {
  return (
    <main id="main" className="article">
      <p className="eyebrow">EXPERIMENTAL PREVIEW · {release.version}</p>
      <h1>Your next pause starts here.</h1>
      <p className="article-lead">Try Still on your Mac. This preview is ad-hoc signed and not notarized by Apple.</p>
      <nav className="download-actions" aria-label="Preview downloads">
        <a className="button-primary" href={release.download}>
          Download for Mac ↗
        </a>
        <a href={release.notes}>Release notes and known limits ↗</a>
        <a href={release.checksum}>SHA256 checksums ↗</a>
      </nav>
      <section>
        <h2>A preview, with clear boundaries.</h2>
        <p>
          Porcelain and Glass, a full-screen editor and ten configurable native plugins are available to explore. Still
          is visual privacy, not the macOS security lock. Desktop gestures during activation or system-password handoff
          can expose underlying windows. Authentication, accessibility, multi-display and prolonged keep-awake checks
          remain incomplete.
        </p>
      </section>
      <section>
        <h2>Apple Silicon and Intel. A broad target.</h2>
        <p>
          The ZIP includes a universal app and universal helpers, compiled with a macOS 14 deployment target. Runtime
          checks so far come from Apple Silicon on macOS 26; older macOS and Intel runtime compatibility are not
          certified. Use the release notes for the exact build and tested boundaries.
        </p>
      </section>
      <section>
        <h2>Open it deliberately.</h2>
        <ol>
          <li>Download and extract the ZIP. Quit any other Still instance.</li>
          <li>Move Still.app to Applications and open it. Back up custom layouts before replacing an older version.</li>
          <li>
            macOS may block this unidentified, unnotarized preview. If you trust the source, Apple’s per-app “Open
            Anyway” action may be available in System Settings → Privacy &amp; Security. Managed Macs may prohibit it.
            Never disable Gatekeeper globally.
          </li>
        </ol>
        <p>
          <a href="https://support.apple.com/en-us/102445">Apple’s guidance on opening apps safely ↗</a>
        </p>
      </section>
      <section>
        <h2>Verify the download.</h2>
        <p>Download SHA256SUMS beside the ZIP and run:</p>
        <pre>
          <code>{'shasum -a 256 -c SHA256SUMS'}</code>
        </pre>
        <p className="checksum-text">ZIP SHA256: {release.sha256}</p>
      </section>
      <section>
        <h2>Updates stay in your hands.</h2>
        <p>
          Each tagged preview has a semantic version, release notes and checksums. Download the next version manually,
          quit Still and replace the app. Automatic app/plugin updates and Homebrew installation are not available. The
          signed, notarized beta comes later.
        </p>
      </section>
      <section>
        <h2>Open source. MIT licensed.</h2>
        <p>
          <a href={release.repository}>Read the source, report an issue or contribute on GitHub ↗</a>. Fonts retain
          their own licenses. No account or purchase is required.
        </p>
      </section>
    </main>
  );
}
