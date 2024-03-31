public final class ObserverRegistrar {
    public init() {}

    deinit {
        print("Deinit \(type(of: self))")
    }

    public func registerObserver<T>(
        tracking tracker: @autoclosure () -> T,
        receiving changeType: PropertyChangeType,
        options: ObservationOptions,
        handler: @escaping ObservationChangeHandler<T>
    ) {
        guard let accessList = generateAccessList(tracker) else {
            return
        }
        let tracking = ObservationTracking(accessList)
        let changeHandler = AnyObservationChangeHandler(handler)
        tracking.installObserver(receiving: changeType, changeHandler: changeHandler)
    }
}

private extension ObserverRegistrar {
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
