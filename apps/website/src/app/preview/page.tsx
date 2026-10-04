import type { Metadata } from 'next';
import { notFound } from 'next/navigation';
import { DesignPreview } from '@/features/design-preview/preview';

export const dynamic = 'force-dynamic';
export const metadata: Metadata = {
  title: { absolute: 'Still — Template design preview' },
  robots: { index: false, follow: false },
};

export default function PreviewPage() {
  if (
    process.env.VERCEL_ENV === 'production' ||
    (process.env.NODE_ENV !== 'development' && process.env.STILL_DESIGN_PREVIEW !== 'true')
  ) {
    notFound();
  }
  return <DesignPreview />;
}
