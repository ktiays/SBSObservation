struct AnyObservationChangeHandler: Sendable {
    private let handler: @Sendable (Any, Any) throws -> Void

    init<T>(_ handler: @Sendable @escaping (T, T) -> Void) {
        self.handler = { oldValue, newValue in
            guard let typedOldValue = oldValue as? T else {
                throw ObservationError.mismatchOldValueType(
                    expectedType: T.self,
                    actualType: type(of: oldValue)
                )
            }
            guard let typedNewValue = newValue as? T else {
                throw ObservationError.mismatchNewValueType(
                    expectedType: T.self, 
                    actualType: type(of: newValue)
                )
            }
            handler(typedOldValue, typedNewValue)
        }
    }

    func invoke(changingFrom oldValue: Any, to newValue: Any) throws {
        try handler(oldValue, newValue)
    }
}
