import { readFile } from 'node:fs/promises';
import { join } from 'node:path';
import { ImageResponse } from 'next/og';

export const alt = 'Still — A little space to step away. A native privacy screen for Mac.';
export const size = { width: 1200, height: 630 };
export const contentType = 'image/png';
export default async function Image() {
  const font = await readFile(join(process.cwd(), 'public/fonts/InstrumentSerif-Regular.ttf'));
  return new ImageResponse(
    <div
      style={{
        display: 'flex',
        width: '100%',
        height: '100%',
        background: '#20171B',
        color: '#F3E9E6',
        padding: '64px 80px',
        flexDirection: 'column',
        justifyContent: 'space-between',
      }}
    >
      <div style={{ display: 'flex', fontSize: 48, color: '#D9A8B8' }}>Still.</div>
      <div
        style={{
          display: 'flex',
          flexDirection: 'column',
          fontFamily: 'Instrument Serif',
          fontSize: 100,
          lineHeight: 1,
        }}
      >
        <span>A little space</span>
        <span>to step away.</span>
      </div>
      <div style={{ display: 'flex', justifyContent: 'space-between', fontSize: 22, color: '#C5B0B8' }}>
        <span>A calm screen for a working Mac.</span>
        <span>meet-still.app</span>
      </div>
    </div>,
    { ...size, fonts: [{ name: 'Instrument Serif', data: font, style: 'normal', weight: 400 }] },
  );
}
