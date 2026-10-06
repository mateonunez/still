# macOS compatibility target

**Recommendation:** retain **macOS 14 or later** as the engineering target and prepare a **universal `arm64` + `x86_64` app**. Do not restrict the beta to Apple silicon or macOS 26 merely because the current development Mac uses them. Publish verified compatibility separately from the target: cross-compilation, source availability checks and host tests do not establish successful operation on an older OS or a physical Intel Mac.

## Platform and architecture

Apple's universal format supports native Apple silicon and Intel slices in one app. A universal binary can be built on either architecture; Apple silicon can additionally exercise its Intel slice through Rosetta. That translated run is useful evidence, but it does not exercise physical Intel hardware. Every bundled executable and native dependency must contain the required architecture slices. [Apple universal binary guidance](https://developer.apple.com/documentation/apple-silicon/building-a-universal-macos-binary)

The repository already declares `.macOS(.v14)` in the app and its packages, and `LSMinimumSystemVersion` is `14.0` in `apps/macos/Resources/Info.plist`. The local builder currently invokes a host-architecture Swift build; these declarations alone do not produce a universal artifact. The app, `StillAgentBridge`, `StillClaudeBridge` and `StillSpotifyBridge` need both slices in the eventual release bundle.

The deployment target describes the minimum intended runtime OS; the SDK supplies build-time APIs. Availability checks let newer APIs coexist with an older deployment target. Runtime acceptance must still verify the fallback branches. [Apple availability guidance](https://developer.apple.com/documentation/xcode/running-code-on-a-specific-version), [Swift package platform declarations](https://developer.apple.com/documentation/packagedescription/supportedplatform)

## Authentication and visual fallback

`LAAuthenticationView` is available from macOS 12 according to the installed Apple macOS SDK header (`LocalAuthenticationEmbeddedUI.framework/Headers/LAAuthenticationView.h`). It therefore does not require raising the existing macOS 14 minimum. Apple's embedded UI represents authentication policy state; hardware capability remains a runtime concern. [Apple embedded authentication UI](https://developer.apple.com/documentation/localauthenticationembeddedui/laauthenticationview)

Still checks `canEvaluatePolicy` and `.touchID` before preparing the embedded view. Its separate `.deviceOwnerAuthentication` flow keeps password authentication inside macOS. Apple's policy supports Touch ID, Apple Watch or the user's Mac password; Still should remain usable on compatible Macs without Touch ID. This is a source-level feasibility finding, not a completed password/recovery trial on those Macs. [Apple system authentication policy](https://developer.apple.com/documentation/localauthentication/lapolicy/deviceownerauthentication)

Current `StillMaterials.swift` and `ScreenCanvasView.swift` guard Liquid Glass controls and `glassEffect` with `#available(macOS 26.0, *)`; earlier systems use bordered controls and regular material. Reduce Transparency and increased contrast select solid alternatives. Porcelain and Glass remain selectable themes on older systems, but Glass's native optical treatment differs. Apple recommends standard system controls and avoiding redundant custom background effects. [Apple Liquid Glass adoption guidance](https://developer.apple.com/documentation/technologyoverviews/adopting-liquid-glass)

## Acceptance before publishing the compatibility claim

| Lane | Evidence needed |
| --- | --- |
| Artifact | Verify both slices and minimum OS metadata for the app and every helper; sign and validate the actual final bundle. |
| macOS 14 / 15 fallback | Real runtime trial: launch, both themes, editor, source permissions, authentication/recovery, displays, accessibility and awake endurance. |
| macOS 26+ | Runtime trial of Liquid Glass plus all the same functional checks; record each tested version rather than promising every future release. |
| Intel | A physical compatible Intel Mac, including a no-Touch-ID authentication path; Rosetta testing supplements this lane. |
| Apple silicon | Native runtime trial with and without available/enrolled Touch ID and the required display/trackpad matrix. |

Beta participants are intended end users. No arbitrary private-cohort size follows from platform compatibility. An incomplete lane should be labeled **targeted, not yet verified**, with the relevant limitation visible before download; it should not silently become a supported-platform claim. A failure should drive a specific fix or documented restriction, not a blanket hardware cutoff without evidence.

Checked October 6, 2026. This note records feasibility and source inspection only; cross-build results and device observations belong in the verification report for the exact executable.
