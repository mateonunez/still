import type { Metadata } from 'next';

export const site = {
  name: 'Still',
  tagline: 'A little space to step away.',
  descriptor: 'A calm screen and keep-awake app for Mac.',
  origin: 'https://meet-still.app',
  description:
    'Cover your desktop. Keep your Mac awake. Make room for the details you choose. Still is a native Mac app with Porcelain and Glass themes and configurable widgets. Open source, with an experimental preview available.',
  indexable: process.env.VERCEL_ENV === 'production' || process.env.STILL_INDEXABLE === 'true',
};

export function pageMetadata(title: string, description: string, path: string): Metadata {
  const url = `${site.origin}${path}`;
  return {
    title: path === '/' ? { absolute: title } : title,
    description,
    alternates: { canonical: url },
    robots: { index: site.indexable, follow: site.indexable },
    openGraph: {
      type: 'website',
      title,
      description,
      url,
      siteName: site.name,
      locale: 'en_US',
      images: [
        {
          url: '/opengraph-image',
          width: 1200,
          height: 630,
          alt: `Still — ${site.tagline} ${site.descriptor}`,
        },
      ],
    },
    twitter: { card: 'summary_large_image', title, description, images: ['/opengraph-image'] },
  };
}
