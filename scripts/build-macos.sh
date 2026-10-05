#!/bin/zsh
set -euo pipefail
still_root="${0:A:h:h}"
configuration="${1:-debug}"
application_name="${2:-Still}"
if [[ "$application_name" != Still && "$application_name" != Still-preview ]]; then
  print -u2 'App output must be Still or Still-preview under out/.'
  exit 2
fi
if [[ "$configuration" != debug && "$configuration" != release ]]; then
  print -u2 'Usage: scripts/build-macos.sh [debug|release]'
  exit 2
fi
node "$still_root/scripts/generate-native-tokens.mjs"
swift build --package-path "$still_root/apps/macos" -c "$configuration"
still_bin="$(swift build --package-path "$still_root/apps/macos" -c "$configuration" --show-bin-path)"
still_app="$still_root/out/$application_name.app"
# Only rebuild our generated app bundle; no installed application is modified.
mkdir -p "$still_app/Contents/MacOS" "$still_app/Contents/Resources"
cp "$still_bin/Still" "$still_app/Contents/MacOS/Still.new"
mv -f "$still_app/Contents/MacOS/Still.new" "$still_app/Contents/MacOS/Still"
cp "$still_bin/StillClaudeBridge" "$still_app/Contents/MacOS/StillClaudeBridge.new"
mv -f "$still_app/Contents/MacOS/StillClaudeBridge.new" "$still_app/Contents/MacOS/StillClaudeBridge"
cp "$still_root/apps/macos/Resources/Info.plist" "$still_app/Contents/Info.plist"
cp "$still_root/design/fonts/InstrumentSerif-Regular.ttf" "$still_app/Contents/Resources/"
cp "$still_root/design/fonts/InstrumentSerif-OFL.txt" "$still_app/Contents/Resources/"
# Ad-hoc signing is a local development artifact, never a distributable release.
codesign --force --sign - "$still_app"
codesign --verify --deep --strict "$still_app"
print "Local development app: $still_app"
