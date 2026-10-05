import Testing
@testable import SessionKit

@MainActor
private final class CurtainAssertions: AwakeAssertionDriver {
    var acquisitions = 0
    var timeouts: [Double] = []
    var kinds: [AwakeAssertion] = []
    var held: Set<UInt32> = []
    var failAcquire = false
    var failRelease = false
    func acquire(_ kind: AwakeAssertion, timeout: Double) -> Result<UInt32, EnergyFailure> {
        if failAcquire { return .failure(EnergyFailure(code: "TEST", message: "Unavailable")) }
        kinds.append(kind)
        timeouts.append(timeout)
        acquisitions += 1
        let id = UInt32(acquisitions)
        held.insert(id)
        return .success(id)
    }
    func release(_ id: UInt32) -> Result<Void, EnergyFailure> {
        if failRelease { return .failure(EnergyFailure(code: "TEST", message: "Cleanup failed")) }
        held.remove(id)
        return .success(())
    }
}

@Test @MainActor func curtainReturnPreservesIndependentTimedSession() throws {
    let driver = CurtainAssertions()
    let curtain = CurtainAwakeSession(driver: driver)
    let timed = EnergySession(driver: driver, now: { 0 })
    try timed.start(seconds: 60).get()
    let timedID = try #require(timed.owned[.system])
    curtain.setCovered(true)
    #expect(driver.held.count == 2)
    curtain.setCovered(false)
    #expect(driver.held == [timedID] && timed.isRunning)
    timed.stop()
    #expect(driver.held.isEmpty)
}

@Test @MainActor func curtainLifetimeDoesNotExpireOrStack() {
    let driver = CurtainAssertions()
    let session = CurtainAwakeSession(driver: driver)
    session.tick()
    #expect(driver.held.isEmpty)
    session.setCovered(true)
    #expect(driver.kinds == [.display])
    for _ in 0..<100 { session.tick(); session.setCovered(true) }
    #expect(driver.acquisitions == 1 && driver.held.count == 1 && driver.timeouts == [0])
    session.setCovered(false)
    #expect(driver.held.isEmpty && session.owned == nil)
    session.setCovered(true)
    #expect(driver.acquisitions == 2 && driver.held.count == 1)
}

@Test @MainActor func curtainAcquisitionFailureRetriesWithoutClaimingOwnership() {
    let driver = CurtainAssertions()
    driver.failAcquire = true
    let session = CurtainAwakeSession(driver: driver)
    session.setCovered(true)
    #expect(session.failure != nil && session.owned == nil)
    driver.failAcquire = false
    session.tick()
    #expect(session.failure == nil && driver.held.count == 1)
}

@Test @MainActor func curtainCleanupFailureKeepsExactIDForRetry() {
    let driver = CurtainAssertions()
    let session = CurtainAwakeSession(driver: driver)
    session.setCovered(true)
    let id = session.owned
    driver.failRelease = true
    session.setCovered(false)
    #expect(session.owned == id && session.failure != nil)
    driver.failRelease = false
    session.tick()
    #expect(session.owned == nil && driver.held.isEmpty)
}

@Test @MainActor func systemEndedAssertionIsReacquiredOnlyWhileCovered() {
    let driver = CurtainAssertions()
    let session = CurtainAwakeSession(driver: driver)
    session.setCovered(true)
    driver.held.removeAll()
    session.assertionEnded()
    #expect(driver.acquisitions == 2 && driver.held.count == 1)
    session.setCovered(false)
    session.assertionEnded()
    #expect(driver.acquisitions == 2 && driver.held.isEmpty)
}
