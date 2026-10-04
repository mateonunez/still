import Testing
@testable import SessionKit

@Test func activationIsIdempotent() {
    var session = CurtainSession()
    let activated = session.cover()
    #expect(activated)
    let state = session.state
    let duplicateRejected = !session.cover()
    #expect(duplicateRejected)
    #expect(session.state == state)
}

@Test func inactiveCannotAuthenticate() {
    var session = CurtainSession()
    let authenticationUnavailable = session.beginAuthentication() == nil
    #expect(authenticationUnavailable)
}

@Test func oneAttemptAcrossDisplays() throws {
    var session = CurtainSession()
    session.cover()
    let pendingAttempt = session.beginAuthentication()
    let attempt = try #require(pendingAttempt)
    let duplicateRejected = session.beginAuthentication() == nil
    #expect(duplicateRejected)
    let completed = session.completeAuthentication(attempt: attempt, outcome: .authenticated)
    #expect(completed)
    #expect(session.state == .inactive)
}

@Test(arguments: [CurtainSession.AuthenticationOutcome.canceled, .failed])
func unsuccessfulAuthenticationRetainsCurtain(outcome: CurtainSession.AuthenticationOutcome) throws {
    var session = CurtainSession()
    session.cover()
    let pendingAttempt = session.beginAuthentication()
    let attempt = try #require(pendingAttempt)
    let completed = session.completeAuthentication(attempt: attempt, outcome: outcome)
    #expect(completed)
    #expect(session.isRequested)
    let retryAvailable = session.beginAuthentication() != nil
    #expect(retryAvailable)
}

@Test func oldAttemptCannotCompleteNewAttempt() throws {
    var session = CurtainSession()
    session.cover()
    let firstAttempt = session.beginAuthentication()
    let old = try #require(firstAttempt)
    session.invalidateAuthentication()
    let nextAttempt = session.beginAuthentication()
    let current = try #require(nextAttempt)
    let oldResultRejected = !session.completeAuthentication(attempt: old, outcome: .authenticated)
    #expect(oldResultRejected)
    let currentResultAccepted = session.completeAuthentication(attempt: current, outcome: .authenticated)
    #expect(currentResultAccepted)
}

@Test func previousSessionCannotUncoverNextSession() throws {
    var session = CurtainSession()
    session.cover()
    let pendingAttempt = session.beginAuthentication()
    let old = try #require(pendingAttempt)
    session.stop()
    session.cover()
    let oldResultRejected = !session.completeAuthentication(attempt: old, outcome: .authenticated)
    #expect(oldResultRejected)
    #expect(session.isRequested)
}

@Test func sleepInvalidatesPendingAuthentication() throws {
    var session = CurtainSession()
    session.cover()
    let pendingAttempt = session.beginAuthentication()
    let attempt = try #require(pendingAttempt)
    session.suspend()
    let authenticationUnavailable = session.beginAuthentication() == nil
    #expect(authenticationUnavailable)
    let suspendedResultRejected = !session.completeAuthentication(attempt: attempt, outcome: .authenticated)
    #expect(suspendedResultRejected)
    session.resume()
    let resumedResultRejected = !session.completeAuthentication(attempt: attempt, outcome: .authenticated)
    #expect(resumedResultRejected)
    let retryAvailable = session.beginAuthentication() != nil
    #expect(retryAvailable)
}

@Test func repeatedSuspensionStillRequiresFreshAuthentication() throws {
    var session = CurtainSession()
    session.cover()
    let firstAttempt = session.beginAuthentication()
    let old = try #require(firstAttempt)
    session.suspend()
    session.suspend()
    session.resume()
    let nextAttempt = session.beginAuthentication()
    let current = try #require(nextAttempt)
    #expect(old != current)
    let oldResultRejected = !session.completeAuthentication(attempt: old, outcome: .authenticated)
    #expect(oldResultRejected)
    #expect(session.isRequested)
}

@Test func idleSessionDoesNotActivateOnWake() {
    var session = CurtainSession()
    session.suspend()
    session.resume()
    #expect(session.state == .inactive)
}

@Test func terminationInvalidatesAttempt() throws {
    var session = CurtainSession()
    session.cover()
    let pendingAttempt = session.beginAuthentication()
    let attempt = try #require(pendingAttempt)
    session.stop()
    let oldResultRejected = !session.completeAuthentication(attempt: attempt, outcome: .authenticated)
    #expect(oldResultRejected)
    #expect(session.state == .inactive)
}
