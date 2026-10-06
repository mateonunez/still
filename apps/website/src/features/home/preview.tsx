'use client';

import { useState } from 'react';
import { site } from '@/content/site';
import { Mark } from './mark';

export function Preview() {
  const [appearance, setAppearance] = useState<'light' | 'dark'>('dark');
  const [theme, setTheme] = useState<'porcelain' | 'glass'>('porcelain');
  return (
    <section className="preview-section" id="preview" aria-label="Still theme illustration">
      <div className="preview-top">
        <fieldset className="appearance-picker" aria-label="Preview theme">
          {(['porcelain', 'glass'] as const).map((value) => (
            <button type="button" key={value} aria-pressed={theme === value} onClick={() => setTheme(value)}>
              {value === 'porcelain' ? 'Porcelain' : 'Glass'}
            </button>
          ))}
        </fieldset>
        <fieldset className="appearance-picker" aria-label="Preview appearance">
          {(['light', 'dark'] as const).map((mode) => (
            <button type="button" key={mode} aria-pressed={appearance === mode} onClick={() => setAppearance(mode)}>
              {mode === 'light' ? 'Light' : 'Dark'}
            </button>
          ))}
        </fieldset>
      </div>
      <div className="screen" data-theme={theme} data-appearance={appearance}>
        <div className="screen-brand">
          <Mark />
          <span>Still</span>
          <span className="screen-theme">{theme.toUpperCase()}</span>
        </div>
        <aside className="screen-widgets" aria-label="Sample widgets">
          <div className="screen-widget">
            <div className="screen-widget-heading">
              <strong>Agents</strong>
              <span>Sample</span>
            </div>
            <p>Codex · Weekly quota 42%</p>
            <p>Claude · Activity observed</p>
          </div>
          <div className="screen-widget">
            <div className="screen-widget-heading">
              <strong>World Clock</strong>
              <span>Sample</span>
            </div>
            <p>
              Milan <span>20:24</span>
            </p>
            <p>
              New York <span>14:24</span>
            </p>
          </div>
        </aside>
        <div className="screen-time">
          <p>SUNDAY, OCTOBER 4</p>
          <span>20:24</span>
          <p className="screen-message">{site.tagline}</p>
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
      <p className="preview-caption" aria-live="polite">
        {theme === 'glass' ? 'Glass: soft light and native materials.' : 'Porcelain: warm tones and quiet typography.'}{' '}
        A web illustration with sample widgets, not a native screenshot. App in development.
      </p>
    </section>
  );
}
