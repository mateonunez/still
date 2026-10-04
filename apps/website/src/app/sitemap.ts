import type { MetadataRoute } from 'next';
import { site } from '@/content/site';
export default function sitemap(): MetadataRoute.Sitemap {
  return ['/', '/how-it-works', '/download', '/privacy', '/support', '/changelog'].map((path) => ({
    url: `${site.origin}${path}`,
    lastModified: new Date('2026-10-04T00:00:00Z'),
  }));
}
