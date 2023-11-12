public final class ObservableRegistry<ObservableType: Observable> {
    private var observationStore: ObservationStore
    private var propertyChangeIdCatalog: PropertyChangeIdCatalog

    public convenience init() {
        let observationStore = DictionaryObservationStore()
        let propertyChangeIdCatalog = DictionaryPropertyChangeIdCatalog()
        self.init(observationStore: observationStore, propertyChangeIdCatalog: propertyChangeIdCatalog)
    }

    init<ObservationStoreType: ObservationStore, PropertyChangeIdCatalogType: PropertyChangeIdCatalog>(
        observationStore: ObservationStoreType,
        propertyChangeIdCatalog: PropertyChangeIdCatalogType
    ) {
        self.observationStore = observationStore
        self.propertyChangeIdCatalog = propertyChangeIdCatalog
    }

    deinit {
        deregisterAllObservers()
        print("Deinit \(type(of: self))")
    }

    public func publishChange<T>(
        ofType changeType: PropertyChangeType,
        changing keyPath: KeyPath<ObservableType, T>,
        on observable: ObservableType,
        from oldValue: T,
        to newValue: T
    ) {
        let propertyChangeId = PropertyChangeId(for: observable, publishing: changeType, of: keyPath)
        let observations = propertyChangeIdCatalog.observations(for: propertyChangeId)
        for observation in observations {
            observation.handler.invoke(changingFrom: oldValue, to: newValue)
        }
    }

    public func registerObserver<T>(
        _ observer: some Observer,
        observing keyPath: KeyPath<ObservableType, T>,
        on observable: ObservableType,
        receiving changeType: PropertyChangeType,
        options: ObservationOptions = [],
        handler: @escaping ObservationChangeHandler<T>
    ) -> ObservationId {
        let propertyChangeId = PropertyChangeId(for: observable, publishing: changeType, of: keyPath)
        let observation = Observation(
            observer: observer,
            propertyChangeId: propertyChangeId,
            handler: handler
        )
        observationStore.addObservation(observation)
        propertyChangeIdCatalog.addObservation(observation, for: propertyChangeId)
        if options.contains(.initialValue) {
            let initialValue = observable[keyPath: keyPath]
            handler(initialValue, initialValue)
        }
        return observation.id
    }

    public func cancelObservation(withId observationId: ObservationId) {
        guard let observation = observationStore.observation(withId: observationId) else {
            return
        }
        propertyChangeIdCatalog.removeObservation(observation, for: observation.propertyChangeId)
        observationStore.removeObservation(withId: observationId)
    }
}

private extension ObservableRegistry {
    private func deregisterAllObservers() {
        for observation in observationStore.observations {
            observation.invokeCancelOnObserver()
        }
        observationStore.removeAll()
        propertyChangeIdCatalog.removeAll()
    }
}
