# Decision register

Prepared for joint review. Recommendations are not approvals.

| ID | Question | Recommendation | Status |
| --- | --- | --- | --- |
| D01 | Ambient screen or OS-equivalent security? | Private, elegant screen while the Mac continues working; preserve an honest boundary and native-lock access | Selected ambient screen on 2026-10-04 |
| D02 | Default visual direction? | Porcelain as the initial standard, with light and dark appearances | Selected on 2026-10-04; other themes retained for future collections |
| D03 | First release activity scope? | Hidden by default; selected app names/counts, session-local recent events | Decision pending |
| D04 | Authentication scope? | Embedded system Touch ID + Mac password in the system dialog; no app PIN/custom password | Selected this combination on 2026-10-04; implemented refinement, hardware acceptance pending |
| D05 | Energy concept? | Preserve implementation; hide awake/display controls pending a unified inactivity concept | Controls hidden on 2026-10-04; no new combined behavior selected |
| D06 | Name and identity? | Still as the working product name; Porcelain with burgundy direction | Selected name and color direction; font/brand implementation prepared; name clearance not performed |
| D07 | Distribution? | Native `.app`, direct signed/notarized distribution; evaluate Homebrew and terminal download | Selected direct distribution; App Store excluded |
| D08 | Pricing/license? | Test willingness to pay; evaluate one-time license | Decision pending |
| D09 | OS/hardware support? | Choose based on native experiment matrix | macOS 14 provisional deployment floor; only macOS 26.5.2 arm64 structurally verified |
| D10 | Remote repo visibility and workflow? | Modern branded repo with native app and Next.js website | Repository style requested; remote visibility and workflow not selected |
| D12 | Website stack? | Next.js App Router with typed metadata | Selected Next.js; implementation pending |
| D11 | Agent awareness timing? | Optional metadata-only status, attention and usage view after v1 | Selected post-v1 evolution; providers and integration scope pending |

Next step: manual review of the Phase 2 candidate using the inactivity/energy guide, including the earlier authentication and display acceptance cases. Native Liquid Glass controls and restrained service-window vibrancy use modern macOS materials; Porcelain coverage stays opaque. The Next.js website and direct app distribution are selected. OS support, pricing and remote ownership remain open.

Local development uses `co.mateonunez.still.development`; `co.mateonunez.still` is the proposed release identity, to confirm before distribution. A product website domain is not selected.
