import Foundation

final class DictionaryPropertyChangeIdCatalog: PropertyChangeIdCatalog {
    private var map: [PropertyChangeId: [Observation]] = [:]

    func addObservation(_ observation: Observation, for propertyChangeId: PropertyChangeId) {
        map[propertyChangeId] = (map[propertyChangeId] ?? []) + [observation]
    }
    
    func observations(for propertyChangeId: PropertyChangeId) -> [Observation] {
        map[propertyChangeId] ?? []
    }
    
    func removeObservation(_ observation: Observation, for propertyChangeId: PropertyChangeId) {
        var observations = map[propertyChangeId] ?? []
        observations.removeAll { $0.id == observation.id }
        if !observations.isEmpty {
            map[propertyChangeId] = observations
        } else {
            map.removeValue(forKey: propertyChangeId)
        }
    }
    
    func removeAll() {
        map.removeAll()
    }
}
