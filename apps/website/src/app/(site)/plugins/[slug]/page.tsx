import Link from 'next/link';
import { notFound } from 'next/navigation';
import { pageMetadata } from '@/content/site';
import { plugins } from '@/features/plugins/catalog';

type Props = { params: Promise<{ slug: string }> };
export const dynamicParams = false;
export function generateStaticParams() {
  return plugins.map(({ slug }) => ({ slug }));
}
export async function generateMetadata({ params }: Props) {
  const { slug } = await params;
  const plugin = plugins.find((item) => item.slug === slug);
  if (!plugin) notFound();
  return pageMetadata(`${plugin.name} plugin for Still`, plugin.summary, `/plugins/${slug}`);
}
export default async function PluginPage({ params }: Props) {
  const { slug } = await params;
  const plugin = plugins.find((item) => item.slug === slug);
  if (!plugin) notFound();
  return (
    <main id="main" className="article plugin-detail">
      <Link className="text-link" href="/plugins">
        ← All plugins
      </Link>
      <p className="eyebrow">
        {plugin.publisher} · NATIVE COLLECTION · {plugin.version}
      </p>
      <h1>{plugin.name}</h1>
      <p className="article-lead">{plugin.summary}</p>
      <dl className="plugin-facts">
        <div>
          <dt>Source</dt>
          <dd>{plugin.source}</dd>
        </div>
        <div>
          <dt>Availability</dt>
          <dd>Built into the development app. Disabled until you enable it.</dd>
        </div>
        <div>
          <dt>Configuration</dt>
          <dd>Settings → Plugins → Configure {plugin.name}</dd>
        </div>
      </dl>
      <section>
        <h2>Make it yours.</h2>
        <p>{plugin.setup}</p>
      </section>
      <section>
        <h2>Only the details you choose.</h2>
        <p>{plugin.privacy}</p>
      </section>
      <section>
        <h2>A place on your screen.</h2>
        <p>
          Enable the source, choose Show on curtain, then open Edit screen to move and resize the widget. Four optional
          widgets share the screen with the host-owned clock and return controls. A theme never grants source access.
        </p>
      </section>
      <Link className="button-primary" href="/download">
        Development availability <span aria-hidden="true">↗</span>
      </Link>
    </main>
  );
}
