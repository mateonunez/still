# Deferred awake controls and Spaces findings

Date: 2026-10-04. Awake controls are hidden with functionality retained, pending refinement of the inactivity concept. No merged concept is selected.

## Current candidate

`ProductFeatures.awakeControlsVisible = false` hides awake/display choices from the native menu and Preferences. About/tooltip copy no longer presents them as available. The energy domain, adapters, view helpers, action handlers, preferences and tests remain retained. No preference is erased and ordinary launches acquire no awake requests. Inactivity remains available. Preferences fits its content rather than retaining an empty energy-sized window.

Candidate: `out/Still-preview.app`, ad-hoc personal identity. SHA-256 `a3de2013513d26b30982696325e012627f069221ee3b749f70395b7b9ff8dddd`. `./scripts/build-macos.sh debug Still-preview` passed. `python3 scripts/verify-native-runtime.py --app Still-preview --output out/verification/phase02/deferred-awake` passed all 8 structural checks on the same macOS 26.5.2 one-display host. Synthetic work advanced 1 → 3,083,139 → 3,781,308. Prior domain/energy evidence belongs to the earlier hash in the Phase 2 report; energy logic is unchanged. Product-facing visibility is source-verified; live menu/preferences acceptance is pending after relaunch.

## Observed coverage issue

A desktop screenshot shows Mission Control arranging Still alongside ordinary application windows, revealing desktop contents. Exposure during trackpad desktop transitions is also reported. These are real observed privacy-curtain limitations; do not mark them fixed because frame/level checks pass. Do not commit private desktop screenshots or its unrelated application contents.

The new diagnostic receipt records actual collection-behavior getters after panel creation. Observed: raw value 262481; stationary, canJoinAllSpaces and canJoinAllApplications true; managed and transient false; level 1000. This rules out those flags being silently lost during normal initialization on the probe host. It does not establish how the system compositor uses them during a gesture.

[Apple documents collection behaviors](https://developer.apple.com/documentation/appkit/nswindow/collectionbehavior-swift.struct) as window-management preferences. Stationary requests exclusion from Mission Control rearrangement; transient hides in Mission Control, so it is not a privacy fix. Joining all Spaces does not establish animation coverage. No new window-management hack, global gesture interception, private API or changed system preference was introduced.

The diagnosing-bugs workflow was applied. Native automation now resolves Still using its exact app path; bundle-only resolution is ambiguous because both local app bundles exist. The automation's capture is a selected application-window image, not reliable proof of the compositor's whole-screen transition. A cover action produced the real curtain AX state; a subsequent Control-Up observation selected Welcome, so the result is inconclusive and must not be called a deterministic gesture reproduction. No credential was collected. No red-capable automated regression test for the reported compositor exposure exists yet; a further behavioral change needs the guided native loop below.

## Guided native reproduction

Quit the previous Still via its menu, open the current preview, and record its hash before testing. Keep normal recovery available. Use the same display setup for before/after comparisons.

1. Show Still and verify ordinary desktop coverage.
2. Swipe up to Mission Control. Record whether Still becomes a tile and other windows become visible. Exit Mission Control.
3. Swipe horizontally to another desktop, then back. Separately record exposure during the animation and after it settles.
4. Repeat while moving to/from a full-screen application Space; then repeat with a second display if available.
5. Return through Touch ID/system authentication and confirm normal Spaces behavior is restored.

Report each case as PASS/EXPOSED/NOT TESTED, with Still hash, OS, display count and gesture. Distinguish a settled-Space recovery improvement from suppression of Mission Control/transition exposure. The issue stays open until the same failing gesture is observed passing. Do not claim OS-equivalent locking.
