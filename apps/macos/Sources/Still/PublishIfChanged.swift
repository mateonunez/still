import Combine

extension ObservableObject {
    /// The 1 s policy tick re-derives every value; assigning an equal value still fires objectWillChange and re-lays out every open window.
    func publish<Value: Equatable>(_ keyPath: ReferenceWritableKeyPath<Self, Value>, _ value: Value) {
        if self[keyPath: keyPath] != value { self[keyPath: keyPath] = value }
    }
}
