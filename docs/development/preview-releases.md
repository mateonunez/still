# Semantic experimental preview delivery

2026-10-06. Introduced VERSION, strict prerelease validation and a tag-triggered Preview release workflow. The separate packager cross-compiles arm64/x86_64 at the macOS 14 deployment floor, combines every helper, verifies ad-hoc signatures and emits a ZIP, checksum file and explicit experimental notes.

Development candidates remain separate; packaging never replaces a running Still app or changes native-candidate.json. GitHub prereleases are experimental downloads, not the signed/notarized beta. Private repository access remains required until a separate visibility change. Application updates remain manual.

See the [release guide](../guides/github-releases.md) for the version/tag procedure and [verification](../verification/preview-releases.md) for evidence boundaries.
