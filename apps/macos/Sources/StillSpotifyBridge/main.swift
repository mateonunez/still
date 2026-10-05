import AppKit
import Carbon
import Foundation

// Fixed read-only Apple Events. No script engine, permission preflight or interactive background requests.
func code(_ value: String) -> OSType { value.utf8.reduce(0) { ($0 << 8) | OSType($1) } }
func property(_ name: String, container: NSAppleEventDescriptor = .null()) -> NSAppleEventDescriptor? {
    let record = NSAppleEventDescriptor.record()
    record.setDescriptor(NSAppleEventDescriptor(typeCode: code("prop")), forKeyword: AEKeyword(keyAEDesiredClass))
    record.setDescriptor(NSAppleEventDescriptor(enumCode: code("prop")), forKeyword: AEKeyword(keyAEKeyForm))
    record.setDescriptor(NSAppleEventDescriptor(typeCode: code(name)), forKeyword: AEKeyword(keyAEKeyData))
    record.setDescriptor(container, forKeyword: AEKeyword(keyAEContainer))
    return record.coerce(toDescriptorType: DescType(typeObjectSpecifier))
}
func get(_ object: NSAppleEventDescriptor) throws -> NSAppleEventDescriptor? {
    let event = NSAppleEventDescriptor(eventClass: AEEventClass(kAECoreSuite), eventID: AEEventID(kAEGetData), targetDescriptor: NSAppleEventDescriptor(bundleIdentifier: "com.spotify.client"), returnID: AEReturnID(kAutoGenerateReturnID), transactionID: AETransactionID(kAnyTransactionID))
    event.setParam(object, forKeyword: AEKeyword(keyDirectObject))
    let reply = try event.sendEvent(options: [.waitForReply, .neverInteract, .dontRecord], timeout: 2)
    if let number = reply.paramDescriptor(forKeyword: AEKeyword(keyErrorNumber)), number.int32Value != 0 { throw NSError(domain: NSOSStatusErrorDomain, code: Int(number.int32Value)) }
    return reply.paramDescriptor(forKeyword: AEKeyword(keyDirectObject))
}
func read() -> [String: Any] {
    guard CommandLine.arguments.count == 2, ["--show-titles", "--hide-titles"].contains(CommandLine.arguments[1]), !NSRunningApplication.runningApplications(withBundleIdentifier: "com.spotify.client").isEmpty, let player = property("pPlS") else { return ["state": "unavailable"] }
    do {
        guard let value = try get(player) else { return ["state": "unavailable"] }
        let state = value.enumCodeValue
        guard [code("kPSP"), code("kPSp"), code("kPSS")].contains(state) else { return ["state": "unavailable"] }
        var title = "Spotify", artist = "Track details hidden"
        if CommandLine.arguments[1] == "--show-titles", state != code("kPSS"), let track = property("pTrk"), let name = property("pnam", container: track), let author = property("pArt", container: track) {
            title = try get(name)?.stringValue ?? "Spotify"
            artist = try get(author)?.stringValue ?? ""
        }
        func label(_ value: String) -> String { String(value.unicodeScalars.filter { !CharacterSet.controlCharacters.contains($0) && !(0x202A...0x202E).contains($0.value) && !(0x2066...0x2069).contains($0.value) }.map(String.init).joined().prefix(80)) }
        return ["state": "ready", "title": label(title), "artist": label(artist), "playing": state == code("kPSP")]
    } catch { return ["state": (error as NSError).code == -1743 ? "permissionRequired" : "unavailable", "errorCode": (error as NSError).code] }
}
if let data = try? JSONSerialization.data(withJSONObject: read(), options: [.sortedKeys]) { FileHandle.standardOutput.write(data) }
