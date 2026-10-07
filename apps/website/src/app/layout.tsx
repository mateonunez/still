import type { Metadata, Viewport } from 'next';
import localFont from 'next/font/local';
import { site } from '@/content/site';
import { WebsiteAnalytics } from '@/features/analytics/website-analytics';
import './globals.css';

const display = localFont({
  src: '../../public/fonts/InstrumentSerif-Regular.woff2',
  variable: '--font-display',
  display: 'swap',
});
const inter = localFont({ src: '../../public/fonts/InterVariable.woff2', variable: '--font-ui', display: 'swap' });
export const metadata: Metadata = {
  metadataBase: new URL(site.origin),
  title: { default: 'Still — A calm screen and keep-awake app for Mac', template: '%s · Still' },
  description: site.description,
  applicationName: 'Still',
};
export const viewport: Viewport = { themeColor: '#F4EFEB', colorScheme: 'light' };

export default function Layout({ children }: Readonly<{ children: React.ReactNode }>) {
  return (
    <html lang="en" className={`${display.variable} ${inter.variable}`}>
      <body>
        <a className="skip-link" href="#main">
          Skip to content
        </a>
        {children}
        {process.env.VERCEL_ENV === 'production' && <WebsiteAnalytics />}
      </body>
    </html>
  );
}
