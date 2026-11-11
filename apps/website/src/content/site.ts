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

/** The home page showcase video, shared by its markup, share metadata, structured data and sitemap. */
export const showcase = {
  title: 'Still — A little space to step away',
  description:
    'A 16-second silent showcase of the Still native editor in Porcelain and Glass, light and dark. Native SwiftUI view exports from the development build.',
  url: '/media/still-showcase.mp4',
  poster: '/media/editor-glass-dark.png',
  width: 1280,
  height: 800,
  duration: 16,
  uploadDate: '2026-10-07T09:41:45+02:00',
};

export function pageMetadata(title: string, description: string, path: string): Metadata {
  const url = `${site.origin}${path}`;
  const imageAlt = `Still — ${site.tagline} ${site.descriptor}`;
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
          alt: imageAlt,
        },
      ],
    },
    twitter: { card: 'summary_large_image', title, description, images: [{ url: '/opengraph-image', alt: imageAlt }] },
  };
}
