/// Consumes elapsed-input age, never event contents. All times use one monotonic clock.
public struct IdlePolicy: Sendable {
    public private(set) var threshold: Double?
    private var notBefore = 0.0
    private var armed = true

    public init() {}

    public mutating func configure(threshold: Double?, now: Double) {
        self.threshold = threshold.flatMap { $0.isFinite && $0 > 0 ? $0 : nil }
        resetAfterReturn(now: now)
    }

    public mutating func resetAfterReturn(now: Double) {
        notBefore = now + (threshold ?? 0)
        armed = true
    }

    public mutating func shouldActivate(
        inputAge: Double, now: Double, alreadyCovered: Bool, sessionAvailable: Bool
    ) -> Bool {
        guard let threshold, inputAge.isFinite, inputAge >= 0, now.isFinite,
              sessionAvailable, !alreadyCovered else { return false }
        if inputAge < threshold { armed = true }
        guard armed, inputAge >= threshold, now >= notBefore else { return false }
        armed = false
        return true
    }
}
