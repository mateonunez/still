import Link from 'next/link';
import { release } from '@/content/release';
import { pageMetadata } from '@/content/site';

export const metadata = pageMetadata(
  'Your first few minutes with Still',
  'Set up the Still Mac preview: find the menu bar app, choose Porcelain or Glass, configure widgets, edit the screen and share useful feedback.',
  '/start',
);

export default function StartPage() {
  return (
    <main id="main" className="article">
      <p className="eyebrow">GET STARTED · EXPERIMENTAL PREVIEW</p>
      <h1>Your first few minutes of quiet.</h1>
      <p className="article-lead">Start simple. Make it yours. Connect only the details you want.</p>
      <section>
        <h2>First, open the preview.</h2>
        <p>
          <Link href="/download">Download Still and read the installation notes</Link>. The archive contains one
          universal app for Apple Silicon and Intel, built for macOS 14 or later. Current runtime evidence comes from
          Apple Silicon on macOS 26; Intel and earlier macOS versions still need real testing. This preview is ad-hoc
          signed and not notarized.
        </p>
        <p>
          Quit any existing Still before opening the new version. Keep macOS security protections enabled. If your Mac
          blocks the preview, follow the linked Apple guidance; managed Macs may not allow it.
        </p>
      </section>
      <section>
        <h2>Find Still in the menu bar.</h2>
        <p>
          Still lives at the top of your screen. Open its menu to show the curtain or open Settings. If no large window
          appears on launch, look for the Still icon in the menu bar.
        </p>
      </section>
      <section>
        <h2>Choose your appearance.</h2>
        <p>
          Open Settings → Appearance. Choose Porcelain or Glass, then light, dark or system appearance. Use the screen
          editor via Edit screen… to arrange the clock and modules in Grid or Free layout, then save your composition.
          Start with one widget so you can judge spacing on your own display.
        </p>
      </section>
      <section>
        <h2>Connect one source at a time.</h2>
        <p>
          In Settings → Plugins, enable a module, configure its source and choose Show on curtain. Enabled and visible
          are separate choices. The <Link href="/plugins">plugin catalog</Link> explains each source and permission.
          Configure sources while your desktop is available, before showing the curtain.
        </p>
        <ul>
          <li>World Clock and Quiet Timer are useful starting points without an external account.</li>
          <li>Spotify needs the local Spotify app and an explicit macOS Automation permission.</li>
          <li>Next Up needs calendar permission and your choice of calendar.</li>
          <li>Agents connects Codex and Claude quota separately from optional activity hooks.</li>
        </ul>
        <p>Unavailable or stale data is a source state, not a healthy zero. Check configuration before reconnecting.</p>
      </section>
      <section>
        <h2>Step away, then come back.</h2>
        <p>
          Show Still from its menu. While covered, it requests that your Mac and display stay awake; closing the lid,
          manual Sleep and system overrides still apply. Return with system-owned Touch ID where supported, or your Mac
          password in the macOS dialog. Still never asks for your password in its own form.
        </p>
        <p>
          Still is visual privacy, not the macOS security lock. Desktop gestures during activation or password handoff
          can expose underlying windows. Use the system lock when you need to secure the session.
        </p>
      </section>
      <section>
        <h2>Tell us what actually happened.</h2>
        <p>
          Successful installations are useful feedback too. Include the Still version, macOS version, Apple Silicon or
          Intel, display arrangement and the steps you tried. Distinguish a pass from something you did not test. Keep
          credentials, conversations, client logs and private screenshots out of public issues.
        </p>
        <div className="download-actions">
          <a className="button-primary" href={`${release.repository}/issues/new?template=preview-feedback.yml`}>
            Share your preview experience ↗
          </a>
          <Link className="text-link" href="/support">
            Find help ↗
          </Link>
        </div>
      </section>
    </main>
  );
}
