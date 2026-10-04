# Widgets and plugins — preview guide

Status: design proposal. The app does not yet offer plugin installation, a widget hub or a Codex connection. No install command or marketplace is available.

## Proposed experience

1. Open the native customization hub after returning to Still.
2. Select a Porcelain light/dark/system template and preview its layout.
3. Add a compact Codex widget to an approved slot; other widgets remain optional.
4. Enable its source explicitly and choose disclosure. Counts are the proposed default; account/project labels require a separate choice.
5. Preview healthy, unavailable, disconnected, stale and attention states before covering the screen. Example data is always labeled.

A template changes layout and appearance; it does not connect a source or grant permissions. A plugin supplies typed data; Still renders the widget and owns authentication. Approvals remain in the original agent client. Unavailable data must appear unavailable rather than showing fictional progress or healthy zero counts.

## Review before implementation

- Is the clock-only default still calm, with widgets clearly optional?
- Does the light/dark Codex card remain readable at a glance on large and secondary displays?
- Can source settings, disclosure and reset be understood without reading technical documentation?
- Can usage percentages be distinguished from task progress, with their time window and freshness visible?
- Does adding a template preserve the return controls and accessibility behavior?

See [design and protocol proposal](../plugins-and-widgets.md), [Codex source research](../research/codex-plugin-2026.md) and [roadmap](../roadmap.md).
