# Editor interaction evidence

Date: 2026-10-07. Scope: local native refinement; physical acceptance pending.

## Reproduced failures

`swift test --package-path packages/StillNativePlugins --filter alignmentGuidesDoNotJumpAsPointerCrossesTheirThreshold` initially failed with 26 assertions. A 0.5-point step across the alignment threshold produced a 6.5-point center step. The test exercises the geometry used directly by the Free drag handler.

`swift test --package-path packages/StillNativePlugins --filter resizingKeepsLeadingAndTopEdgesStationaryWhenContentWraps` failed with five assertions after extracting the existing centered calculation into the shared layout seam. At width 250.5 the leading origin moved from 100 to 119.75; increasing height from 160 to 200 moved the top from 150 to 130. Both regression loops pass after the changes.

## Passing local checks

- StillNativePlugins: 25 tests passed, including movement/resize regressions, composition decoding, all-module geometry and persistence safeguards.
- Native Still target: 21 enabled tests passed. Opt-in runtime probes and view exports are not counted as runtime acceptance.
- Native-view export diagnostic passed for Porcelain/Glass light/dark. The Glass dark export was inspected for layout/controls. These offscreen AppKit/SwiftUI views do not demonstrate drag performance or live material rendering.
- Grid callback inspection: hover only sets the highlighted target; `performDrop` is the sole insertion callback. A live cancelled/outside-drop trial remains required.

Local logs: `out/verification/editor-interaction/`. Build output and screenshots are ignored.

## Physical trial

After quitting an older Still instance, open the hash-verified local candidate with `--editor`. Do not run two candidates together.

1. In Free, slowly cross center and module-edge guides in both directions. Verify the card follows the pointer without a threshold jump.
2. Resize a text-heavy card. Verify the leading/top edges stay fixed, wrapping grows downward and the trailing edge follows the pointer. Check release and reopening preserve the placement.
3. In Grid, hover over several cards. Verify saved order does not change before drop. Drop once; repeat with Escape and a drop outside the cards.
4. Repeat at the narrowest supported main-display viewport and on a second display. Check collision settling, reserved areas and crowding feedback.
5. Use the selection picker, movement menu and width slider with the keyboard. Repeat with Reduce Motion, Reduce Transparency and VoiceOver.

No pointer recording, VoiceOver result, gesture-privacy trial, awake endurance or clean-Mac installation is established by this phase. Automatic Free collision fitting can still move modules at release in dense scenes; that interaction remains part of issue #1. No new public native preview release is published by these source changes.

## Built candidate

`./scripts/build-macos.sh debug Still-review` completed on macOS 26.5.2 (25F84), arm64. The build script verified the ad-hoc bundle signature. This is a local development candidate, not Developer ID signing or notarization.

- Path: `out/Still-review.app`
- Source: `203c0a79318bb8844124e27295d608f8650bb01e`, clean at build
- Executable SHA-256: `4eee2da374398b47777364754a4c703a58a3603e9be9789b7a3d017e5ea4383e`
- Candidate resolver verified the executable against the local manifest.
- No interactive candidate was launched or replaced. Existing `Still-polish` remained running.
