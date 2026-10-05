'use client';

import { useEffect, useRef, useState } from 'react';
import { Mark } from '@/features/home/mark';
import './widget-prototype.css';

type Layout = 'corner' | 'rail';
type Provider = 'codex' | 'claude';
const providers = {
  codex: { name: 'Codex', mark: '⌘', used: 64, weekly: 28, reset: '1h 20m' },
  claude: { name: 'Claude', mark: '✳', used: 42, weekly: 18, reset: '2h 10m' },
} satisfies Record<Provider, { name: string; mark: string; used: number; weekly: number; reset: string }>;
type SourceState = 'ready' | 'attention' | 'stale' | 'disconnected';
const sourceLabels: Record<SourceState, string> = {
  ready: 'Up to date',
  attention: 'Needs attention',
  stale: 'Out of date',
  disconnected: 'Not connected',
};

/** Disposable visual prototype. No provider access, credentials or persistence. */
export function WidgetPrototype() {
  const [surface, setSurface] = useState<'hub' | 'curtain'>('hub');
  const [layout, setLayout] = useState<Layout>('corner');
  const [enabled, setEnabled] = useState<Record<Provider, boolean>>({ codex: false, claude: false });
  const [selectedProvider, setSelectedProvider] = useState<Provider>('codex');
  const [sources, setSources] = useState<Record<Provider, SourceState>>({ codex: 'ready', claude: 'ready' });
  const source = sources[selectedProvider];
  const activeProviders = (Object.keys(providers) as Provider[]).filter((provider) => enabled[provider]);
  const [labels, setLabels] = useState(false);
  const [ready, setReady] = useState(false);
  const surfaceFocus = useRef<Partial<Record<'hub' | 'curtain', HTMLButtonElement | null>>>({});
  const pendingFocus = useRef(false);
  const changeSurface = (value: 'hub' | 'curtain') => {
    pendingFocus.current = true;
    setSurface(value);
  };
  useEffect(() => {
    if (pendingFocus.current) {
      surfaceFocus.current[surface]?.focus();
      pendingFocus.current = false;
    }
  }, [surface]);
  useEffect(() => {
    const params = new URLSearchParams(window.location.search);
    if (params.get('layout') === 'rail') setLayout('rail');
    if (params.get('surface') === 'curtain') setSurface('curtain');
    setReady(true);
  }, []);
  useEffect(() => {
    if (!ready) return;
    const url = new URL(window.location.href);
    url.searchParams.set('layout', layout);
    url.searchParams.set('surface', surface);
    window.history.replaceState(null, '', url);
  }, [layout, surface, ready]);

  const card = (provider: Provider, mini = false) => {
    const info = providers[provider];
    const source = sources[provider];
    return (
      <aside
        className={`widget-card ${mini ? 'mini' : ''}`}
        key={provider}
        aria-label={`${info.name} demonstration widget`}
      >
        <div className="widget-card-heading">
          <span className="widget-provider-mark" aria-hidden="true">
            {info.mark}
          </span>
          <span>{info.name}</span>
          <span className="widget-demo">Demo</span>
        </div>
        {labels && <p className="widget-account">Personal workspace · fictional label</p>}
        {source === 'ready' && (
          <>
            <div className="widget-metric">
              <strong>
                {info.used}
                <span>%</span>
              </strong>
              <span>5-hour quota used</span>
            </div>
            <meter min={0} max={100} value={info.used} aria-label={`${info.name} demo five-hour quota used`}>
              {info.used}%
            </meter>
            <div className="widget-detail">
              <span>Resets in {info.reset}</span>
              <span>Updated 2m ago</span>
            </div>
            <div className="widget-week">
              <span>Weekly quota</span>
              <strong>{info.weekly}% used</strong>
            </div>
          </>
        )}
        {source === 'attention' && (
          <>
            <p className="widget-state-title">A little attention.</p>
            <p>1 approval request</p>
            <p className="widget-card-note">Review it in the original client after returning.</p>
          </>
        )}
        {source === 'stale' && (
          <>
            <p className="widget-state-title">Waiting for an update.</p>
            <p className="widget-card-note">Last received 12m ago. Current quota is unavailable.</p>
          </>
        )}
        {source === 'disconnected' && (
          <>
            <p className="widget-state-title">Not connected.</p>
            <p className="widget-card-note">Connect a source from the Hub when you return.</p>
          </>
        )}
        <footer>
          {sourceLabels[source]} · {source === 'attention' ? 'Illustrative capability' : 'Sample metadata only'}
        </footer>
      </aside>
    );
  };

  const curtain = (mini = false) => (
    <div className={`widget-curtain ${layout} ${mini ? 'mini' : ''} ${activeProviders.length === 2 ? 'has-two' : ''}`}>
      <div className="widget-curtain-brand">
        <Mark />
        <span>Still</span>
        <small>PORCELAIN</small>
      </div>
      <div className="widget-clock">
        <p>MONDAY, OCTOBER 5</p>
        <div>16:42</div>
        <span>A little space to step away.</span>
      </div>
      {activeProviders.length > 0 && (
        <div className="widget-stack">{activeProviders.map((provider) => card(provider, mini))}</div>
      )}
      {!mini && (
        <div className="widget-return">
          <span aria-hidden="true">◎</span>
          <button type="button" onClick={() => changeSurface('hub')}>
            Preview return to Hub
          </button>
          <small>System authentication simulated · Mac stays awake in the native app</small>
        </div>
      )}
      <span className="widget-curtain-footnote">
        {mini ? 'Sample preview' : 'Visual privacy · not the macOS security lock'}
      </span>
    </div>
  );

  return (
    <section className="widget-prototype" aria-label="Customization design prototype">
      <div className="widget-toolbar">
        <div>
          <p className="preview-eyebrow">CUSTOMIZATION · DESIGN PROTOTYPE</p>
          <h1>{surface === 'hub' ? 'Your kind of quiet.' : 'A pause, with perspective.'}</h1>
        </div>
        <fieldset className="widget-segment" aria-label="Prototype surface">
          {(['hub', 'curtain'] as const).map((value) => (
            <button
              type="button"
              key={value}
              ref={(element) => {
                surfaceFocus.current[value] = element;
              }}
              aria-pressed={surface === value}
              onClick={() => changeSurface(value)}
            >
              {value === 'hub' ? 'Hub' : 'Curtain'}
            </button>
          ))}
        </fieldset>
      </div>
      {surface === 'hub' ? (
        <div className="widget-hub">
          <aside className="widget-hub-sidebar">
            <Mark />
            <p>Your Still</p>
            <a href="#widget-layout">Composition</a>
            <a href="#widget-library">Widgets</a>
            <a href="#widget-source">Sources & privacy</a>
            <small>
              Local design preview
              <br />
              Nothing is connected.
            </small>
          </aside>
          <div className="widget-hub-content">
            <div className="widget-section-heading">
              <div>
                <h2>Make room for what matters.</h2>
                <p>One calm screen. Only the details you choose.</p>
              </div>
              <span className="widget-theme-label">Porcelain</span>
            </div>
            {curtain(true)}
            <section id="widget-layout" className="widget-control-section">
              <div className="widget-section-heading">
                <h3>Composition</h3>
                <span>Clock always stays visible</span>
              </div>
              <div className="widget-layout-options">
                {(['corner', 'rail'] as const).map((value) => (
                  <button type="button" key={value} aria-pressed={layout === value} onClick={() => setLayout(value)}>
                    <span className={`widget-layout-icon ${value}`} aria-hidden="true">
                      <i />
                      <b />
                    </span>
                    <strong>{value === 'corner' ? 'Quiet corner' : 'Side rail'}</strong>
                    <small>
                      {value === 'corner' ? 'A small detail, off to the side.' : 'A dedicated space for context.'}
                    </small>
                  </button>
                ))}
              </div>
            </section>
            <section id="widget-library" className="widget-control-section">
              <div className="widget-section-heading">
                <h3>Widgets</h3>
                <span>{activeProviders.length > 0 ? `${activeProviders.length} of 4 slots used` : 'Clock only'}</span>
              </div>
              {(Object.keys(providers) as Provider[]).map((provider) => (
                <div className="widget-library-card" key={provider}>
                  <span className="widget-provider-mark" aria-hidden="true">
                    {providers[provider].mark}
                  </span>
                  <div>
                    <h4>{providers[provider].name}</h4>
                    <p>Quota windows, resets and source freshness.</p>
                    <small>First-party concept · no conversations</small>
                  </div>
                  <button
                    type="button"
                    className="widget-action"
                    aria-pressed={enabled[provider]}
                    onClick={() => setEnabled((current) => ({ ...current, [provider]: !current[provider] }))}
                  >
                    {enabled[provider] ? 'Remove' : 'Add'} {providers[provider].name} widget
                  </button>
                </div>
              ))}
            </section>
            <section id="widget-source" className="widget-control-section">
              <div className="widget-section-heading">
                <h3>Sources & privacy</h3>
                <span className="widget-demo">Demonstration</span>
              </div>
              <label className="widget-provider-picker">
                Source preview
                <select value={selectedProvider} onChange={(e) => setSelectedProvider(e.target.value as Provider)}>
                  {(Object.keys(providers) as Provider[]).map((provider) => (
                    <option key={provider} value={provider}>
                      {providers[provider].name}
                    </option>
                  ))}
                </select>
              </label>
              <div className="widget-source-grid">
                <label>
                  Sample source state
                  <select
                    value={source}
                    onChange={(e) =>
                      setSources((current) => ({ ...current, [selectedProvider]: e.target.value as SourceState }))
                    }
                  >
                    {(Object.keys(sourceLabels) as SourceState[]).map((value) => (
                      <option value={value} key={value}>
                        {sourceLabels[value]}
                      </option>
                    ))}
                  </select>
                </label>
                <label className="widget-label-toggle">
                  <span>
                    Show account label<small>Off by default. Fictional identity only.</small>
                  </span>
                  <input type="checkbox" checked={labels} onChange={(e) => setLabels(e.target.checked)} />
                </label>
              </div>
              <p className="widget-source-note">
                No live data or permissions. Approval awareness is an illustrative state; support in the original agent
                clients still needs verification.
              </p>
            </section>
            <div className="widget-hub-footer">
              <button
                type="button"
                onClick={() => {
                  setEnabled({ codex: false, claude: false });
                  setLabels(false);
                  setLayout('corner');
                  setSources({ codex: 'ready', claude: 'ready' });
                  setSelectedProvider('codex');
                }}
              >
                Reset to clock only
              </button>
              <button type="button" className="widget-action" onClick={() => changeSurface('curtain')}>
                Preview curtain <span aria-hidden="true">↗</span>
              </button>
            </div>
          </div>
        </div>
      ) : (
        curtain()
      )}
      <p className="widget-state-summary" role="status">
        Demo · {layout === 'corner' ? 'Quiet corner' : 'Side rail'} ·{' '}
        {activeProviders.length
          ? activeProviders
              .map((provider) => `${providers[provider].name} on · ${sourceLabels[sources[provider]]}`)
              .join(' · ')
          : 'Clock only'}{' '}
        · labels {labels ? 'shown' : 'hidden'} · settings reset when this preview closes
      </p>
    </section>
  );
}
