# Settings title-bar alignment

Date: 2026-10-05. Status: source/build verified; native visual acceptance pending.

Customize used a full-size content view with its service material extending through the transparent title bar. Preferences used a separate title-bar content area. Preferences now uses the same full-size content style, with the measured native title-bar inset above the existing content padding. Traffic lights and title remain native and content is kept below them.

`swift build --package-path apps/macos` passes. No accessibility focus or authentication behavior changes. Verify Settings and Customize in light/dark and active/inactive states, including Reduce Transparency and Increase Contrast. Build success alone does not establish the live material appearance.
