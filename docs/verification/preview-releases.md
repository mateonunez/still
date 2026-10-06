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

## Published and downloaded

Preview 0.1.0-preview.2 was published as a non-draft GitHub prerelease from source 5927a19cd73dea120e4521fc4464f1222574b3c1. [Release workflow](https://github.com/mateonunez/still/actions/runs/37490434401) passed; its source [Verify workflow](https://github.com/mateonunez/still/actions/runs/37490112718) passed.

All three assets are uploaded. The downloaded ZIP (2,783,706 bytes) matches SHA256SUMS: `fc97c7dd674fdbe39bca3c5cb9b419a064af2e29a85673aca9a0036b1e62f002`. All four downloaded executables pass arm64/x86_64 architecture verification; outer deep/strict signature verification passes. The signature is ad-hoc with no TeamIdentifier; bundle identity is co.mateonunez.still.development. StillPreviewVersion is 0.1.0-preview.2 and the bundled MIT text matches the root license.

The inspected extraction is ignored under out/verification/releases/0.1.0-preview.2. It was not launched or installed. A CLI-authenticated download is not a browser-quarantined clean-install test. Repository visibility remains private; there is no public unauthenticated download yet. Existing owner app candidates and their manifest were preserved.
