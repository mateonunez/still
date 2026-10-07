# Idle publication and CPU investigation

2026-10-07. Scope: source invalidation regression, current-process observation and a local development candidate. No production/native publication or deployment.

## Report versus observation

A supplied report describes a development process near 99% of one core after about 25 hours, attributed to repeated SwiftUI layout. That historical process/sample is not available in this investigation. The only observed Still process was Still-review in editor mode, launched about 3 hours 40 minutes earlier, executable SHA-256 `4eee2da374398b47777364754a4c703a58a3603e9be9789b7a3d017e5ea4383e`.

A three-second `sample` showed the main thread predominantly waiting, with some SwiftUI/AppKit layout work. A separate ten-second CPU-time delta observation measured 10.15% of one core on average and 15.94% peak per roughly one-second interval. No interaction was induced by this audit. The active scene/user interaction was not controlled, so this is an observation, not certified idle acceptance. The 99% sustained case was not reproduced; elapsed lifetime and executable identity differ from the supplied report.

## Deterministic regression

Command:

```sh
swift test --package-path apps/macos --filter 'unchangedSourceTicksDoNotInvalidateObservers|unchangedNativeCardAndPauseDoNotInvalidateObservers'
```

Before correction, 100 identical ticks emitted 200 widget-center notifications, 100 imported-plugin notifications, 100 native-card notifications and another 100 while the native card remained paused. These are real `objectWillChange` subscribers at the polling/view-model seam. They demonstrate avoidable view invalidation, not an independently reproduced perpetual layout loop or the historical 99% CPU case.

After correction, all these unchanged sequences emit zero notifications. A separate test verifies that fresh quota and suspension still notify, clear visible quota and then settle. The full native suite passed: 24 tests. CPU-probe/parser tests and existing script tests passed: four tests. Biome/whitespace checks passed.

## Changes

Widget and extension cards now support equality; rebuilt collections publish only when values differ. Native source cards pass through a guarded publication helper. Local clock, timer and combined-agent projections no longer fabricate a new observation timestamp on every tick; their actual content still updates, and clock/timer views retain their own schedules. Real external snapshots keep observation/expiry metadata. Cancellation only publishes `fetching = false` when it changes. Source permissions, polling cadence, expiry checks, cancellation and live-source work remain enabled.

A scratch-store injection for PluginCenter keeps the new tests away from owner plugin files. No owner app was stopped or replaced. No temporary debug instrumentation was left in product code.

## Remaining acceptance

The exact historical 99% episode remains unresolved. Reproduce it against an identified candidate and capture a matching CPU receipt/sample before attributing it to geometry feedback, a timer or this notification regression. Compare editor, Settings, curtain and menu-only states; then repeat with source configurations and after prolonged use. The current owner process retains old code, so its CPU cannot verify this correction.

Use the [performance guide](../guides/native-performance.md). Ignored evidence is under `out/verification/cpu-layout/`: current sample/CPU receipt, failing/passing publication logs and test logs. Before/after runtime CPU, long-run stability, graphics energy and physical interaction are not yet verified.
