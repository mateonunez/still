# Contributor PR 5: CPU integration and privacy boundary

2026-10-07. [PR 5](https://github.com/mateonunez/still/pull/5) was already merged as `e5c487ede7b46b9766f8651513ee667b171bc7a3`. Reviewed against its base `53f8f03cc997d319f0e35a1b44030b07dddf04ca`.

## Pull and integration

Pulled with rebase, retaining all four unpublished local commits and a pre-rebase backup branch. Resolved overlapping WidgetCenter, PluginCenter and NativePluginCenter changes by retaining the contributor's shared changed-value publisher plus the stronger local source publication/derived timestamp fixes, isolated store tests and marketplace discovery work. No remote push, release, deployment or PR comment was made.

Retained minute-aligned clock updates, Settings hosting-view minimum sizing and changed-value presentation projections. Completed SessionControls publication gating: its stable state still emitted 200 observer notifications per 100 ticks after the contributor patch. The added regression failed before correction and passes after; one final energy-status string is now published only on change.

Opaque Glass scenery and curtain panels were restored. Glass controls and within-window materials remain; behind-window desktop sampling was removed from the curtain/editor scene. This preserves the product privacy contract rather than treating blur as a privacy boundary.

## Standards review

Two findings on the immutable contributor diff:

1. **P1 privacy-contract violation:** StillTheme's behind-window material and CurtainCoordinator's nonopaque Glass panels contradicted the base DESIGN requirement, “The curtain remains fully opaque,” and its “Still-owned opaque scenery.” Contributor edits to DESIGN did not themselves establish approval of a new privacy boundary. Resolved by restoring opaque scenery/panels.
2. **P2 incomplete publication filtering:** repeated SessionControls status assignments and native derived timestamp generation still invalidated observers. These were existing paths left uncovered by the proposed fix, not newly introduced regressions. Resolved by retaining the local card fixes and completing status publication guards.

A subsequent read-only review of the integrated source found no new concrete defect. The new SessionControls test covers the default inactive state; an active finite awake session and enabled inactivity/error transitions are not covered by that particular test. Physical privacy/accessibility and long-running CPU remain separate checks. No actionable Fowler smell was identified beyond these findings.

## Spec review

Six findings/limits on the immutable contributor diff:

1. Unchanged `idleIssue` and `energyStatus` publication remained, contrary to the intended changed-value policy-tick behavior. Corrected locally.
2. World Clock, Quiet Timer and Agents manufactured fresh derived observation times, bypassing equality filtering. Local fixes retained.
3. The PR explicitly says “The 100% spin was not reproduced”; its short before/after editor CPU measurement was unchanged. Compilation/CI does not prove resolution of the historical long-running episode. Still open.
4. Transparent Glass scenery/panels diverged from the opaque design contract. Corrected locally.
5. `docs/research/liquid-glass.md` says blurred desktop content must not implement the privacy boundary; the PR's DESIGN change left conflicting guidance. Opaque contract restored.
6. Accessibility fallback existed, but live transparency/contrast switching was not demonstrated. Opaque panels remove that particular dynamic-opacity mismatch; physical accessibility/material acceptance is still open.

Desktop-translucent Glass was a separate product change from CPU mitigation. The integration retains the opaque contract. Authentication logic was not changed and no new authentication acceptance is claimed.

## Verification

- Contributor CI website/native checks passed: [run](https://github.com/mateonunez/still/actions/runs/37630158723).
- Integrated app: 25 Swift tests passed, including unchanged source/card/session ticks and new quota/suspension transitions.
- StillPluginKit: 15 tests passed; workspace CLI: 13 tests passed, preserving local/HTTPS discovery after the rebase.
- Biome: 81 files passed. Whitespace/conflict-marker checks passed.
- Ignored evidence: `out/verification/cpu-layout/pr5-*.log`.

The owner interactive candidate was not stopped, rebuilt or replaced. New source/tests do not establish its running CPU. Historical near-one-core churn, prolonged stability and physical native acceptance remain open. The previous Still-polish build in [idle-publication evidence](idle-publication-cpu.md) is a historical pre-PR candidate until rebuilt from this integrated source.
