# GitHub Releases before Developer ID

GitHub Releases can host a macOS app archive without an Apple Developer Program membership. Hosting does not sign or notarize the app, establish compatibility, or grant permission to run it under macOS Gatekeeper.

Still's current builder produces an ad-hoc development app. It is not Developer ID signed or notarized. It should not be presented as a verified end-user beta. Before sharing any experimental artifact, identify the exact source revision, executable hash, architecture, tested OS and known privacy limitations; include license notices and checksum files, and test the actual downloaded archive on a clean Mac.

Apple may allow a user to approve an unidentified or unnotarized app through System Settings → Privacy & Security → Open Anyway. Availability depends on the warning and system policy; managed Macs may prohibit this. Do not instruct testers to disable Gatekeeper or remove quarantine attributes globally.

As of 2026-10-07, Still’s source repository and experimental releases are public. Downloads require no repository invitation. Private repositories otherwise restrict their releases to users with repository read access; MIT licensing alone does not change visibility.

For the end-user beta, retain the personal Developer ID, hardened runtime, helper signing, notarization and clean-download acceptance gates. GitHub Releases remains a suitable delivery channel after those gates pass. Automatic updates are a separate feature.

## Sources

- [GitHub: About releases](https://docs.github.com/en/repositories/releasing-projects-on-github/about-releases)
- [Apple: Developer ID](https://developer.apple.com/developer-id/)
- [Apple: Safely open apps on your Mac](https://support.apple.com/en-us/102445)

Verified 2026-10-06. The initial assessment did not create a release; delivery evidence follows below.

## Semantic preview releases

`VERSION` is the authoritative native preview version, initially `0.1.0-preview.1`. Use `MAJOR.MINOR.PATCH-preview.N` and the matching `v`-prefixed Git tag. Increment N for another preview of the same base release; bump the base version when release scope changes. Before 1.0, minor releases may introduce breaking contracts; patch releases fix compatible behavior. Stable releases use a separate, future signed distribution process.

The preview packager projects the numeric base into CFBundleShortVersionString and N into CFBundleVersion. The full prerelease label is retained in StillPreviewVersion and release notes. The Node website/package versions describe their own packages and are not the app release authority.

1. Update VERSION and document changes and known limits.
2. Run checks, commit and push main, and wait for successful Verify CI.
3. Create and push the matching annotated tag: validate with `node scripts/preview-version.mjs`, then use `git tag -a "v$(cat VERSION)" -m "Still $(cat VERSION)"` and `git push origin "v$(cat VERSION)"`.
4. The Preview release workflow verifies the tag/version, runs checks, builds both architectures, combines and verifies all four executables, ad-hoc signs the app and publishes a GitHub prerelease with ZIP, SHA256SUMS and PREVIEW.md.
5. Test the downloaded artifact on a separate Mac. Automated cross-compilation is not Intel runtime acceptance or clean-install acceptance.

No release is triggered on ordinary main pushes. Published tags/assets are not overwritten; corrections get a new preview version. Local packaging uses `./scripts/package-preview.sh "v$(cat VERSION)"`, requires a clean source tree and refuses to reuse an existing output directory. Artifacts live under ignored out/releases; interactive candidates and their manifest are untouched. No signing secrets or employer identity are used.

## First delivered preview

[0.1.0-preview.2](https://github.com/mateonunez/still/releases/tag/v0.1.0-preview.2) was published on 2026-10-06. All three assets were downloaded and inspected: matching ZIP checksum, universal app/helpers, numeric and prerelease version fields, MIT resource and valid ad-hoc bundle signature. This did not launch the app or certify Gatekeeper/clean-Mac installation. See [delivery evidence](../verification/preview-releases.md).
