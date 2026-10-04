import Testing
@testable import SessionKit

@MainActor
private final class FakeClock { var now = 0.0 }

@MainActor
private final class FakeAssertions: AwakeAssertionDriver {
    var nextID: UInt32 = 1
    var held: [UInt32: AwakeAssertion] = [:]
    var timeouts: [Double] = []
    var released: [UInt32] = []
    var failAcquire: AwakeAssertion?
    var failRelease = false

    func acquire(_ kind: AwakeAssertion, timeout: Double) -> Result<UInt32, EnergyFailure> {
        if kind == failAcquire { return .failure(EnergyFailure(code: "TEST_ACQUIRE", message: "Acquisition failed")) }
        let id = nextID
        nextID += 1
        held[id] = kind
        timeouts.append(timeout)
        return .success(id)
    }

    func release(_ id: UInt32) -> Result<Void, EnergyFailure> {
        if failRelease { return .failure(EnergyFailure(code: "TEST_RELEASE", message: "Release failed")) }
        held.removeValue(forKey: id)
        released.append(id)
        return .success(())
    }
}

@Test @MainActor func noAssertionsUntilExplicitStart() {
    let driver = FakeAssertions()
    let session = EnergySession(driver: driver, now: { 0 })
    session.setKeepDisplaysOn(true)
    #expect(driver.held.isEmpty)
    #expect(!session.isRunning)
}

@Test @MainActor func displayToggleDoesNotReleaseSystemRequest() throws {
    let driver = FakeAssertions()
    let clock = FakeClock()
    let session = EnergySession(driver: driver, now: { clock.now })
    try session.start(seconds: 60).get()
    #expect(driver.held.count == 1)
    let system = try #require(session.owned[.system])
    try session.setKeepDisplaysOn(true).get()
    #expect(driver.held.count == 2)
    try session.setKeepDisplaysOn(false).get()
    #expect(session.owned[.system] == system)
    #expect(driver.held.count == 1)
    #expect(session.owned[.display] == nil)
}

@Test @MainActor func exactDeadlineReleasesAllOwnedRequests() throws {
    let driver = FakeAssertions()
    let clock = FakeClock()
    let session = EnergySession(driver: driver, now: { clock.now })
    session.setKeepDisplaysOn(true)
    try session.start(seconds: 60).get()
    #expect(driver.timeouts == [62, 62])
    clock.now = 59
    session.tick()
    #expect(session.isRunning)
    clock.now = 60
    session.tick()
    #expect(!session.isRunning)
    #expect(session.owned.isEmpty && driver.held.isEmpty)
}

@Test @MainActor func partialStartRollsBackSystemRequest() {
    let driver = FakeAssertions()
    driver.failAcquire = .display
    let session = EnergySession(driver: driver, now: { 0 })
    session.setKeepDisplaysOn(true)
    let result = session.start(seconds: 60)
    if case .success = result { Issue.record("Should fail when display acquisition fails") }
    #expect(!session.isRunning)
    #expect(driver.held.isEmpty)
    #expect(driver.released.count == 1)
    #expect(session.failure != nil)
}

@Test @MainActor func failedReleaseRemainsOwnedUntilRetry() throws {
    let driver = FakeAssertions()
    let session = EnergySession(driver: driver, now: { 0 })
    try session.start(seconds: 60).get()
    driver.failRelease = true
    session.stop()
    #expect(!session.isRunning)
    #expect(!session.owned.isEmpty)
    #expect(session.failure != nil)
    let restart = session.start(seconds: 60)
    if case .success = restart { Issue.record("Must not stack a new request over failed cleanup") }
    #expect(driver.nextID == 2)
    driver.failRelease = false
    session.tick()
    #expect(session.owned.isEmpty && driver.held.isEmpty)
}

@Test @MainActor func failedDisplayToggleDoesNotClaimDisplayOwnership() throws {
    let driver = FakeAssertions()
    let session = EnergySession(driver: driver, now: { 0 })
    try session.start(seconds: 60).get()
    driver.failAcquire = .display
    session.setKeepDisplaysOn(true)
    #expect(session.isRunning)
    #expect(session.keepDisplaysOn)
    #expect(session.owned[.display] == nil)
    #expect(session.failure != nil)
}

@Test @MainActor func replacingSessionDoesNotLeakOldAssertions() throws {
    let driver = FakeAssertions()
    let session = EnergySession(driver: driver, now: { 0 })
    try session.start(seconds: 60).get()
    let first = try #require(session.owned[.system])
    try session.start(seconds: 120).get()
    #expect(driver.released == [first])
    #expect(driver.held.count == 1)
    #expect(session.remaining == 120)
}

@Test(arguments: [Double.nan, .infinity, 0, -1, 86_401]) @MainActor
func invalidDurationDoesNotReplaceActiveSession(seconds: Double) throws {
    let driver = FakeAssertions()
    let session = EnergySession(driver: driver, now: { 0 })
    try session.start(seconds: 60).get()
    let result = session.start(seconds: seconds)
    if case .success = result { Issue.record("Invalid duration accepted") }
    #expect(session.isRunning)
    #expect(driver.held.count == 1 && driver.released.isEmpty)
}
