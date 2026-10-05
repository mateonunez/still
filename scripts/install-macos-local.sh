#!/bin/zsh
set -euo pipefail
still_workspace="${0:A:h:h}"
still_source="$still_workspace/out/Still-preview.app"
still_destination="$HOME/Applications/Still.app"
[[ -d "$still_source" ]] || { print -u2 'Build Still-preview first.'; exit 1; }
codesign --verify --deep --strict "$still_source"
if [[ -e "$still_destination" ]]; then
  still_identity="$(/usr/libexec/PlistBuddy -c 'Print CFBundleIdentifier' "$still_destination/Contents/Info.plist")"
  [[ "$still_identity" == co.mateonunez.still.development ]] || { print -u2 'An unrelated app owns this destination.'; exit 1; }
  if ps -axo comm | rg -F -x "$still_destination/Contents/MacOS/Still" >/dev/null; then
    print -u2 'Quit the installed Still before updating it. No running process was stopped.'
    exit 1
  fi
fi
mkdir -p "$HOME/Applications"
still_stage="$HOME/Applications/.Still-stage-$(uuidgen).app"
ditto "$still_source" "$still_stage"
codesign --verify --deep --strict "$still_stage"
if [[ -e "$still_destination" ]]; then
  mv "$still_destination" "$HOME/Applications/.Still-previous-$(date +%Y%m%dT%H%M%S).app"
fi
mv "$still_stage" "$still_destination"
print "Installed personal development preview: $still_destination"
print 'Quit the older Still, then open the installed app. This is an ad-hoc development build.'
