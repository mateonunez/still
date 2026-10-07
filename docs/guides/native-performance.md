# Native CPU investigation

Identify the exact running candidate before interpreting CPU data. Debug/release builds, different scenes, source configuration, multiple displays and elapsed lifetime can produce different workloads. A processor percentage is a share of one core, not total system CPU capacity.

## Observe a running Still

```sh
pgrep -x Still
node scripts/verify-native-cpu.mjs --pid <PID> --seconds 10 --max-percent 25
```

Select one PID explicitly; do not combine results from different candidates. The script verifies a Still app executable, records its SHA-256, detects a changed launch identity and computes process CPU-time deltas over actual elapsed intervals. It never activates, quits, rebuilds or changes the observed app. It returns 1 when the average exceeds the chosen investigative threshold and 2 for an invalid observation. The default threshold is an investigation signal, not a release performance budget.

Keep the chosen scene idle during the observation. Repeat editor, Settings, curtain and menu-only scenes separately; record theme, screen topology, enabled sources and uptime without private source content. Do not sample stacks at the same time as the CPU interval, since sampling can perturb the measurement. When high use is visible, capture a separate bounded stack sample:

```sh
mkdir -p out/verification/cpu-layout
sample <PID> 3 1 -file out/verification/cpu-layout/high-cpu-sample.txt
```

Profiles can include local paths or process details; keep them out of Git/public issues and share only reviewed aggregate findings. Observe the same binary, scene and source configuration before/after a change. A unit test reducing notifications does not establish the live app's CPU reduction. A ten-second pass does not establish stability after hours.

## Regression and candidate trial

```sh
swift test --package-path apps/macos --filter 'unchangedSourceTicksDoNotInvalidateObservers|unchangedNativeCardAndPauseDoNotInvalidateObservers|changedQuotaAndSuspensionStillInvalidateObservers'
```

Quit the old Still normally before launching a replacement candidate, and use the candidate resolver to identify its path/hash. Test new source data, suspension/recovery, clock progression, local timer and expiration as well as CPU. Preserve ordinary authentication and recovery. [Investigation evidence](../verification/idle-publication-cpu.md).
