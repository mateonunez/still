# Idle source publication regression

A source polling tick was publishing identical cards into ObservableObjects, invalidating subscribed SwiftUI views even when data had not changed. Native cards also assigned an unchanged current value before polling; local derived cards created fresh timestamps irrelevant to their display.

The regression tests subscribe to the actual centers, repeat unchanged ticks and assert zero invalidations. Collection equality and guarded card publication now suppress those events while retaining real data changes, suspension, freshness and source execution. A scratch plugin store gives tests an isolated seam without modifying owner sources.

[Evidence](../verification/idle-publication-cpu.md) · [Performance guide](../guides/native-performance.md). The supplied historical near-one-core layout episode is not reproduced; these changes address a proven contributor, with live before/after and long-run acceptance still open.
