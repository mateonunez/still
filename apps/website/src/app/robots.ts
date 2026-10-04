import type { MetadataRoute } from 'next';
import { site } from '@/content/site';
export default function robots(): MetadataRoute.Robots {
  return {
    rules: { userAgent: '*', ...(site.indexable ? { allow: '/' } : { disallow: '/' }) },
    ...(site.indexable ? { sitemap: `${site.origin}/sitemap.xml`, host: site.origin } : {}),
  };
}
