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
    ...plugins.map((plugin) => `/plugins/${plugin.slug}`),
  ].map((path) => ({
    url: `${site.origin}${path}`,
    lastModified: new Date('2026-10-05T00:00:00Z'),
  }));
}
