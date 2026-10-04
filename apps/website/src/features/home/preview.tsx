'use client';

import { useState } from 'react';
import { Mark } from './mark';

export function Preview() {
  const [appearance, setAppearance] = useState<'light' | 'dark'>('dark');
  return (
    <section className="preview-section" id="preview" aria-label="Porcelain design preview">
      <div className="preview-top">
        <span className="eyebrow">PORCELAIN, BY STILL</span>
        <fieldset className="appearance-picker" aria-label="Preview appearance">
          {(['light', 'dark'] as const).map((mode) => (
            <button type="button" key={mode} aria-pressed={appearance === mode} onClick={() => setAppearance(mode)}>
              {mode === 'light' ? 'Light' : 'Dark'}
            </button>
          ))}
        </fieldset>
      </div>
      <div className="screen" data-appearance={appearance}>
        <div className="screen-brand">
          <Mark />
          <span>Still</span>
          <span className="screen-theme">PORCELAIN</span>
        </div>
        <div className="screen-time">
          <p>SUNDAY, OCTOBER 4</p>
          <span>20:24</span>
          <h2>A little space to step away.</h2>
        </div>
        <div className="screen-return">
          <svg aria-hidden="true" viewBox="0 0 32 32" fill="none">
            <path
              d="M7 23c2-5-1-11 3-15 5-5 14-1 13 6m-17 3C3 5 16-2 24 6m-13 20c4-6 0-11 3-14 3-3 6 0 5 4-1 5 2 9-1 14m-3-15c-2 4 3 9-1 15m9-12c0 5 1 8-2 11"
              stroke="currentColor"
              strokeWidth="1.4"
              strokeLinecap="round"
            />
          </svg>
          <p>Touch ID or your Mac password</p>
        </div>
        <div className="screen-edge">YOUR DESKTOP CAN WAIT.</div>
      </div>
      <p className="preview-caption">An interactive design preview. Native app in development.</p>
    </section>
  );
}
