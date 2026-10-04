import type { MetadataRoute } from 'next';
import { site } from '@/content/site';
export default function robots(): MetadataRoute.Robots {
  return {
    // Allow crawlers to read noindex headers/meta on accessible previews.
    rules: { userAgent: '*', allow: '/' },
    ...(site.indexable ? { sitemap: `${site.origin}/sitemap.xml`, host: site.origin } : {}),
  };
}
