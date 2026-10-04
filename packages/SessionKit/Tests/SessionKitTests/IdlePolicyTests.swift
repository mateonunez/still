import Testing
@testable import SessionKit

@Test func inactivityDisabledByDefault() {
    var policy = IdlePolicy()
    let activate = policy.shouldActivate(inputAge: 1000, now: 1000, alreadyCovered: false, sessionAvailable: true)
    #expect(!activate)
}

@Test func enablingInactivityStartsFreshInterval() {
    var policy = IdlePolicy()
    policy.configure(threshold: 60, now: 100)
    let early = policy.shouldActivate(inputAge: 1000, now: 159, alreadyCovered: false, sessionAvailable: true)
    let due = policy.shouldActivate(inputAge: 1000, now: 160, alreadyCovered: false, sessionAvailable: true)
    let duplicate = policy.shouldActivate(inputAge: 1000, now: 161, alreadyCovered: false, sessionAvailable: true)
    #expect(!early)
    #expect(due)
    #expect(!duplicate)
}

@Test func biometricReturnCannotImmediatelyRecoverOldIdleAge() {
    var policy = IdlePolicy()
    policy.configure(threshold: 60, now: 0)
    let first = policy.shouldActivate(inputAge: 60, now: 60, alreadyCovered: false, sessionAvailable: true)
    #expect(first)
    policy.resetAfterReturn(now: 70)
    let early = policy.shouldActivate(inputAge: 500, now: 129, alreadyCovered: false, sessionAvailable: true)
    let next = policy.shouldActivate(inputAge: 500, now: 130, alreadyCovered: false, sessionAvailable: true)
    #expect(!early)
    #expect(next)
}

@Test func currentInputAndUnavailableSessionsDoNotActivate() {
    var policy = IdlePolicy()
    policy.configure(threshold: 60, now: 0)
    let recent = policy.shouldActivate(inputAge: 2, now: 70, alreadyCovered: false, sessionAvailable: true)
    let covered = policy.shouldActivate(inputAge: 70, now: 70, alreadyCovered: true, sessionAvailable: true)
    let unavailable = policy.shouldActivate(inputAge: 70, now: 70, alreadyCovered: false, sessionAvailable: false)
    let ready = policy.shouldActivate(inputAge: 70, now: 70, alreadyCovered: false, sessionAvailable: true)
    #expect(!recent && !covered && !unavailable)
    #expect(ready)
}

@Test(arguments: [Double.nan, .infinity, -1])
func invalidIdleSampleDoesNotActivate(sample: Double) {
    var policy = IdlePolicy()
    policy.configure(threshold: 60, now: 0)
    let activate = policy.shouldActivate(inputAge: sample, now: 100, alreadyCovered: false, sessionAvailable: true)
    #expect(!activate)
}
