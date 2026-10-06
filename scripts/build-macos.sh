#!/bin/zsh
set -euo pipefail
still_root="${0:A:h:h}"
configuration="${1:-debug}"
application_name="${2:-Still}"
if [[ "$application_name" != Still && "$application_name" != Still-preview && "$application_name" != Still-canvas && "$application_name" != Still-glass && "$application_name" != Still-design && "$application_name" != Still-review && "$application_name" != Still-polish ]]; then
  print -u2 'Unsupported development candidate name.'
  exit 2
fi
if [[ "$configuration" != debug && "$configuration" != release ]]; then
  print -u2 'Usage: scripts/build-macos.sh [debug|release]'
  exit 2
fi
still_app="$still_root/out/$application_name.app"
if [[ -e "$still_app" ]]; then
  if ! still_processes="$(ps -axo comm)"; then
    print -u2 "Cannot inspect running apps; refusing to replace $application_name."
    exit 1
  fi
  if print -r -- "$still_processes" | rg -F -x "$still_app/Contents/MacOS/Still" >/dev/null; then
    print -u2 "Quit $application_name before rebuilding it. No running app was replaced."
    exit 1
  fi
fi
node "$still_root/scripts/generate-native-tokens.mjs"
still_swift_options=()
[[ -z "${STILL_SWIFT_CACHE_PATH:-}" ]] || still_swift_options+=(--cache-path "$STILL_SWIFT_CACHE_PATH")
[[ -z "${STILL_SWIFT_SCRATCH_PATH:-}" ]] || still_swift_options+=(--scratch-path "$STILL_SWIFT_SCRATCH_PATH")
[[ "${STILL_SWIFT_DISABLE_SANDBOX:-0}" != 1 ]] || still_swift_options+=(--disable-sandbox)
swift build "${still_swift_options[@]}" --package-path "$still_root/apps/macos" -c "$configuration"
still_bin="$(swift build "${still_swift_options[@]}" --package-path "$still_root/apps/macos" -c "$configuration" --show-bin-path)"
# Only rebuild our generated app bundle; no installed application is modified.
mkdir -p "$still_app/Contents/MacOS" "$still_app/Contents/Resources"
cp "$still_bin/Still" "$still_app/Contents/MacOS/Still.new"
mv -f "$still_app/Contents/MacOS/Still.new" "$still_app/Contents/MacOS/Still"
cp "$still_bin/StillClaudeBridge" "$still_app/Contents/MacOS/StillClaudeBridge.new"
mv -f "$still_app/Contents/MacOS/StillClaudeBridge.new" "$still_app/Contents/MacOS/StillClaudeBridge"
cp "$still_bin/StillAgentBridge" "$still_app/Contents/MacOS/StillAgentBridge.new"
mv -f "$still_app/Contents/MacOS/StillAgentBridge.new" "$still_app/Contents/MacOS/StillAgentBridge"
cp "$still_bin/StillSpotifyBridge" "$still_app/Contents/MacOS/StillSpotifyBridge.new"
mv -f "$still_app/Contents/MacOS/StillSpotifyBridge.new" "$still_app/Contents/MacOS/StillSpotifyBridge"
cp "$still_root/apps/macos/Resources/Info.plist" "$still_app/Contents/Info.plist"
plutil -insert StillCandidate -string "$application_name" "$still_app/Contents/Info.plist"
cp "$still_root/design/fonts/InstrumentSerif-Regular.ttf" "$still_app/Contents/Resources/"
cp "$still_root/design/fonts/InstrumentSerif-OFL.txt" "$still_app/Contents/Resources/"
cp "$still_root/LICENSE" "$still_app/Contents/Resources/LICENSE"
# Ad-hoc signing is a local development artifact, never a distributable release.
codesign --force --sign - "$still_app"
codesign --verify --deep --strict "$still_app"
node "$still_root/scripts/native-candidate.mjs" --record "$application_name"
print "Local development app: $still_app"
