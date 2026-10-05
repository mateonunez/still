import Foundation
import Testing
@testable import Still

@Test func nativeReadRejectsOversizedOutputAndStopsOwnedProcess() async {
    let result = await NativeReadCommand.fetch(executable: URL(fileURLWithPath: "/usr/bin/yes"), arguments: [])
    if case .failure(.oversized) = result { } else { Issue.record("Expected oversized output failure") }
}
@Test func nativeReadCancellationEndsOwnedProcess() async throws {
    let task = Task { await NativeReadCommand.fetch(executable: URL(fileURLWithPath: "/bin/sleep"), arguments: ["30"]) }
    try await Task.sleep(for: .milliseconds(50)); task.cancel()
    if case .failure(.canceled) = await task.value { } else { Issue.record("Expected cancellation failure") }
}
