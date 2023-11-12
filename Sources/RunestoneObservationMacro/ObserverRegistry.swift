public final class ObserverRegistry: Observer {
    private final class WeakObservabe {
        private(set) weak var observable: (any Observable)?

        init(_ observable: any Observable) {
            self.observable = observable
        }
    }

    private var observables: [ObservationId: WeakObservabe] = [:]

    public init() {}

    public func registerObserver<ObservableType: Observable, T>(
        observing keyPath: KeyPath<ObservableType, T>,
        on observable: ObservableType,
        receiving changeType: PropertyChangeType,
        options: ObservationOptions = [],
        handler: @escaping ObservationChangeHandler<T>
    ) {
        let observationId = observable.registerObserver(
            self,
            observing: keyPath,
            receiving: changeType,
            options: options,
            handler: handler
        )
        observables[observationId] = WeakObservabe(observable)
    }

    public func cancelObservation(withId observationId: ObservationId) {
        observables.removeValue(forKey: observationId)
    }

    deinit {
        deregisterFromAllObservables()
        print("Deinit \(type(of: self))")
    }
}

private extension ObserverRegistry {
    private func deregisterFromAllObservables() {
        for (observationId, weakObservable) in observables {
            weakObservable.observable?.cancelObservation(withId: observationId)
        }
        observables = [:]
    }
}
