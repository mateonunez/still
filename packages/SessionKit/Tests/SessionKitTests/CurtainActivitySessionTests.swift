import Testing
@testable import SessionKit

@MainActor private final class ActivityDriver: CurtainActivityDriver {
    var declarations: [UInt32?] = []
    var releases: [UInt32] = []
    var failRelease = false
    var failDeclare = false
    func declareActivity(previous: UInt32?) -> Result<UInt32, EnergyFailure> { declarations.append(previous); return failDeclare ? .failure(EnergyFailure(code: "TEST", message: "Retry")) : .success(UInt32(declarations.count)) }
    func releaseActivity(_ id: UInt32) -> Result<Void, EnergyFailure> { releases.append(id); return failRelease ? .failure(EnergyFailure(code: "TEST", message: "Retry")) : .success(()) }
}
@Test @MainActor func activityRenewalIsBoundedAndStopsAfterReturn() {
    var time = 0.0
    let driver = ActivityDriver()
    let session = CurtainActivitySession(driver: driver, now: { time })
    session.tick(); #expect(driver.declarations.isEmpty)
    session.setCovered(true)
    for second in 1...3600 { time = Double(second); session.tick() }
    #expect(driver.declarations.count == 241)
    #expect(driver.declarations.first! == nil)
    #expect(driver.declarations[1] == 1)
    session.setCovered(false)
    #expect(driver.releases == [241] && session.owned == nil)
    time += 3600; session.tick(); #expect(driver.declarations.count == 241)
    session.setCovered(true); #expect(driver.declarations.last! == nil)
    session.setCovered(false)
}
@Test @MainActor func activityCleanupRetriesTheExactOwnedID() {
    let driver = ActivityDriver()
    let session = CurtainActivitySession(driver: driver, now: { 0 })
    session.setCovered(true); driver.failRelease = true; session.setCovered(false)
    #expect(session.owned == 1 && session.failure != nil)
    driver.failRelease = false; session.tick()
    #expect(driver.releases == [1, 1] && session.owned == nil)
}

@Test @MainActor func activityDeclarationFailureRetriesWithoutLeakingStateAfterStop() {
    var time = 0.0
    let driver = ActivityDriver(); driver.failDeclare = true
    let session = CurtainActivitySession(driver: driver, now: { time })
    session.setCovered(true)
    #expect(session.owned == nil && session.failure != nil)
    time = 14; session.tick(); #expect(driver.declarations.count == 1)
    driver.failDeclare = false; time = 15; session.tick()
    #expect(session.owned != nil && session.failure == nil)
    session.setCovered(false)
    driver.failDeclare = true; session.setCovered(true)
    session.setCovered(false)
    #expect(session.owned == nil && session.failure == nil)
}
