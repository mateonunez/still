import Darwin
import Foundation

enum NativeReadFailure: String, Error, Sendable { case missingClient, timeout, canceled, unavailable, oversized }

private final class NativeCommandProcess: @unchecked Sendable {
    let process = Process()
    let lock = NSLock()
    var data = Data()
    var failure: NativeReadFailure?
    func launch() -> Bool {
        lock.lock(); defer { lock.unlock() }
        guard failure == nil else { return false }
        do { try process.run(); return true } catch { failure = .unavailable; return false }
    }
    func result() -> Result<Data, NativeReadFailure> {
        lock.lock(); defer { lock.unlock() }
        if let failure { return .failure(failure) }
        return process.terminationStatus == 0 ? .success(data) : .failure(.unavailable)
    }
    func stop(_ reason: NativeReadFailure) {
        lock.lock(); failure = failure ?? reason; lock.unlock()
        if process.isRunning {
            process.terminate()
            DispatchQueue.global().asyncAfter(deadline: .now() + 0.5) { [self] in if process.isRunning { _ = Darwin.kill(process.processIdentifier, SIGKILL) } }
        }
    }
    func append(_ chunk: Data) {
        lock.lock()
        let tooLarge = data.count + chunk.count > 1048576
        if !tooLarge { data.append(chunk) }
        lock.unlock()
        if tooLarge { stop(.oversized) }
    }
}

enum NativeReadCommand {
    static func locate(_ name: String) -> URL? {
        let fm = FileManager.default, home = fm.homeDirectoryForCurrentUser
        var directories = (ProcessInfo.processInfo.environment["PATH"] ?? "").split(separator: ":").map(String.init)
        directories += [home.appendingPathComponent(".local/bin").path, "/opt/homebrew/bin", "/usr/local/bin", "/usr/bin"]
        let versions = home.appendingPathComponent(".nvm/versions/node")
        if let names = try? fm.contentsOfDirectory(atPath: versions.path) { directories += names.sorted { $0.compare($1, options: .numeric) == .orderedDescending }.map { versions.appendingPathComponent("\($0)/bin").path } }
        return directories.map { URL(fileURLWithPath: $0).appendingPathComponent(name) }.first { fm.isExecutableFile(atPath: $0.path) }
    }
    static func fetch(_ name: String, arguments: [String]) async -> Result<Data, NativeReadFailure> {
        guard let url = locate(name) else { return .failure(.missingClient) }
        return await fetch(executable: url, arguments: arguments)
    }
    static func fetch(executable url: URL, arguments: [String], timeoutSeconds: TimeInterval = 15) async -> Result<Data, NativeReadFailure> {
        guard FileManager.default.isExecutableFile(atPath: url.path) else { return .failure(.missingClient) }
        let box = NativeCommandProcess()
        return await withTaskCancellationHandler {
            await Task.detached(priority: .utility) {
                let output = Pipe(), error = Pipe(), input = Pipe()
                box.process.executableURL = url; box.process.arguments = arguments
                box.process.currentDirectoryURL = FileManager.default.temporaryDirectory
                var environment = ProcessInfo.processInfo.environment
                environment["PATH"] = url.deletingLastPathComponent().path + ":" + (environment["PATH"] ?? "/usr/bin:/bin:/opt/homebrew/bin")
                environment["CI"] = "1"; environment["NO_COLOR"] = "1"; environment["GH_PROMPT_DISABLED"] = "1"
                box.process.environment = environment
                box.process.standardInput = input; box.process.standardOutput = output; box.process.standardError = error
                error.fileHandleForReading.readabilityHandler = { _ = $0.availableData }
                defer { error.fileHandleForReading.readabilityHandler = nil; try? output.fileHandleForReading.close(); try? error.fileHandleForReading.close(); try? input.fileHandleForWriting.close() }
                guard box.launch() else { return box.result() }
                try? input.fileHandleForWriting.close()
                let timeout = DispatchWorkItem { box.stop(.timeout) }
                DispatchQueue.global().asyncAfter(deadline: .now() + min(60, max(0.1, timeoutSeconds)), execute: timeout)
                while true { let chunk = output.fileHandleForReading.availableData; if chunk.isEmpty { break }; box.append(chunk) }
                box.process.waitUntilExit(); timeout.cancel()
                return box.result()
            }.value
        } onCancel: { box.stop(.canceled) }
    }
}
