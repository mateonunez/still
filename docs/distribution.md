# Still — direct macOS distribution

Decision, 2026-10-04: ship a real native macOS `.app`, outside the Mac App Store. Website: Next.js. App Store submission is excluded from the product roadmap.

## Main download

Package the native SwiftUI/AppKit application as `Still.app`, signed with Developer ID and hardened runtime, notarized with Apple and distributed in a user-friendly DMG or ZIP. Staple the ticket where supported, preserve the signed bundle, and verify installation on a clean supported Mac. These steps require a Developer ID signing identity and Apple Developer access; no credentials or signing configuration are created by this plan. [Developer ID](https://developer.apple.com/developer-id/), [notarization](https://developer.apple.com/documentation/security/notarizing-macos-software-before-distribution).

Published releases need a versioned immutable HTTPS URL, SHA-256, release notes, compatibility and architecture metadata. Verify codesigning/Gatekeeper and installation, not only an archive upload. Select supported architectures from native evidence, then choose a universal or architecture-specific package.

## Homebrew

Technically supported: a Homebrew **cask** can download the archive and install the contained `.app`. Define version, checksum, URL, name, description, homepage and the app artifact. Preserve normal quarantine/Gatekeeper behavior; do not use `:no_check` for a versioned downloadable release. [Cask Cookbook](https://docs.brew.sh/Cask-Cookbook).

Start by evaluating a project-maintained tap. Acceptance into Homebrew's central cask repository is a separate maintainer decision and must not be promised. Choose tap ownership and cask identity before publishing a command. [Maintaining a tap](https://docs.brew.sh/How-to-Create-and-Maintain-a-Tap), [acceptable casks](https://docs.brew.sh/Acceptable-Casks).

No usable `brew install` command exists yet. Do not display a guessed package name as an install instruction.

## curl and Node

`curl` can download the same signed archive from its real release URL. The published terminal instructions should fail on HTTP errors, follow expected redirects, verify the checksum, and retain macOS verification. Downloading alone is not installation; give explicit unpack/mount/copy instructions appropriate to the selected package format.

A Node installer could technically wrap those steps, but adds a runtime requirement and an additional distribution/maintenance path to a native app. It is not needed for the primary download or Homebrew route. Revisit only if an npm/npx installation path has a concrete use case. No remote shell execution, security-disabling instructions, or invented installer URLs are introduced now.

## Updates and release ownership

Choose a signed in-app update mechanism or a documented manual update flow before public release. Clarify the behavior when a Homebrew-installed copy also updates itself. Verify upgrade/downgrade handling, preserved preferences, authentication and power cleanup, uninstall behavior and update source authenticity.

Keep local app validation, signing/notarization, hosted artifact availability, Homebrew installation, website download readiness and final release approval as separate gates. The working name Still does not establish domain or package availability.
