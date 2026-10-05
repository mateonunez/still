import type { Metadata } from 'next';

export const site = {
  name: 'Still',
  origin: 'https://meet-still.app',
  description:
    'A calm privacy screen for your Mac. Meet Still: a native macOS app with Porcelain light and dark themes, system authentication, a customizable canvas and ten optional native plugins.',
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
          alt: 'Still — A little space to step away. A native privacy screen for Mac.',
        },
      ],
    },
    twitter: { card: 'summary_large_image', title, description, images: ['/opengraph-image'] },
  };
}
