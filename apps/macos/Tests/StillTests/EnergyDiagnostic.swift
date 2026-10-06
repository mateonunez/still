import Foundation
import Testing
@testable import Still

/// Finite, owned IOKit assertions only; no coverage, consent or endurance claim.
@Test(.enabled(if: ProcessInfo.processInfo.environment["STILL_LIVE_ENERGY_PROBE"] == "1"))
@MainActor func verifyOwnedEnergyAssertionLifecycle() async throws {
    let root = URL(fileURLWithPath: #filePath)
        .deletingLastPathComponent().deletingLastPathComponent()
        .deletingLastPathComponent().deletingLastPathComponent()
        .deletingLastPathComponent()
    let output = root.appendingPathComponent("out/verification/beta-inputs-energy-host")
    await EnergyRuntimeProbe.run(directory: output)
    let data = try Data(contentsOf: output.appendingPathComponent("energy.json"))
    let receipt = try #require(JSONSerialization.jsonObject(with: data) as? [String: Any])
    #expect(receipt["allPassed"] as? Bool == true)
}
