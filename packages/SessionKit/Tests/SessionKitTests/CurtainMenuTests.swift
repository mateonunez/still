import Foundation
import Testing
@testable import SessionKit

@Test func readyMenuOffersOnlyPresentation() {
    let menu = CurtainMenu(state: .inactive)
    #expect(menu.actionTitle == "Show Still")
    #expect(menu.actionEnabled)
}

@Test func coveredMenuOffersReturn() {
    let menu = CurtainMenu(state: .covered(UUID()))
    #expect(menu.actionTitle == "Return to desktop…")
    #expect(menu.actionEnabled)
}

@Test func biometricWaitStillAllowsFallback() {
    let menu = CurtainMenu(state: .authenticating(session: UUID(), attempt: UUID()), embeddedBiometrics: true)
    #expect(menu.actionTitle == "Other unlock options…")
    #expect(menu.actionEnabled)
}

@Test func systemPromptCannotStartDuplicateAttempt() {
    let menu = CurtainMenu(state: .authenticating(session: UUID(), attempt: UUID()))
    #expect(!menu.actionEnabled)
}

@Test func suspendedMenuDoesNotOfferPresentation() {
    let menu = CurtainMenu(state: .suspended(UUID()))
    #expect(!menu.actionEnabled)
}

@Test func fallbackInvalidatesPendingBiometricSuccess() throws {
    var session = CurtainSession()
    session.cover()
    let first = session.beginAuthentication()
    let biometric = try #require(first)
    session.invalidateAuthentication()
    let second = session.beginAuthentication()
    let fallback = try #require(second)
    let oldAccepted = session.completeAuthentication(attempt: biometric, outcome: .authenticated)
    #expect(!oldAccepted)
    let fallbackAccepted = session.completeAuthentication(attempt: fallback, outcome: .authenticated)
    #expect(fallbackAccepted)
}
