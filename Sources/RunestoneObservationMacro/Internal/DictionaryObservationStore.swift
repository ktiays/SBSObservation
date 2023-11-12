final class DictionaryObservationStore: ObservationStore {
    var observations: [Observation] {
        Array(map.values)
    }

    private var map: [ObservationId: Observation] = [:]

    func addObservation(_ observation: Observation) {
        map[observation.id] = observation
    }

    func observation(withId observationId: ObservationId) -> Observation? {
        map[observationId]
    }

    func removeObservation(withId observationId: ObservationId) {
        map.removeValue(forKey: observationId)
    }

    func removeAll() {
        map.removeAll()
    }
}
