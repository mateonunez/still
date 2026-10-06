# Pre-beta refinement implementation

2026-10-06. See [verification](../verification/pre-beta-refinement.md) and [beta handoff](../guides/beta-handoff.md).

- `CurtainPresentation` owns optional appearance persistence; production passes UserDefaults, diagnostics pass no store. Unknown preferences fall back to Porcelain/System. Scene recreation is tested independently of view callbacks.
- `WidgetCenter` supports isolated read-only source roots for host integration tests. Native Agents distinguishes quota and expiring activity on separate lines; no recent signal is visible rather than silently omitted. Fresh receipts, expiry, suspension and new post-resume receipts are covered at the combined-widget boundary. This does not establish a particular client session's trust or delivery.
- `CanvasAlignment` snaps within six points to measured centers/edges and clamps movement inside the display's usable area. Outside that threshold, movement stays continuous. Guide lines do not receive input. Actual card heights and reserved footer govern fit; no fixed normalized Y ceiling or percentage-based maximum card width is imposed on explicit Free sizing.
- The editor reduces movement chrome to a menu while preserving labeled native button alternatives. Theme choices have visual previews and selected labels. Settings uses the same clock/background preferences; source cards adapt between horizontal/vertical arrangements. Plugin settings/preview and screen ordering disclose progressively.
- `native-candidate.mjs` records a successful build and verifies its executable hash before resolving its path. Reports and About identify the candidate. The app builder refuses to overwrite a bundle when process inspection fails or that exact bundle is running.
- `DesignExportDiagnostic` optionally renders Still-owned editor views through the host test runner. It does not capture desktop pixels or other applications. Offscreen exports cannot establish live glass, focus or pointer behavior.
- Website preview derives both palettes from canonical tokens and labels sample widgets as illustrations. Declarative v1 imported templates remain Porcelain-only; the native Glass theme does not expand the public template protocol.
- `beta-preflight.mjs` accepts only explicitly observed boolean checks with matching executable hash/environment. Passing observation gates permits signing review, never automatic publication.

For source checks, use the existing Swift packages and Node runner. Do not add another lint/test framework. Use the offline generated-page audit when HTTP binding is unavailable; keep it separate from served-header and browser verification.
