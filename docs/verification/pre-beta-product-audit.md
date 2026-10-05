# Pre-beta product audit

Date: 2026-10-05. Development artifacts only; no signed/notarized beta.

## Changes and evidence

- Fresh profiles now prepare all ten built-in configurations, disabled and hidden. Existing files are preserved; symbolic-link roots are rejected. Two host regression cases failed before the fix and passed afterward.
- One content display now follows the macOS main display ID. Clock, widgets and embedded authentication appear there; other screens receive opaque minimal covers. Main-display changes invalidate the topology gate. Selection/fallback tests pass; physical multi-monitor acceptance remains open.
- Final candidate: `out/Still.app`; executable SHA-256 `a7eb5db53e078626f2e8f88d06d919daa6281d26f7a21153761b581c0f645d62`. Light/dark primary and secondary view exports were generated; secondary dark was inspected. These exports do not prove live coverage or material rendering.
- 83 domain/host/Node tests passed: SessionKit 34, StillWidgets 16, StillPluginKit 8, StillNativePlugins 12, macOS host 9, task CLI 4. Brand contrast: 26 checks.
- Agent bridge: 10 checks across 15 synthetic invocations. Native energy: 17 lifecycle checks. Neither proves physical gesture coverage or one-hour display behavior.
- Native collection probe: 16/17 checks passed. Build Watch remained unavailable. Exact `gh api` request timed out; HTTPS to api.github.com failed DNS resolution after ten seconds. No network settings were changed.
- Provider/energy receipts refer to earlier executable `d08032f288ad98ad0b563e1ed685b85742a25ce9b16a74bdc730be9f0e10f199`, before final error-copy and render-export changes. Do not attribute them to the final executable.
- Build guard rejects replacement of a running candidate. The interactive Still-preview process was preserved; no curtain runtime probe was launched over it.

## Native collection

| Plugin | Evidence | Remaining acceptance |
| --- | --- | --- |
| Agents | Two installed clients discovered; real quota observed; bounded bridge tested synthetically | Live client hook trust/reload, parallel attention and disconnect |
| Build Watch | Bounded unavailable state | Retry GitHub after DNS recovery |
| Deploy Watch | Real configured source ready | Fresh authentication and revocation |
| Task Watch | Real registered command completed; concurrent CLI tests pass | Longer live workload |
| Mac Pulse | Native resource facts ready | Sustained resource overhead |
| Next Up | Explicit permission-required state | Real Calendar grant, selection and revocation |
| World Clock | Three real time zones ready | Physical layout/readability |
| Quiet Timer | Start/stop tested | Full-duration interactive expiry |
| Weather | Configured provider ready | Commercial provider terms before commercial distribution |
| Spotify | Real transport ready; interactive app connection reported working | Fresh-install grant/revocation |

## Website and developer delivery

Eighteen HTML routes build and pass metadata/canonical/sitemap checks. Catalog details describe configuration, permissions and unavailable app delivery. Five SDK assets match canonical workspace files; schema IDs resolve; JSON catalog and human/agent guides share typed content. Native v2 modules and declarative v1 metadata packages are distinct contracts. Custom canvas currently arranges native modules only.

Headless mobile axe audits: catalog, developer guide and Spotify detail have zero violations. Home has zero violations and one incomplete decorative-arrow contrast check; manual visual review is still necessary. A developer code block scrolling/focus issue was fixed by wrapping long lines. Catalog desktop visual and mobile width/navigation checks passed. Build, TypeScript, Biome and an owned production-server verifier passed. Local verification is not production delivery or search indexing proof.

## Release blockers

Physical activation-time swipes and password-dialog exposure remain unresolved. The reported one-hour screensaver incident has no verified endurance fix. Test the final candidate with real multi-monitor topology changes, Touch ID/password retry, VoiceOver, material accessibility and AC/battery idle timing. Calendar consent and clean-Mac installation remain open. Choose a verified compatibility matrix, release identity and license before the final signing/notarization step.

Updates remain manual for the first verified distribution. No public artifact, Homebrew package, automatic updater, community submission service, accounts or payments is advertised.
