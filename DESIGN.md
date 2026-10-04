# Still — design contract

Still is the current working product name. Porcelain is the initial design standard: warm light surfaces, a deep-plum dark appearance, burgundy accents and quiet serif typography.

Read [brand fundamentals](docs/brand-fundamentals.md) and [the design system](docs/design-system.md) before changing a product surface. Canonical colors and roles live in [design/tokens.json](design/tokens.json).

- Preserve the selected Porcelain layout and functional hierarchy in light/dark.
- Instrument Serif is for display typography; never small controls. Use Inter for web UI and system type for native controls.
- Keep brand colors separate from semantic warning/error states. Pair status color with text.
- Generate prototype tokens and check contrast with the documented scripts.
- Respect appearance, motion, transparency, contrast and accessibility preferences.
- Use native Liquid Glass for selected controls on macOS 26, with standard controls on older systems. Service windows may use restrained vibrancy; Reduce Transparency and increased-contrast surfaces remain solid. The curtain remains fully opaque. Do not force focus, hide keyboard focus or add ornamental animation.
- Preserve the user's activity privacy. Agent awareness and marketplace features are follow-up scope.
- Use real product evidence for screenshots, claims, compatibility and installation.

The browser prototype is a design artifact. It is not the native app or the Next.js production landing.
