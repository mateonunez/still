# Private beta preparation evidence

2026-10-06. Candidate remains `Still-polish`, executable SHA-256 `e6c6ae77b50bd98cf3cfa074f3f87e420f9509703c48118fde9a6178f48a87ac`. No app source or existing candidate binary changed in this follow-up.

| Check | Observed result |
| --- | --- |
| Candidate hash | Matches the latest successful development-build manifest |
| Preflight against prepared form | Correctly refuses signing review; ten physical checks remain null |
| Standalone energy probe | SIGABRT, no receipt; cause unestablished, no runtime pass |
| Opt-in host energy probe | Passed: 15 real IOKit lifecycle/scalar checks in 6.175 seconds; owned requests cleaned up |
| GitHub CLI status retry | Connection failed; no CI result inferred |
| Open-Meteo status-only retry | HTTP 000, curl resolution failure; no weather payload read |
| Verifier syntax / formatting | Node syntax checks and workspace Biome pass |
| Beta-preflight regression | Passed; unknown or mismatched observations cannot pass signing review |
| Intel/macOS 14 cross-build | Still, StillAgentBridge, StillClaudeBridge and StillSpotifyBridge compiled and linked; no Intel runtime acceptance |

The host energy receipt is `out/verification/beta-inputs-energy-host/energy.json`. It covers acquisition, display/system separation, explicit return/suspension, kernel timeout and cleanup. It does not establish one-hour inactivity behavior, battery endurance or packaged-app launch. The prior [refinement evidence](pre-beta-refinement.md) remains the source for functional tests, visual exports and web inspection.

The [end-user beta plan](../development/private-beta-preparation.md) records distribution inputs and the broader macOS 14+/two-architecture target. The beta audience is end users, without a fixed small-cohort limit. The [Developer ID guide](../guides/developer-id-setup.md) was researched against official Apple sources and local tool help. No membership enrollment, certificate generation, credential inspection/storage, signing, notarization upload or distribution was performed.

Native physical acceptance and release-input confirmation are pending. The current filesystem profile still prevents local Git writes and central memory extension updates. Changes and an ignored workspace phase note are preserved; remote delivery has not occurred.
