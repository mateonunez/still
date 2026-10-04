# Plugin and Codex planning evidence

2026-10-04. Status: proposed architecture and source research; no plugin runtime or live integration implemented.

## Scope and evidence

- Roadmap now places reusable widgets/plugins and the first Codex adapter before beta and distribution. Existing desktop coverage, authentication and inactivity work remains earlier.
- The proposal separates data adapters, native widgets, declarative templates and marketplace distribution. Community authoring starts with a versioned contract, fixtures, validation and local import; hosted marketplace operations remain later scope.
- CodexBar source research is pinned to v0.71.1 / c04fc93f91f17984d9dff93a556e553e750f2c1c. A public CodexBar plugin format exists; Still interoperability is not proven by its existence.
- The installed Codex CLI version and read-only generated protocol schemas were inspected. No authenticated usage request, client attachment, hook installation or approval action was performed.
- Usage is account quota, not session progress. Lifecycle/attention sources require separate proof; an independently spawned app-server does not establish observation of another client's sessions.
- Whitespace and relative Markdown link checks passed. No application code changed, so no additional application tests were needed for this planning change.

## Remaining decisions and next proof

Review actual Porcelain light/dark UI prototypes for the curtain card and compact customization hub before implementation. Select initial card families, source integration and community template scope. Resource ceilings and runner isolation are proposed, unmeasured constraints.

Then agree on a minimal versioned metadata envelope and validate one fixture-to-card path. A live opt-in usage spike must demonstrate units, identity, missing/stale/error states and bounded cleanup before reporting Codex connected. Lifecycle and approval awareness must prove the intended original client independently. In-app execution of approvals is outside the first integration scope.

See [proposal](../plugins-and-widgets.md), [source research](../research/codex-plugin-2026.md), [preview guide](../guides/widgets-and-plugins.md) and [roadmap](../roadmap.md).
