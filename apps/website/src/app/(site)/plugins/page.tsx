import Link from 'next/link';
import { pageMetadata, site } from '@/content/site';
import { plugins } from '@/features/plugins/catalog';

export const metadata = pageMetadata(
  'Plugins for your quiet screen',
  'Explore ten configurable Still plugins for agents, builds, deployments, music, calendars and your Mac. A native collection, with explicit source access.',
  '/plugins',
);
export default function PluginsPage() {
  const list = {
    '@context': 'https://schema.org',
    '@type': 'ItemList',
    name: 'Still native plugin collection',
    itemListElement: plugins.map((plugin, index) => ({
      '@type': 'ListItem',
      position: index + 1,
      name: plugin.name,
      url: `${site.origin}/plugins/${plugin.slug}`,
    })),
  };
  return (
    <main id="main" className="catalog-page">
      <script type="application/ld+json">{JSON.stringify(list).replace(/</g, '\\u003c')}</script>
      <p className="eyebrow">THE MATEONUNEZ COLLECTION · NATIVE · CONFIGURABLE</p>
      <h1>
        A little more <em>of your world.</em>
      </h1>
      <p className="catalog-lead">
        Ten small windows into what matters. Choose your sources, keep the details you want, and make room for quiet.
      </p>
      <div className="catalog-notice">
        <p>
          Built into the development app. Every plugin starts disabled; access and visibility are your choices. Show up
          to four widgets alongside your clock.
        </p>
        <Link href="/download">Availability ↗</Link>
      </div>
      <div className="plugin-grid">
        {plugins.map((plugin) => (
          <article className="plugin-tile" key={plugin.id}>
            <span className="eyebrow">
              {plugin.category} · {plugin.publisher}
            </span>
            <h2>
              <Link className="plugin-title" href={`/plugins/${plugin.slug}`}>
                {plugin.name}
                <span aria-hidden="true"> ↗</span>
              </Link>
            </h2>
            <p>{plugin.summary}</p>
            <span className="plugin-kind">Native · Configurable</span>
          </article>
        ))}
      </div>
      <section className="catalog-community">
        <p className="eyebrow">A FOUNDATION FOR WHAT COMES NEXT</p>
        <h2>Small plugins. A clear contract.</h2>
        <p>
          Build a local metadata source or Porcelain template with the declarative SDK. The catalog is the first step
          toward a marketplace; community publishing, accounts and payments are not available yet.
        </p>
        <Link className="button-primary" href="/developers">
          Build for Still <span aria-hidden="true">↗</span>
        </Link>
      </section>
    </main>
  );
}
