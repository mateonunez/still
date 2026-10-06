# GitHub Releases before Developer ID

GitHub Releases can host a macOS app archive without an Apple Developer Program membership. Hosting does not sign or notarize the app, establish compatibility, or grant permission to run it under macOS Gatekeeper.

Still's current builder produces an ad-hoc development app. It is not Developer ID signed or notarized. It should not be presented as a verified end-user beta. Before sharing any experimental artifact, identify the exact source revision, executable hash, architecture, tested OS and known privacy limitations; include license notices and checksum files, and test the actual downloaded archive on a clean Mac.

Apple may allow a user to approve an unidentified or unnotarized app through System Settings → Privacy & Security → Open Anyway. Availability depends on the warning and system policy; managed Macs may prohibit this. Do not instruct testers to disable Gatekeeper or remove quarantine attributes globally.

The source repository is private. Its releases require repository read access, which also grants source access. For public binary downloads while preserving source privacy, a separate personally owned public distribution repository or another public asset host is a separate decision. Do not change visibility or publish a release implicitly.

For the end-user beta, retain the personal Developer ID, hardened runtime, helper signing, notarization and clean-download acceptance gates. GitHub Releases remains a suitable delivery channel after those gates pass. Automatic updates are a separate feature.

## Sources

- [GitHub: About releases](https://docs.github.com/en/repositories/releasing-projects-on-github/about-releases)
- [Apple: Developer ID](https://developer.apple.com/developer-id/)
- [Apple: Safely open apps on your Mac](https://support.apple.com/en-us/102445)

Verified 2026-10-06. No release was created as part of this assessment.
