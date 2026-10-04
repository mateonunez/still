# Review notes

2026-10-04. Selected Porcelain as the initial standard and requested dark mode. Other families remain future collection/marketplace candidates. See [ADR 0001](../docs/adr/0001-porcelain-design-standard.md).

The product is an ambient privacy screen while work continues; it does not replace the macOS security lock.

Browser verification completed in the local Chrome preview:

- Porcelain, Spectrum, and Meadow render with distinct compositions and URL selection.
- Simulated return and cover-again flow work; focus moves to the next action.
- Automatic cover changes through the keyboard using Space.
- Disabling keep-awake does not change automatic cover or display preference.
- Settings expose labeled controls and the current simulated state.
- The landing CTA explains that enrollment is not open and collects no data.
- JavaScript syntax and local documentation links pass static checks.

Accessibility review: semantic buttons/labels, visible focus styling, live state announcements, a skip link, reduced-motion styling, and inert background controls after simulated return are included. Dark-theme navigation contrast was corrected and the Spectrum background was darkened for text legibility. This is a limited browser review, not a complete WCAG audit, mobile validation, or native VoiceOver acceptance.

No actual native window coverage, biometric evaluation, power behavior, task continuity, or permission behavior was tested. Static artwork and sample app identities do not demonstrate real integration.

Capture the accepted hierarchy and theme direction in the design document. Remove or absorb the disposable prototype when its question has been answered.

Porcelain Dark added with matching screen, settings, website and return surfaces. Browser inspection confirmed the dark screen and settings render with the new appearance selector. System appearance support is implemented with a media-query observer; native appearance behavior and a full accessibility audit remain unverified.

Still brand refinement, 2026-10-04: working name Still and burgundy Porcelain direction. Bundled Instrument Serif and Inter with license files and provenance hashes. Browser inspection confirmed the real display font and light/dark burgundy surfaces render. The palette script passes all 26 defined text/action/focus/toggle pairs. The README banner uses Instrument Serif vector outlines for the wordmark. The production landing is explicitly planned as Next.js, and direct app distribution excludes the App Store.
