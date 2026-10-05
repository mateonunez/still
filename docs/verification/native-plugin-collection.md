# Native collection and historical Claude quota

Verified locally on 2026-10-05. Development candidate only; no signed/notarized beta or public native release.

## Delivered

The mateonunez collection contains Agents, Build Watch, Deploy Watch, Task Watch, Mac Pulse, Next Up, World Clock, Quiet Timer, Weather and Spotify. Codex/Claude discovery and source configuration feed one Agents card. Each plugin has persistent settings, independent enable/visibility and explicit setup/permission/error states. Four optional visible cards are shared with declarative packages.

The workspace CLI installs reviewed manifests and configuration; it does not execute downloaded plugin code. The private package is not published on npm. GitHub/Vercel use selected, authenticated CLIs with fixed read-only requests. Weather sends selected coordinates to Open-Meteo for local evaluation; commercial deployment needs a suitable service plan. Calendar/Spotify require explicit native consent; titles are hidden by default. Spotify reads run in a bounded owned helper so an Automation stall cannot block source refresh.

Task Watch executes an explicitly supplied command and publishes only labeled state. Concurrent producer updates are serialized; task expiry is independent so a heartbeat cannot renew another completed task. No command output, environment, conversation, transcript or credential enters the snapshot.

Claude status-line observations are not server polling. Freshness expires after five minutes. An otherwise valid older observation can remain **Last reported**, with its original age, for at most 24 hours and only while a known reset is still in the future. Reset/missing/invalid windows remain unavailable. Three regression tests cover timestamp preservation, expired windows and invalid/old observations. The running native Hub was also observed showing historical quota with its original age.

## Evidence

- SessionKit: 34 tests; StillPluginKit: 8; StillWidgets: 16; StillNativePlugins: 9; native host: 4; Node CLI: 4. Total: 75 passing tests across the phase.
- `pnpm check` and `pnpm typecheck` passed. Native build and ad-hoc signing passed.
- `node scripts/verify-native-plugins.mjs`: 17/17 checks passed. Receipt: ignored `out/verification/native-collection/2026-10-05T14-03-09.410Z/native-plugins.json`.
- Exact candidate SHA-256: `dadb968eb7d1f0a4569ea7458bd9d082f1337b6c3238905e0aa2478b1312907b`.
- Real selected GitHub workflow, Vercel deployment, system metrics, clocks, timer state, Milan weather and a completed `/usr/bin/true` task supplied typed payloads. Codex/Claude client discovery passed. Calendar and Spotify correctly reported permission required; no fixtures substituted for provider facts.
- Porcelain light/dark card exports were inspected. Native Hub accessibility state showed ten enabled entries, four visible choices, disclosure controls, source facts and historical Claude quota. Opening Configure Agents exposed its real source controls.
- Energy assertion probe: 17/17 passed; native structural smoke: 12/12 passed on preceding SHA `8004ee8aaa4fa7d26c8e5b3e5c7249895755e3dd528ebecece14781d6ea06c03`. The subsequent change only added independent Task Watch row expiry; these checks are not exact-final-candidate evidence.

The initial Task Watch live probe completed before its five-second polling interval. An explicit refresh after the real producer finished made the probe deterministic; the receipt validator was retained. An initial Spotify probe exposed a stalled Automation read; explicit consent gating and the bounded helper addressed that source lifecycle failure.

## Open acceptance

Calendar permission/selection and Spotify Automation/playback need native consent and real acceptance. Task Watch must be started explicitly for actual jobs; the timer must be started explicitly. Discovered clients are not proof of live activity hooks: client trust/reload and real parallel event delivery remain separate checks.

Native glass active/inactive, keyboard/VoiceOver, smaller screens/card scrolling, permission revocation, prolonged AC/battery screen-saver behavior, Touch ID/password and gesture transitions still require physical acceptance. Source/build/render success does not prove desktop privacy. Activation-time swipe and the system-password transition remain known coverage findings. Signed distribution is deferred.

See the [configuration guide](../guides/native-plugins.md), [authoring guide](../development/native-plugin-authoring.md) and [roadmap](../roadmap.md).
