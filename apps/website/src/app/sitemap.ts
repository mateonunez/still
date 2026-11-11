import type { MetadataRoute } from 'next';
import { showcase, site } from '@/content/site';
import { plugins } from '@/features/plugins/catalog';
export default function sitemap(): MetadataRoute.Sitemap {
  return [
    '/',
    '/how-it-works',
    '/download',
    '/start',
    '/privacy',
    '/support',
    '/changelog',
    '/plugins',
    '/developers',
    '/license',
    ...plugins.map((plugin) => `/plugins/${plugin.slug}`),
  ].map((path) => ({
    url: `${site.origin}${path}`,
    // No lastModified: deployments carry no Git history, and a hand-kept date goes stale silently.
    ...(path === '/'
      ? {
          videos: [
            {
              title: showcase.title,
              description: showcase.description,
              thumbnail_loc: `${site.origin}${showcase.poster}`,
              content_loc: `${site.origin}${showcase.url}`,
              duration: showcase.duration,
              publication_date: showcase.uploadDate,
            },
          ],
        }
      : {}),
  }));
}
