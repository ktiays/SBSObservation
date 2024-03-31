struct ObservationTracking {
    struct ValueId: Hashable {
        let id: Int
        let changeType: PropertyChangeType
    }

    struct Entry: @unchecked Sendable {
        private let context: ObservableRegistrar.Context
        private var properties: Set<AnyKeyPath>

        init(_ context: ObservableRegistrar.Context, properties: Set<AnyKeyPath> = []) {
            self.context = context
            self.properties = properties
        }

        func addObserver(
            receiving changeType: PropertyChangeType,
            changeHandler: AnyObservationChangeHandler
        ) -> Int {
            context.registerTracking(of: properties, receiving: changeType, changeHandler: changeHandler)
        }

        mutating func insert(_ keyPath: AnyKeyPath) {
            properties.insert(keyPath)
        }

        func union(_ entry: Entry) -> Entry {
            Entry(context, properties: properties.union(entry.properties))
        }
    }

    struct AccessList: Sendable {
        private(set) var entries: [ObjectIdentifier: Entry] = [:]

        init() { }

        mutating func addAccess<Subject: Observable>(
            keyPath: PartialKeyPath<Subject>,
            context: ObservableRegistrar.Context
        ) {
            entries[context.id, default: Entry(context)].insert(keyPath)
        }

        mutating func merge(_ other: AccessList) {
            entries.merge(other.entries) { existing, entry in
                existing.union(entry)
            }
        }
    }

    struct State {
        var values: [ObjectIdentifier: ValueId] = [:]
        var cancelled = false
    }

    private let state = ManagedCriticalState(State())
    private let accessList: AccessList

    init(_ accessList: AccessList) {
        self.accessList = accessList
    }

    func installObserver(
        receiving changeType: PropertyChangeType,
        changeHandler: AnyObservationChangeHandler
    ) {
        let values = accessList.entries.mapValues { entry in
            let id = entry.addObserver(receiving: changeType, changeHandler: changeHandler)
            return ValueId(id: id, changeType: changeType)
        }
        state.withCriticalRegion { state in
            if !state.cancelled {
                state.values = values
            }
        }
    }
}
