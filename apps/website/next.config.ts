import { resolve } from 'node:path';
import type { NextConfig } from 'next';

const config: NextConfig = {
  poweredByHeader: false,
  agentRules: false,
  turbopack: { root: resolve(import.meta.dirname, '../..') },
  async headers() {
    const base = [
      { key: 'X-Content-Type-Options', value: 'nosniff' },
      { key: 'Referrer-Policy', value: 'strict-origin-when-cross-origin' },
    ];
    if (process.env.VERCEL_ENV !== 'production' && process.env.STILL_INDEXABLE !== 'true') {
      base.push({ key: 'X-Robots-Tag', value: 'noindex, nofollow' });
    }
    return [
      { source: '/:path*', headers: base },
      { source: '/preview/:path*', headers: [{ key: 'X-Robots-Tag', value: 'noindex, nofollow' }] },
    ];
  },
};
export default config;
