import Foundation
import StillPluginKit

let arguments = CommandLine.arguments
guard arguments.count == 3, arguments[1] == "validate" else {
    FileHandle.standardError.write(Data("Usage: still-plugin validate <package.stillplugin>\n".utf8)); exit(2)
}
do {
    let scratch = FileManager.default.temporaryDirectory.appendingPathComponent("still-validator-\(UUID().uuidString)")
    defer { try? FileManager.default.removeItem(at: scratch) }
    let manifest = try PluginStore(root: scratch).importPackage(URL(fileURLWithPath: arguments[2]))
    print("Valid protocol v\(manifest.protocolVersion): \(manifest.id) · \(manifest.widgets.count) widgets · no code execution")
} catch {
    FileHandle.standardError.write(Data("Invalid package: \((error as? PluginError)?.rawValue ?? "unreadable")\n".utf8)); exit(1)
}
