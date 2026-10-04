import type { Metadata, Viewport } from 'next';
import localFont from 'next/font/local';
import { site } from '@/content/site';
import './globals.css';

const display = localFont({
  src: '../../public/fonts/InstrumentSerif-Regular.woff2',
  variable: '--font-display',
  display: 'swap',
});
const inter = localFont({ src: '../../public/fonts/InterVariable.woff2', variable: '--font-ui', display: 'swap' });
export const metadata: Metadata = {
  metadataBase: new URL(site.origin),
  title: { default: 'Still — A calm privacy screen for Mac', template: '%s · Still' },
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
      </body>
    </html>
  );
}
