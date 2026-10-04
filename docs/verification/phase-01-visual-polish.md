# Phase 1 — Focus and biometric layout polish

Date: 2026-10-04. Status: compiled; visual/keyboard acceptance pending.

A live screenshot confirms the embedded authentication area appears. It exposes an oversized fingerprint overlapping its caption and a double focus indicator on the password action. It does not establish authentication success. Large-screen transitions also need further refinement.

## Fix

Remove forced initial/retry focus assignments and the additional branded focus outlines from curtain/welcome buttons. Keep native buttons, keyboard shortcuts and system keyboard-focus effects. Focus is no longer programmatically forced onto the password alternative on launch. Do not disable system accessibility or keyboard-navigation preferences to hide an indicator.

Use regular rather than large LAAuthenticationView control size. Bind the system subview's width and height to its 64 × 64 hosting slot instead of centering an unconstrained child that can overflow into adjacent text. [Apple control-size API](https://developer.apple.com/documentation/localauthenticationembeddedui/laauthenticationview/init%28context%3Acontrolsize%3A%29).

## Evidence and limits

`./scripts/build-macos.sh debug Still-preview` passes, including ad-hoc signature verification. Source inspection confirms the forced focus assignments/custom overlays are absent and the biometric subview has both dimension constraints. Executable SHA-256: `22500f561c69f7ddeec6f305383235e9f86480dc9cd46c8162ba7a723f9d40cd`.

The unchanged session/menu logic retains the previously passing 16-test baseline; it was not rerun for this visual-only change. The prior structural runtime receipt belongs to the earlier artifact, not this exact binary. No new desktop screenshot, live fingerprint-size measurement, Tab/VoiceOver result or authentication success is claimed.

Quit the running preview and reopen `out/Still-preview.app` to test. Check that initial presentation has no forced password focus, the fingerprint stays inside its slot, and Tab/Shift-Tab/Space/Return work with a visible native focus indicator according to macOS keyboard-navigation settings. Check cancellation/retry as well. Enabled OS accessibility preferences may still legitimately show focus.

## Large-screen follow-up

Keep these findings open rather than treating panel-frame equality as a fluid experience:

- Proportional spacing and clock/authentication balance at large resolutions and different display scales.
- Which display owns the inline biometric control; predictable fallback from the other display.
- Appearance/disappearance and screen-topology changes, with motion preferences honored.
- Visible transition quality across Spaces/fullscreen and actual system-dialog placement.

Phase 1 remains open until these native observations and the authentication matrix are completed. Multi-monitor smoothness remains unverified.
