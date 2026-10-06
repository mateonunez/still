import type { MetadataRoute } from 'next';
import { site } from '@/content/site';
import { plugins } from '@/features/plugins/catalog';
export default function sitemap(): MetadataRoute.Sitemap {
  return [
    '/',
    '/how-it-works',
    '/download',
    '/privacy',
    '/support',
    '/changelog',
    '/plugins',
    '/developers',
    '/license',
    ...plugins.map((plugin) => `/plugins/${plugin.slug}`),
  ].map((path) => ({
    url: `${site.origin}${path}`,
    lastModified: new Date(
      [
        '/',
        '/how-it-works',
        '/download',
        '/support',
        '/license',
        '/changelog',
        '/developers',
        '/plugins/agents',
      ].includes(path)
        ? '2026-10-06T00:00:00Z'
        : '2026-10-05T00:00:00Z',
    ),
  }));
}
