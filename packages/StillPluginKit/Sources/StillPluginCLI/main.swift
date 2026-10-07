import Foundation
import StillPluginKit

let arguments = Array(CommandLine.arguments.dropFirst())
let json = arguments.last == "--json"
let inputs = json ? Array(arguments.dropLast()) : arguments
func emit<T: Encodable>(_ value: T) throws {
    let encoder = JSONEncoder()
    encoder.outputFormatting = [.sortedKeys]
    FileHandle.standardOutput.write(try encoder.encode(value))
    FileHandle.standardOutput.write(Data("\n".utf8))
}
struct Failure: Encodable { let schemaVersion = 1; let error: String; let actionsTaken: [String] = [] }
guard inputs.count == 2, ["validate", "inspect"].contains(inputs[0]) else {
    FileHandle.standardError.write(Data("Usage: still-plugin validate <package.stillplugin> [--json] | inspect <local-repository-or-package> [--json]\n".utf8)); exit(2)
}
do {
    let source = URL(fileURLWithPath: inputs[1])
    if inputs[0] == "inspect" {
        let report = try RepositoryDiscovery.inspect(source)
        if json { try emit(report) } else if report.candidates.isEmpty {
            print("No packages found. Add still.plugins.json or use root/plugins *.stillplugin directories.")
        } else {
            for candidate in report.candidates {
                if let manifest = candidate.manifest {
                    print("Compatible: \(candidate.path) · \(manifest.id) · \(manifest.version)")
                } else {
                    print("Incompatible: \(candidate.path) · \(candidate.error ?? "unknown")")
                }
            }
            print("Read-only inspection; no package installed or source connected.")
        }
        if !report.compatible { exit(1) }
    } else {
        let manifest = try PluginStore.inspectPackage(source)
        if json { try emit(manifest) } else {
            print("Valid protocol v\(manifest.protocolVersion): \(manifest.id) · \(manifest.widgets.count) widgets · no code execution")
        }
    }
} catch {
    let code = RepositoryDiscovery.code(error)
    if json { try? emit(Failure(error: code)) } else {
        FileHandle.standardError.write(Data("Inspection failed: \(code)\n".utf8))
    }
    exit(1)
}
