#!/bin/zsh
set -euo pipefail
still_root="${0:A:h:h}"
cd "$still_root"
node scripts/preview-version.mjs "${1:-}" >/dev/null
still_version="$(cat VERSION)"
still_numeric="${still_version%-preview.*}"
still_build="${still_version##*.}"
if [[ -n "$(git status --porcelain)" ]]; then
  print -u2 'Commit all source changes before packaging a preview.'
  exit 1
fi
still_revision="$(git rev-parse HEAD)"
still_output="$still_root/out/releases/$still_version"
if [[ -e "$still_output" ]]; then
  print -u2 'Preview output already exists; use a new version or inspect the existing artifact.'
  exit 1
fi
mkdir -p "$still_output/Still.app/Contents/MacOS" "$still_output/Still.app/Contents/Resources"
still_app="$still_output/Still.app"
for still_arch in arm64 x86_64; do
  swift build --package-path apps/macos -c release --triple "$still_arch-apple-macosx14.0" --scratch-path "$still_output/build-$still_arch"
done
for still_executable in Still StillClaudeBridge StillAgentBridge StillSpotifyBridge; do
  still_arm="$(swift build --package-path apps/macos -c release --triple arm64-apple-macosx14.0 --scratch-path "$still_output/build-arm64" --show-bin-path)"
  still_intel="$(swift build --package-path apps/macos -c release --triple x86_64-apple-macosx14.0 --scratch-path "$still_output/build-x86_64" --show-bin-path)"
  lipo -create "$still_arm/$still_executable" "$still_intel/$still_executable" -output "$still_app/Contents/MacOS/$still_executable"
  lipo -verify_arch arm64 x86_64 "$still_app/Contents/MacOS/$still_executable"
  codesign --force --sign - "$still_app/Contents/MacOS/$still_executable"
done
cp apps/macos/Resources/Info.plist "$still_app/Contents/Info.plist"
plutil -replace CFBundleShortVersionString -string "$still_numeric" "$still_app/Contents/Info.plist"
plutil -replace CFBundleVersion -string "$still_build" "$still_app/Contents/Info.plist"
plutil -insert StillPreviewVersion -string "$still_version" "$still_app/Contents/Info.plist"
cp design/fonts/InstrumentSerif-Regular.ttf design/fonts/InstrumentSerif-OFL.txt LICENSE THIRD_PARTY_NOTICES.md "$still_app/Contents/Resources/"
codesign --force --sign - "$still_app"
codesign --verify --deep --strict "$still_app"
cat > "$still_output/PREVIEW.md" <<NOTES
# Still $still_version

Experimental preview. Ad-hoc signed, NOT Developer ID signed or notarized.
Source revision: $still_revision
Universal app: Apple Silicon and Intel. Deployment target macOS 14+; broader runtime compatibility remains unverified.
Bundle identity: co.mateonunez.still.development (preview identity, not final release identity).

Still is visual privacy, not the macOS security lock. Desktop gestures during activation or system-password handoff may expose windows. Authentication, accessibility, multi-display and prolonged keep-awake acceptance remain incomplete.

Quit other Still instances before opening this preview. Back up custom layouts before changing versions. macOS may block launch; use only Apple's per-app approval in Privacy & Security if available. Never disable Gatekeeper globally. Automatic updates are not implemented; future previews require manual download.

License: MIT; Instrument Serif retains SIL OFL. See bundled notices.
NOTES
# Include the boundary in the app resources, then refresh the bundle signature.
cp "$still_output/PREVIEW.md" "$still_app/Contents/Resources/PREVIEW.md"
codesign --force --sign - "$still_app"
codesign --verify --deep --strict "$still_app"
ditto -c -k --keepParent "$still_app" "$still_output/Still-$still_version-universal.zip"
(cd "$still_output" && shasum -a 256 "Still-$still_version-universal.zip" > SHA256SUMS)
print "Preview archive: $still_output/Still-$still_version-universal.zip"
