import AppKit
import Carbon
import Foundation

// Fixed read-only Spotify properties. Parent owns this process and enforces a 15s lifetime.
func read() -> [String: Any] {
    guard CommandLine.arguments.count == 2, ["--show-titles", "--hide-titles"].contains(CommandLine.arguments[1]) else { return ["state": "unavailable"] }
    guard !NSRunningApplication.runningApplications(withBundleIdentifier: "com.spotify.client").isEmpty else { return ["state": "unavailable"] }
    let target = NSAppleEventDescriptor(bundleIdentifier: "com.spotify.client")
    guard AEDeterminePermissionToAutomateTarget(target.aeDesc, AEEventClass(kAECoreSuite), AEEventID(kAEGetData), false) == noErr else { return ["state": "permissionRequired"] }
    let properties = CommandLine.arguments[1] == "--show-titles" ? "{player state as string, name of current track, artist of current track}" : "{player state as string, \"Spotify\", \"Track details hidden\"}"
    let script = NSAppleScript(source: "with timeout of 2 seconds\ntell application id \"com.spotify.client\"\nreturn \(properties)\nend tell\nend timeout")
    var error: NSDictionary?
    guard let result = script?.executeAndReturnError(&error), error == nil, let state = result.atIndex(1)?.stringValue, ["playing", "paused"].contains(state) else { return ["state": "unavailable"] }
    func label(_ value: String) -> String { String(value.unicodeScalars.filter { !CharacterSet.controlCharacters.contains($0) && !(0x202A...0x202E).contains($0.value) && !(0x2066...0x2069).contains($0.value) }.map(String.init).joined().prefix(80)) }
    return ["state": "ready", "title": label(result.atIndex(2)?.stringValue ?? "Spotify"), "artist": label(result.atIndex(3)?.stringValue ?? ""), "playing": state == "playing"]
}
if let data = try? JSONSerialization.data(withJSONObject: read(), options: [.sortedKeys]) { FileHandle.standardOutput.write(data) }
