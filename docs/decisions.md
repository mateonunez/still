# Decision register

Prepared for joint review. Recommendations are not approvals.

| ID | Question | Recommendation | Status |
| --- | --- | --- | --- |
| D01 | Ambient screen or OS-equivalent security? | Private, elegant screen while the Mac continues working; preserve an honest boundary and native-lock access | Selected ambient screen on 2026-10-04 |
| D02 | Default visual direction? | Porcelain as the initial standard, with light and dark appearances | Selected on 2026-10-04; other themes retained for future collections |
| D03 | First release activity scope? | Hidden by default; selected app names/counts, session-local recent events | Decision pending |
| D04 | Authentication scope? | Embedded system Touch ID + Mac password in the system dialog; no app PIN/custom password | Selected this combination on 2026-10-04; implemented refinement, hardware acceptance pending |
| D05 | Energy concept? | Automatic display/system-awake request while covered; retain hidden timed/display controls | Curtain default selected on 2026-10-05; display stays on while covered; prolonged screen-saver acceptance pending |
| D06 | Name and identity? | Still as the working product name; Porcelain with burgundy direction | Selected name and color direction; font/brand implementation prepared; name clearance not performed |
| D07 | Distribution? | Native `.app`, direct signed/notarized distribution; evaluate Homebrew and terminal download | Selected direct distribution; App Store excluded |
| D08 | Pricing/license? | Test willingness to pay; evaluate one-time license | Decision pending |
| D09 | OS/hardware support? | Choose based on native experiment matrix | macOS 14 provisional deployment floor; only macOS 26.5.2 arm64 structurally verified |
| D10 | Remote repo visibility and workflow? | Private personal mateonunez/still; main bootstrap and CI | Selected private; repository created and pushed; broader branch protections remain undecided |
| D12 | Website stack? | Next.js App Router with typed metadata | Implemented and hosted on personal mmateonunez/still Vercel project |
| D13 | Product domain? | meet-still.app canonical; www redirects to apex | Configured; connected and HTTPS-verified |
| D11 | Agent awareness timing? | Optional metadata-only Codex plugin before beta and distribution | Native quota implemented; opt-in advisory hook bridge built 2026-10-05; real client trust/delivery acceptance pending |
| D14 | Widget/plugin extensibility? | Versioned reusable protocol, customizable native templates and community authoring path | Local declarative v1/importer selected and implemented 2026-10-05; producer execution/marketplace excluded |

Next step: exact-candidate physical trackpad, authentication, accessibility, power and live source acceptance using the [native checklist](guides/pre-release-native-checks.md). Native Liquid Glass controls and restrained service-window vibrancy use modern macOS materials; Porcelain coverage stays opaque. The Next.js website and direct app distribution are selected. OS/hardware support, pricing and release identity remain open.

Local development uses `co.mateonunez.still.development`; `co.mateonunez.still` is the proposed release identity, to confirm before distribution. The website uses `meet-still.app`; this does not automatically change the app's identity.

Native account quota widgets are implemented locally using Codex app-server and a Claude status-line bridge. D14 now has a constrained declarative v1; arbitrary runner/assets/actions and marketplace remain future scope. See [ADR 0007](adr/0007-native-account-quota-widgets.md) and [local evidence](verification/native-live-widgets.md).
