import Foundation

struct StoredObservation {
    let id = UUID()
    let properties: Set<AnyKeyPath>
    let changeType: PropertyChangeType
    let changeHandler: AnyObservationChangeHandler

    private let observableObservationStore: ObservationStoring
    private let observerObservationStore: ObservationStoring

    init(
        properties: Set<AnyKeyPath>,
        changeType: PropertyChangeType,
        changeHandler: AnyObservationChangeHandler,
        observableObservationStore: ObservationStoring,
        observerObservationStore: ObservationStoring
    ) {
        self.properties = properties
        self.changeType = changeType
        self.changeHandler = changeHandler
        self.observableObservationStore = observableObservationStore
        self.observerObservationStore = observerObservationStore
    }

    func cancel() {
        observableObservationStore.removeObservation(self)
        observerObservationStore.removeObservation(self)
    }
}
