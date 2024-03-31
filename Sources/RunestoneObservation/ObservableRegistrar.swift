public final class ObservableRegistrar {
    struct State: @unchecked Sendable {
        struct Observation {
            let properties: Set<AnyKeyPath>
            let changeType: PropertyChangeType
            let changeHandler: AnyObservationChangeHandler
        }

        private var id = 0
        private var observations: [Int: Observation] = [:]
        private var lookups: [AnyKeyPath: Set<Int>] = [:]

        mutating func generateId() -> Int {
            defer { id &+= 1 }
            return id
        }

        mutating func registerTracking(
            of properties: Set<AnyKeyPath>,
            receiving changeType: PropertyChangeType,
            changeHandler: AnyObservationChangeHandler
        ) -> Int {
            let id = generateId()
            observations[id] = Observation(
                properties: properties,
                changeType: changeType,
                changeHandler: changeHandler
            )
            for keyPath in properties {
                lookups[keyPath, default: []].insert(id)
            }
            return id
        }

        mutating func cancelAll() {
            print(observations)
            print(lookups)
            observations.removeAll()
            lookups.removeAll()
        }

        func observations(
            observing keyPath: AnyKeyPath,
            receiving changeType: PropertyChangeType
        ) -> [Observation] {
            guard let ids = lookups[keyPath] else {
                return []
            }
            var observations: [Observation] = []
            for id in ids {
                if let observation = self.observations[id], observation.changeType == changeType {
                    observations.append(observation)
                }
            }
            return observations
        }
    }

    struct Context: Sendable {
        private let state = ManagedCriticalState(State())

        var id: ObjectIdentifier {
            state.id
        }

        func registerTracking(
            of properties: Set<AnyKeyPath>,
            receiving changeType: PropertyChangeType,
            changeHandler: AnyObservationChangeHandler
        ) -> Int {
            state.withCriticalRegion { state in
                state.registerTracking(
                    of: properties,
                    receiving: changeType,
                    changeHandler: changeHandler
                )
            }
        }

        func publishChange<Subject: Observable, T>(
            ofType changeType: PropertyChangeType,
            changing keyPath: KeyPath<Subject, T>,
            on subject: Subject,
            from oldValue: T,
            to newValue: T
        ) {
            let observations = state.withCriticalRegion { state in
                state.observations(observing: keyPath, receiving: changeType)
            }
            do {
                for observation in observations {
                    try observation.changeHandler.invoke(changingFrom: oldValue, to: newValue)
                }
            } catch {
                fatalError(error.localizedDescription)
            }
        }

        func cancelAll() {
            state.withCriticalRegion { $0.cancelAll() }
        }
    }

    private let context = Context()

    public init() {}

    deinit {
        print("Deinit \(type(of: self))")
        context.cancelAll()
    }

    public func withMutation<Subject: Observable, T>(
        of keyPath: KeyPath<Subject, T>,
        on observable: Subject,
        changingFrom oldValue: T,
        to newValue: T,
        using handler: () -> Void
    ) {
        context.publishChange(ofType: .willSet, changing: keyPath, on: observable, from: oldValue, to: newValue)
        handler()
        context.publishChange(ofType: .didSet, changing: keyPath, on: observable, from: oldValue, to: newValue)
    }

    public func withMutation<Subject: Observable, T: Equatable>(
        of keyPath: KeyPath<Subject, T>,
        on observable: Subject,
        changingFrom oldValue: T,
        to newValue: T,
        handler: () -> Void
    ) {
        let isDifferentValue = oldValue != newValue
        if isDifferentValue {
            context.publishChange(
                ofType: .willSet,
                changing: keyPath,
                on: observable,
                from: oldValue,
                to: newValue
            )
        }
        handler()
        if isDifferentValue {
            context.publishChange(
                ofType: .didSet,
                changing: keyPath,
                on: observable,
                from: oldValue,
                to: newValue
            )
        }
    }

    public func access<Subject: Observable, T>(_ keyPath: KeyPath<Subject, T>, on subject: Subject) {
        guard let trackingPtr = ThreadLocal.value?.assumingMemoryBound(
            to: ObservationTracking.AccessList?.self
        ) else {
            return
        }
        if trackingPtr.pointee == nil {
            trackingPtr.pointee = ObservationTracking.AccessList()
        }
        trackingPtr.pointee?.addAccess(keyPath: keyPath, context: context)
    }
}
