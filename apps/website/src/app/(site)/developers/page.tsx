import Link from 'next/link';
import { pageMetadata } from '@/content/site';
import { developerIntro, developerSections } from '@/features/developers/content';

export const metadata = pageMetadata(
  'Build plugins and templates for Still',
  'Still developer SDK: versioned local metadata, declarative templates, JSON schemas, starter manifests and a sample producer. Human and agent documentation.',
  '/developers',
);
export default function DeveloperPage() {
  return (
    <main id="main" className="article developer-page">
      <p className="eyebrow">STILL FOR DEVELOPERS · PUBLIC CONTRACT V1</p>
      <h1>
        Build a little <em>room for useful.</em>
      </h1>
      <p className="article-lead">{developerIntro}</p>
      <p>
        Authoring resources are public. Native import and connection require access to the development app; a public app
        download is not available yet.
      </p>
      <nav className="developer-assets" aria-label="SDK resources">
        <a href="/sdk/plugin-manifest-v1.schema.json" download>
          Manifest schema
        </a>
        <a href="/sdk/plugin-snapshot-v1.schema.json" download>
          Snapshot schema
        </a>
        <a href="/sdk/local-signals/manifest.json" download>
          Metadata starter
        </a>
        <a href="/sdk/porcelain-rail/manifest.json" download>
          Template starter
        </a>
        <a href="/sdk/publish-sample.mjs" download>
          Sample publisher
        </a>
        <a href="/llms-full.txt">Agent guide</a>
        <a href="/plugins/catalog.json">JSON catalog</a>
      </nav>
      <section>
        <h2>A manifest. A separate producer.</h2>
        <p>
          The starter creates a local metadata package. Download the publisher separately; executable files must stay
          outside the package.
        </p>
        <pre>
          <code>{`mkdir local-signals.stillplugin
curl -fL https://meet-still.app/sdk/local-signals/manifest.json \\\n  -o local-signals.stillplugin/manifest.json
curl -fL https://meet-still.app/sdk/publish-sample.mjs \\\n  -o publish-sample.mjs
# After import and explicit Enable local source in Still:
node publish-sample.mjs "$HOME/Library/Application Support/Still/plugins/app.meet-still.local-signals" working`}</code>
        </pre>
      </section>
      {developerSections.map((section) => (
        <section key={section.title}>
          <h2>{section.title}</h2>
          <p>{section.text}</p>
        </section>
      ))}
      <Link className="button-primary" href="/plugins">
        Explore the native collection <span aria-hidden="true">↗</span>
      </Link>
    </main>
  );
}
