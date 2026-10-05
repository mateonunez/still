import Darwin
import Foundation
import StillWidgets

/// Owns a short-lived client only. No thread, conversation, login or approval requests.
private final class CodexProcess: @unchecked Sendable {
    let process = Process()
    private let lock = NSLock()
    private var cancelled = false
    private var timedOut = false
    func stop(timeout: Bool = false) {
        lock.lock(); cancelled = true; timedOut = timedOut || timeout; lock.unlock()
        if process.isRunning {
            process.terminate()
            DispatchQueue.global().asyncAfter(deadline: .now() + 0.5) { [self] in
                if process.isRunning { _ = Darwin.kill(process.processIdentifier, SIGKILL) }
            }
        }
    }
    var failure: UsageFailure { lock.lock(); defer { lock.unlock() }; return timedOut ? .timeout : cancelled ? .cancelled : .unavailable }
    func launch() throws {
        lock.lock(); defer { lock.unlock() }
        guard !cancelled else { throw UsageFailure.cancelled }
        try process.run()
    }
}

enum CodexUsageAdapter {
    static func fetch(executable: URL) async -> Result<UsageSnapshot, UsageFailure> {
        let box = CodexProcess()
        return await withTaskCancellationHandler {
            await Task.detached(priority: .utility) { run(executable: executable, box: box) }.value
        } onCancel: { box.stop() }
    }

    private static func run(executable: URL, box: CodexProcess) -> Result<UsageSnapshot, UsageFailure> {
        guard FileManager.default.isExecutableFile(atPath: executable.path) else { return .failure(.missingClient) }
        let input = Pipe(), output = Pipe(), errors = Pipe()
        let process = box.process
        process.executableURL = executable
        process.arguments = ["app-server", "--stdio"]
        process.standardInput = input; process.standardOutput = output; process.standardError = errors
        process.currentDirectoryURL = FileManager.default.temporaryDirectory
        var environment = ProcessInfo.processInfo.environment
        environment["PATH"] = executable.deletingLastPathComponent().path + ":" + (environment["PATH"] ?? "/usr/bin:/bin:/opt/homebrew/bin")
        process.environment = environment
        errors.fileHandleForReading.readabilityHandler = { handle in _ = handle.availableData }
        let deadline = DispatchWorkItem { box.stop(timeout: true) }
        do { try box.launch() } catch { return .failure(.missingClient) }
        DispatchQueue.global().asyncAfter(deadline: .now() + 15, execute: deadline)
        defer {
            deadline.cancel()
            try? input.fileHandleForWriting.close()
            box.stop()
            process.waitUntilExit()
            errors.fileHandleForReading.readabilityHandler = nil
            try? output.fileHandleForReading.close()
            try? errors.fileHandleForReading.close()
        }
        func send(_ object: [String: Any]) -> Bool {
            guard let data = try? JSONSerialization.data(withJSONObject: object) else { return false }
            do { try input.fileHandleForWriting.write(contentsOf: data + Data([10])); return true } catch { return false }
        }
        guard send(["id": 1, "method": "initialize", "params": ["clientInfo": ["name": "still_usage", "title": "Still", "version": "0.1.0"]]]) else { return .failure(.unavailable) }
        var buffer = Data(), bytes = 0, initialized = false
        while true {
            let chunk = output.fileHandleForReading.availableData
            if chunk.isEmpty { break }
            bytes += chunk.count
            guard bytes <= 65536 else { return .failure(.invalidPayload) }
            buffer.append(chunk)
            while let newline = buffer.firstIndex(of: 10) {
                let line = Data(buffer[..<newline]); buffer.removeSubrange(...newline)
                guard let object = try? JSONSerialization.jsonObject(with: line) as? [String: Any], let id = object["id"] as? Int else { continue }
                if object["error"] != nil { return .failure(.unavailable) }
                if id == 1, !initialized {
                    initialized = true
                    guard send(["method": "initialized", "params": [:]]), send(["id": 2, "method": "account/rateLimits/read", "params": NSNull()]) else { return .failure(.unavailable) }
                } else if id == 2, initialized, let result = object["result"],
                          let data = try? JSONSerialization.data(withJSONObject: result) {
                    return UsageProjection.codex(data, now: Date())
                }
            }
        }
        return .failure(box.failure)
    }

    static func locate() -> URL? {
        let fm = FileManager.default, home = fm.homeDirectoryForCurrentUser
        var paths = (ProcessInfo.processInfo.environment["PATH"] ?? "").split(separator: ":").map { String($0) + "/codex" }
        paths += [home.appendingPathComponent(".local/bin/codex").path, "/opt/homebrew/bin/codex", "/usr/local/bin/codex"]
        let versions = home.appendingPathComponent(".nvm/versions/node")
        if let names = try? fm.contentsOfDirectory(atPath: versions.path) {
            paths += names.sorted { $0.compare($1, options: .numeric) == .orderedDescending }.map { versions.appendingPathComponent("\($0)/bin/codex").path }
        }
        return paths.first(where: { fm.isExecutableFile(atPath: $0) }).map { URL(fileURLWithPath: $0) }
    }
}
