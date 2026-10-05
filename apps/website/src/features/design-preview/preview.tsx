'use client';

import Image from 'next/image';
import { useEffect, useRef, useState } from 'react';
import { Mark } from '@/features/home/mark';
import './preview.css';
import { WidgetPrototype } from './widget-prototype';

type Theme = 'porcelain' | 'spectrum' | 'meadow';
type Appearance = 'light' | 'dark' | 'system';
type View = 'screen' | 'settings' | 'landing' | 'widgets';
const themes: Record<Theme, { name: string; greeting: string; description: string }> = {
  porcelain: {
    name: 'Porcelain',
    greeting: 'A little space to step away.',
    description: 'Warm porcelain. A touch of burgundy.',
  },
  spectrum: { name: 'Spectrum', greeting: 'Keep the momentum.', description: 'Luminous color. A quiet night.' },
  meadow: { name: 'Meadow', greeting: 'Let the day breathe.', description: 'Original landscapes. Open skies.' },
};

export function DesignPreview() {
  const [theme, setTheme] = useState<Theme>('porcelain');
  const [appearance, setAppearance] = useState<Appearance>('light');
  const [view, setView] = useState<View>('screen');
  const [systemDark, setSystemDark] = useState(false);
  const [ready, setReady] = useState(false);
  const [covered, setCovered] = useState(true);
  const [sharing, setSharing] = useState(false);
  const [autoCover, setAutoCover] = useState(false);
  const [idle, setIdle] = useState('5');
  const [notice, setNotice] = useState(false);
  const returnButton = useRef<HTMLButtonElement>(null);
  const coverButton = useRef<HTMLButtonElement>(null);
  const pendingFocus = useRef(false);
  const ClockHeading = covered ? 'h1' : 'div';
  const dark =
    theme === 'spectrum' ||
    (theme === 'porcelain' && (appearance === 'dark' || (appearance === 'system' && systemDark)));

  useEffect(() => {
    const params = new URLSearchParams(window.location.search);
    const selectedTheme = params.get('theme');
    const selectedAppearance = params.get('appearance');
    const selectedView = params.get('view');
    if (selectedTheme === 'porcelain' || selectedTheme === 'spectrum' || selectedTheme === 'meadow')
      setTheme(selectedTheme);
    if (selectedAppearance === 'light' || selectedAppearance === 'dark' || selectedAppearance === 'system')
      setAppearance(selectedAppearance);
    if (
      selectedView === 'screen' ||
      selectedView === 'settings' ||
      selectedView === 'landing' ||
      selectedView === 'widgets'
    )
      setView(selectedView);
    if (selectedView === 'widgets') setTheme('porcelain');
    const media = window.matchMedia('(prefers-color-scheme: dark)');
    const update = () => setSystemDark(media.matches);
    update();
    media.addEventListener('change', update);
    setReady(true);
    return () => media.removeEventListener('change', update);
  }, []);

  useEffect(() => {
    if (!ready) return;
    const url = new URL(window.location.href);
    url.searchParams.set('theme', theme);
    url.searchParams.set('appearance', appearance);
    url.searchParams.set('view', view);
    window.history.replaceState(null, '', url);
  }, [theme, appearance, view, ready]);

  useEffect(() => {
    if (!pendingFocus.current) return;
    (covered ? returnButton : coverButton).current?.focus();
    pendingFocus.current = false;
  }, [covered]);

  const simulateReturn = (value: boolean) => {
    pendingFocus.current = true;
    setCovered(value);
  };

  return (
    <div
      className={`design-preview ${theme} ${dark ? 'dark' : 'light'}`}
      data-theme={theme}
      data-appearance={dark ? 'dark' : 'light'}
    >
      <header className="preview-topbar">
        <div className="preview-brand">
          <Mark />
          <span>Still</span>
          <small>Template design preview</small>
        </div>
        <nav aria-label="Preview pages">
          {(['screen', 'widgets', 'settings', 'landing'] as const).map((item) => (
            <button
              key={item}
              type="button"
              aria-pressed={view === item}
              onClick={() => {
                setView(item);
                if (item === 'widgets') setTheme('porcelain');
              }}
            >
              {item === 'landing'
                ? 'Website'
                : item === 'screen'
                  ? 'Screen'
                  : item === 'widgets'
                    ? 'Customize'
                    : 'Settings'}
            </button>
          ))}
        </nav>
      </header>
      <main id="main" tabIndex={-1}>
        {view === 'widgets' && <WidgetPrototype />}
        {view === 'screen' && (
          <section className="preview-stage" aria-label="Ambient screen concept">
            {theme === 'spectrum' && <div className="preview-orb" aria-hidden="true" />}
            {theme === 'meadow' && (
              <Image className="preview-landscape" src="/previews/meadow.svg" alt="" fill priority />
            )}
            <div className="preview-screen-top">
              <span>Ambient curtain</span>
              <span>Visual simulation</span>
            </div>
            <div className="preview-clock" inert={!covered}>
              <p className="preview-date">Sunday, October 4</p>
              <ClockHeading className="preview-time">
                <time dateTime="16:42">16:42</time>
              </ClockHeading>
              <p className="preview-greeting">{themes[theme].greeting}</p>
              <p>Your desktop can wait.</p>
              <button
                type="button"
                ref={returnButton}
                className="preview-primary"
                onClick={() => simulateReturn(false)}
              >
                Preview return
              </button>
              <small>Touch ID / system authentication · simulated here</small>
            </div>
            <aside className="preview-activity" inert={!covered} aria-label="Sample activity">
              <p className="preview-eyebrow">Activity · sample data</p>
              <h2>3 apps open</h2>
              <p>
                Only what you choose to share.
                <br />
                No task progress is inferred.
              </p>
              <button
                type="button"
                aria-expanded={sharing}
                aria-controls="preview-app-list"
                onClick={() => setSharing(!sharing)}
              >
                {sharing ? 'Hide sample apps' : 'Show sample apps'}{' '}
                <span aria-hidden="true">{sharing ? '−' : '+'}</span>
              </button>
              <ul id="preview-app-list" hidden={!sharing}>
                {['Xcode', 'Terminal', 'Safari'].map((name) => (
                  <li key={name}>
                    <span>{name}</span>
                    <span>Open</span>
                  </li>
                ))}
              </ul>
            </aside>
            <div className="preview-annotation">
              <strong>{themes[theme].name}</strong>
              <p>{dark && theme === 'porcelain' ? 'Deep plum. Soft ivory.' : themes[theme].description}</p>
              <p>Visual privacy curtain · not the macOS system lock.</p>
            </div>
            {!covered && (
              <section className="preview-returned" aria-label="Simulated desktop return">
                <h1>Welcome back.</h1>
                <p>This is a simulated return. No authentication or system lock occurred.</p>
                <button
                  type="button"
                  ref={coverButton}
                  className="preview-primary"
                  onClick={() => simulateReturn(true)}
                >
                  Preview cover again
                </button>
              </section>
            )}
          </section>
        )}
        {view === 'settings' && (
          <section className="preview-settings" aria-label="Settings concept">
            <h1>Make it your pause.</h1>
            <p>Simple controls. Everything here is a visual simulation.</p>
            <h2>Automatic cover</h2>
            <div className="preview-group">
              <label className="preview-row">
                <span>
                  Cover when I step away<small>Activity alone never unlocks.</small>
                </span>
                <input type="checkbox" checked={autoCover} onChange={(event) => setAutoCover(event.target.checked)} />
              </label>
              <label className="preview-row">
                <span>After inactivity</span>
                <select value={idle} onChange={(event) => setIdle(event.target.value)}>
                  {['2', '5', '10', '15'].map((value) => (
                    <option key={value} value={value}>
                      {value} minutes
                    </option>
                  ))}
                </select>
              </label>
            </div>
            <h2>Activity privacy</h2>
            <div className="preview-group">
              <label className="preview-row">
                <span>
                  Show selected app names<small>Off by default. Sample identities only.</small>
                </span>
                <input type="checkbox" checked={sharing} onChange={(event) => setSharing(event.target.checked)} />
              </label>
            </div>
            <p>Still keeps your Mac awake while covered. Your display follows macOS settings.</p>
            <p>Return uses macOS-owned authentication in the native app. No password is collected here.</p>
          </section>
        )}
        {view === 'landing' && (
          <section className="preview-landing" aria-label="Website concept">
            <div className="preview-landing-grid">
              <div>
                <p className="preview-eyebrow">Native macOS utility · concept</p>
                <h1>
                  Step away.
                  <br />
                  Keep the momentum.
                </h1>
                <p>A calm screen for your Mac. A little room to breathe while your work continues.</p>
                <button type="button" className="preview-primary" onClick={() => setNotice(true)}>
                  Preview beta invitation
                </button>
                <small>In development. Compatibility and pricing pending.</small>
                {notice && <p role="status">Concept only. No enrollment is open and no personal data is collected.</p>}
              </div>
              <div className="preview-mini">
                <p>Sunday, October 4</p>
                <time dateTime="16:42">16:42</time>
                <p>Your desktop can wait.</p>
              </div>
            </div>
            <div className="preview-benefits">
              <article>
                <h2>A beautiful pause.</h2>
                <p>Porcelain in light and dark. A warm palette and a quiet clock.</p>
              </article>
              <article>
                <h2>On your terms.</h2>
                <p>Choose when your screen appears, then return with system authentication.</p>
              </article>
              <article>
                <h2>Share less.</h2>
                <p>Optional activity stays hidden until you choose what to show.</p>
              </article>
            </div>
            <p>This is an illustrative website concept. Still does not replace the macOS security lock.</p>
          </section>
        )}
      </main>
      <div className="preview-selector">
        <nav aria-label="Visual directions" hidden={view === 'widgets'}>
          {(Object.keys(themes) as Theme[]).map((item) => (
            <button key={item} type="button" aria-pressed={theme === item} onClick={() => setTheme(item)}>
              {themes[item].name}
            </button>
          ))}
        </nav>
        {theme === 'porcelain' && (
          <fieldset>
            <legend>Appearance</legend>
            {(['light', 'dark', 'system'] as const).map((item) => (
              <button key={item} type="button" aria-pressed={appearance === item} onClick={() => setAppearance(item)}>
                {item[0].toUpperCase() + item.slice(1)}
              </button>
            ))}
          </fieldset>
        )}
      </div>
      <p className="preview-status" role="status">
        Concept · {theme} / {view} · {dark ? 'dark' : 'light'} · {covered ? 'covered' : 'returned'} · auto{' '}
        {autoCover ? `${idle}m` : 'off'} · activity {sharing ? 'apps' : 'counts'}
      </p>
    </div>
  );
}
