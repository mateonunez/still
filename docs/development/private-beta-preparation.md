# End-user beta preparation

2026-10-06. This plan prepares an opt-in beta for end users; it does not publish an app download or establish native acceptance. Source repository visibility remains private.

## Distribution inputs

| Input | Prepared value | Status |
| --- | --- | --- |
| Product | Still | Selected |
| Release bundle ID | `co.mateonunez.still` | Awaiting explicit confirmation |
| Development bundle ID | `co.mateonunez.still.development` | Existing; retain separately |
| First beta label | `0.1.0-beta.1` | Proposed |
| Bundle short version / build | `0.1.0` / `1` | Proposed; prerelease label belongs to release metadata |
| Architecture target | Apple Silicon (`arm64`) and Intel (`x86_64`) | Evaluate both; compiled architectures and runtime acceptance recorded separately |
| OS target | macOS 14 and later | Existing source floor; beta support promise depends on the acceptance matrix below |
| Tester audience | Opt-in end users | Selected; no arbitrary 5–10-person cap |
| Delivery | Immutable ZIP of stapled app over HTTPS | Download access and publication remain final release gates; no archive or URL exists yet |
| Update policy | Manual bundle replacement, preserve preferences/connections | [Documented](../guides/manual-updates.md); signed upgrade trial pending |
| Weather | Disable in release until provider terms cover intended distribution | License gate remains open |

The source deployment floor of macOS 14 is not a support promise. A release artifact must use the confirmed beta minimum and architecture; do not change or sign the existing development candidate in place.

## Compatibility policy

Evaluate macOS 14, 15 and 26, with Apple Silicon and Intel where that OS supports the hardware. Do not require macOS 26 solely for appearance: Porcelain and Glass's opaque scenery/content materials have older-system paths; native Liquid Glass controls activate only on macOS 26. Test the fallback independently. Macs without usable Touch ID retain the macOS-owned password path; no biometric hardware requirement is introduced.

Separate three facts in download metadata: intended minimum OS, binary architectures, and combinations actually tested. Current runtime evidence is macOS 26.5.2/Apple Silicon. On 2026-10-06, Still and all three bundled helpers compiled and linked successfully for `x86_64-apple-macosx14.0`, using an isolated build directory. This verifies compilation/linking only. Older OS and Intel need actual launch, permissions, multi-display/gesture behavior, authentication and awake trials before being advertised as supported.

Before beta delivery, run the exact signed artifact on at least one supported Intel Mac and on macOS 14/15 as well as 26. If those trials are unavailable, explicitly identify those combinations as unverified experimental targets or omit their downloadable artifact until validated. Do not silently equate a broad minimum OS in Info.plist with compatibility. Core recovery/privacy failures block availability for that combination; cosmetic Liquid Glass differences do not.

Record each trial's architecture, macOS version/build, Touch ID availability, display topology, artifact hash and results. A separate matrix row is required for materially different OS/hardware; one owner's overall visual approval cannot pass every row. Universal packaging must include both slices in Still and every bundled executable helper, then be signed and tested as one immutable artifact.

## Candidate acceptance

The exact candidate remains `out/Still-polish.app`, executable SHA-256 `e6c6ae77b50bd98cf3cfa074f3f87e420f9509703c48118fde9a6178f48a87ac`. The acceptance form is `out/beta-acceptance-polish.json`. Untested observations remain null. General positive visual feedback does not establish source permissions, gesture privacy, authentication recovery or awake endurance.

The existing automated refinement evidence remains valid for unchanged native code. On this follow-up, candidate identity was reverified, and the preflight correctly refused signing readiness with all ten physical checks open. The standalone energy probe aborted with SIGABRT without a receipt; its cause was not established. The opt-in host energy diagnostic completed successfully against real IOKit assertions. Its receipt is `out/verification/beta-inputs-energy-host/energy.json`; it verifies finite acquisition/expiry and indefinite curtain-request lifecycle, not one-hour screen-saver endurance. Status-only GitHub CLI and Open-Meteo retries did not connect from this execution environment. These failures do not diagnose the owner-operated app.

The structural runtime verifier now accepts the same candidate-name list as the other tools. The energy verifier reports an early exit or missing receipt as unverified, rather than surfacing a raw missing-file error. Neither change affects the app binary.

## Closeout and final gates

Use the [beta handoff](../guides/beta-handoff.md) to complete and record observations, then run:

```sh
node scripts/beta-preflight.mjs --acceptance out/beta-acceptance-polish.json
```

After physical acceptance and distribution-input confirmation, follow the [Developer ID setup guide](../guides/developer-id-setup.md). Signing, notarization submission, clean-Mac downloaded-artifact acceptance and tester invitations remain separate gates. Developer ID setup can be prepared while native acceptance is open; it does not release the candidate.
