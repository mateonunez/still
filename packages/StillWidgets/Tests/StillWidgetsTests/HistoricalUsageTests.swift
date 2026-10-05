import Foundation
import Testing
@testable import StillWidgets

@Test func oldClaudeQuotaIsHistoricalAndKeepsOriginalObservation() {
    let now = Date(), observed = now.addingTimeInterval(-3600)
    let value = UsageSnapshot(provider: .claude, observedAt: observed, windows: [UsageWindow(minutes: 300, usedPercent: 50, resetsAt: now.addingTimeInterval(60))])
    #expect(!value.isUsable(now: now))
    #expect(value.lastReported(now: now)?.observedAt == observed)
    #expect(value.lastReported(now: now)?.windows.first?.usedPercent == 50)
    #expect(value.lastReported(now: now.addingTimeInterval(60)) == nil)
}
@Test func historicalQuotaDropsExpiredWindowWithoutInferringReset() {
    let now = Date(), value = UsageSnapshot(provider: .claude, observedAt: now.addingTimeInterval(-3600), windows: [UsageWindow(minutes: 300, usedPercent: 90, resetsAt: now.addingTimeInterval(-1)), UsageWindow(minutes: 10080, usedPercent: 40, resetsAt: now.addingTimeInterval(86400))])
    #expect(value.lastReported(now: now)?.windows.map(\.minutes) == [10080])
    #expect(value.lastReported(now: now)?.windows.first?.usedPercent == 40)
}
@Test func historicalQuotaRejectsMissingResetOldInvalidAndOtherProvider() {
    let now = Date(), window = UsageWindow(minutes: 300, usedPercent: 30, resetsAt: now.addingTimeInterval(86400))
    #expect(UsageSnapshot(provider: .claude, observedAt: now.addingTimeInterval(-86401), windows: [window]).lastReported(now: now) == nil)
    #expect(UsageSnapshot(provider: .codex, observedAt: now.addingTimeInterval(-3600), windows: [window]).lastReported(now: now) == nil)
    #expect(UsageSnapshot(provider: .claude, observedAt: now, windows: [UsageWindow(minutes: 300, usedPercent: 30, resetsAt: nil)]).lastReported(now: now) == nil)
    #expect(UsageSnapshot(provider: .claude, observedAt: now, windows: [UsageWindow(minutes: 300, usedPercent: .nan, resetsAt: now.addingTimeInterval(60))]).lastReported(now: now) == nil)
}
