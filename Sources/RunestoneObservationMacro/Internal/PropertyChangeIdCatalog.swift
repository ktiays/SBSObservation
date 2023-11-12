protocol PropertyChangeIdCatalog {
    func addObservation(_ observation: Observation, for propertyChangeId: PropertyChangeId)
    func observations(for propertyChangeId: PropertyChangeId) -> [Observation]
    func removeObservation(_ observation: Observation, for propertyChangeId: PropertyChangeId)
    func removeAll()
}
