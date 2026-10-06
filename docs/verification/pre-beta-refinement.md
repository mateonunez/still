# Pre-beta refinement evidence

2026-10-06. Current local candidate: `out/Still-polish.app`.

Executable SHA-256: `e6c6ae77b50bd98cf3cfa074f3f87e420f9509703c48118fde9a6178f48a87ac`.

The source revision at build time was `530c265` with working-tree changes. The executable hash identifies the tested binary; it is not a published release or an assertion that the current working tree has been committed.

## Implemented and inspected

Appearance persistence now belongs to the scene model, with a separate no-store diagnostic mode. Both official themes share clock preferences and preview surfaces. Native Agents shows quota and activity separately, including explicit source silence after expiry. Free placement uses measured alignment guides and the actual content bounds; explicit card widths are no longer limited to a display-width percentage. The selection toolbar uses a movement menu. Plugin configuration, preview and screen ordering disclose progressively.

Offscreen NSHostingView exports were generated for Porcelain/Glass in Light/Dark. The dark Glass and light Porcelain arrangements were visually inspected at 1280×800. This caught a wrapped Arrangement label; the segmented picker now hides its visual label while retaining its accessibility label. Clock scale now grows when fewer modules need space. Glass scenery uses soft radial gradients rather than relying on blur-filter capture.

Exports are in `out/verification/design-refinement/`. They render only Still-owned views and local read-only Mac Pulse/World Clock data. They are excluded from Git and were not added as public marketing screenshots. Initial ImageRenderer exports contained unsupported-control placeholders; they were replaced by NSHostingView cache exports. Offscreen, inactive material rendering is not live Liquid Glass, pointer, VoiceOver or privacy acceptance.

## Automated results

| Area | Result | Boundary |
| --- | --- | --- |
| App host | 18 functional tests passed | Includes theme recreation and projected activity through the combined Agents widget, expiry, suspension and new post-resume events. |
| StillNativePlugins | 23 tests passed | Ten-module catalog/configuration, schema migration, continuous placement, measured alignment, viewport/grid geometry and source projections. |
| StillWidgets | 16 tests passed | Quota validation/history, advisory activity projection, hooks and conflict-safe status-line changes. |
| StillPluginKit | 8 tests passed | Import, validation, bounded snapshots, identity/revision/expiry, revocation and no package execution. |
| SessionKit | 37 tests passed | Authentication/session transitions, inactivity and owned power-request lifecycle; no physical endurance claim. |
| Workspace plugin CLI | 4 Node tests passed | Configuration preservation, symlink rejection and actual registered task execution/concurrency. |
| Beta preflight | 1 Node test passed | Rejects unknown/string/failed checks, wrong candidate and missing environment; never establishes distributed-beta readiness. |
| Native view diagnostic | Opt-in export test passed; four views generated | Offscreen arrangement only. |
| Agent helper | 15 synthetic invocations passed | Explicit enable/revoke, privacy projection, attention/progress/end, child cleanup; no authoritative approval state. Maximum invocation was 379 ms in this run. |
| Candidate | Swift build and strict ad-hoc signature verification passed | Not Developer ID signed or notarized. |
| Website | Typecheck, Biome and Next.js webpack build passed | 27 generated routes; no deployment in this phase. |
| SEO/SDK build inspection | 18 content pages passed | Unique titles/H1, canonical, local noindex, 18 sitemap entries, ten-plugin catalog, human/agent guide and 1200×630 OG image. Offline built files, not HTTP headers/browser behavior. |
| Contrast | 46 declared flat palette pairs passed | Gradient/material contrast and native focus still require inspection. |

## Live source results and limits

The standalone app probe produced no receipt within its 40-second bound and was stopped as an owned diagnostic process. A separate opt-in host test ran the existing runtime probe against scratch copies of the configured sources. Its receipt is `out/verification/readiness-live-sources/native-plugins.json`; **allPassed is false**.

- Task Watch executed a real registered verification task and reported completion. Mac Pulse, World Clock and Quiet Timer produced payloads; timer start/stop, suspension, ten-module loading and selected-card rendering passed. Individual Mac Pulse fields can still be unavailable.
- Agents produced its combined container. This does not establish fresh quota values. Read-only activity-file inspection separately observed fresh Codex states; Claude had no fresh state at the inspection time. Previously observed fresh receipts do not establish current client work.
- Build Watch, Deploy Watch and Weather produced unavailable states. A direct, status-only GitHub CLI retry failed to connect to `api.github.com`. Other unavailable-source causes are not established by this receipt.
- Calendar remained permissionRequired; no permission prompt was accepted or calendar content read.
- Spotify was unavailable in the host runner, whose bundle does not contain the app helper at the normal bundle-relative location. The actual `Still-polish` helper was also invoked with titles hidden and no permission interaction; it returned unavailable without an error code. Actual app-owned consent/playback therefore remains open. No cause was inferred and no consent was reset.

No sample quota/playback was substituted. Source connections, user hooks, authentication choices and the running interactive candidates were preserved.

## Environment and delivery

Turbopack did not complete compilation in this managed session; the owned build was interrupted and the standard Next.js webpack build succeeded. Local HTTP startup failed with `listen EPERM` on 127.0.0.1:3186, so no browser/served-header verification was claimed. The offline audit is a separate script: `node scripts/verify-website-build.mjs`.

The current permission profile makes `.git` read-only. The GitHub connector separately confirmed the private repository and matching `main` head, but its commit interface does not expose author selection; it was not used to replace the configured noreply identity. Changes remain uncommitted locally and the updated site has not been delivered to Vercel. A review patch, including new files, is prepared at `out/pre-beta-refinement.patch`. Central memory extension notes are also outside the writable roots; an ignored workspace phase note is maintained instead. No credentials, signing or publication were attempted.

## Open acceptance and beta handoff

Use the [beta handoff](../guides/beta-handoff.md), prepared `out/beta-acceptance-polish.json` and `node scripts/beta-preflight.mjs`. Checks start untested. Repeat real theme/editor/Agents/Spotify trials, external-source recovery, Calendar permission, multi-display scaling/topology, accessibility, first/repeated Touch ID, password cancel/retry, activation-time gestures and one-hour AC/battery awake trials. Earlier results must not pass a changed executable automatically.

Release identity, verified compatibility, personal Developer ID, hardened helper signing, notarization and clean-Mac download/install remain separate final gates. A green automated test suite does not establish beta readiness.
