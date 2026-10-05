# Update policy

There is no public native download or automatic updater yet. Development candidates are ad-hoc builds, not end-user updates.

For the first signed distribution, publish an immutable versioned artifact with release notes, compatibility, SHA-256 and verified Developer ID/notarization. Download only through the verified Still release page, quit Still and replace the application bundle. Preserve Application Support and preferences; do not erase source connections or the macOS privacy database. Confirm the app version and test consent, configuration and recovery after replacement. New permissions require explicit consent.

Automatic app updates, plugin registry upgrades, community submissions and payments require separate implementation and acceptance. Declarative metadata import never executes bundled code; importing a package is not a software update channel.
