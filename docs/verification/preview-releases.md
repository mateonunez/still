# Preview release verification

2026-10-06.

- Strict version tests pass: invalid channels, leading zeroes, traversal-like strings and unsafe numeric components are rejected. Tag must exactly match VERSION.
- Shell syntax checked. Packaging requires a clean source tree, refuses existing output, and uses a separate ignored directory.
- Targeted history scan examined 38 reachable revisions for private-key headers, selected credential formats, company identifiers and private collaboration instructions; no pattern findings. This is a targeted scan, not exhaustive secret or licensing clearance.
- Release workflow runs existing website and native checks before publishing. Universal architecture and ad-hoc signature checks apply to all four executables.
- GitHub hosting, archive checksums and compiler targets do not establish Gatekeeper acceptance, Intel runtime support, older-macOS behavior or native physical acceptance.
- Developer ID, notarization and final release identity remain deferred. No repository visibility change is part of preview automation.

The exact workflow run and release assets are available from the matching v-prefixed tag in GitHub. Publication and clean-download testing must be observed separately; an implemented workflow alone is not delivery evidence.

The v0.1.0-preview.1 attempt passed checks and compiled both architectures, but failed before publication because lipo -verify_arch interpreted the trailing file path as an architecture. The input now precedes that operation. The corrected command was exercised against a real local universal binary containing both compiled slices; no mock. The failed tag is retained and the next attempt is 0.1.0-preview.2. No assets were published for preview.1.
