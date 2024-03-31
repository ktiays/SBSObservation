public final class ObservationRegistrar {
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
        
        func publishChange<ObservableType: Observable, T>(
            ofType changeType: PropertyChangeType,
            changing keyPath: KeyPath<ObservableType, T>,
            on observable: ObservableType,
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
    
    private final class Extent: @unchecked Sendable {
        let context = Context()
        
        deinit {
            print("Deinit \(type(of: self))")
            context.cancelAll()
        }
    }
    
    private let extent = Extent()
    
    private var context: Context {
        extent.context
    }

    public init() {}

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
    
    public func access<ObservableType: Observable, T>(
        _ keyPath: KeyPath<ObservableType, T>, 
        on observable: ObservableType
    ) {
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
    
    public func registerObserver<T>(
        tracking tracker: @autoclosure () -> T,
        receiving changeType: RunestoneObservation.PropertyChangeType,
        options: RunestoneObservation.ObservationOptions,
        handler: @escaping ObservationChangeHandler<T>
    ) {
        if let accessList = generateAccessList(tracker) {
            let tracking = ObservationTracking(accessList)
            let changeHandler = AnyObservationChangeHandler(handler)
            tracking.installObserver(receiving: changeType, changeHandler: changeHandler)
        }
    }
}

private extension ObservationRegistrar {
    private func generateAccessList<T>(_ apply: () -> T) -> ObservationTracking.AccessList? {
        var accessList: ObservationTracking.AccessList?
        _ = withUnsafeMutablePointer(to: &accessList) { ptr in
            let previous = ThreadLocal.value
            ThreadLocal.value = UnsafeMutableRawPointer(ptr)
            defer {
                if let scoped = ptr.pointee, let previous {
                    if var prevList = previous.assumingMemoryBound(to: ObservationTracking.AccessList?.self).pointee {
                        prevList.merge(scoped)
                        previous.assumingMemoryBound(to: ObservationTracking.AccessList?.self).pointee = prevList
                    } else {
                        previous.assumingMemoryBound(to: ObservationTracking.AccessList?.self).pointee = scoped
                    }
                }
                ThreadLocal.value = previous
            }
            return apply()
        }
        return accessList
    }
}
