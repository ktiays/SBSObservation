import Foundation

struct ManagedCriticalState<State> {
    final private class LockedBuffer: ManagedBuffer<State, UnsafeRawPointer> {}

    private let lock = NSLock()
    private let buffer: ManagedBuffer<State, UnsafeRawPointer>

    init(_ buffer: ManagedBuffer<State, UnsafeRawPointer>) {
        self.buffer = buffer
    }

    init(_ initial: State) {
        let roundedSize = (MemoryLayout<UnsafeRawPointer>.size - 1) / MemoryLayout<UnsafeRawPointer>.size
        let buffer = LockedBuffer.create(minimumCapacity: Swift.max(roundedSize, 1)) { buffer in
            initial
        }
        self.init(buffer)
    }

    internal func withCriticalRegion<R>(_ critical: (inout State) throws -> R) rethrows -> R {
        try buffer.withUnsafeMutablePointers { header, lock in
            self.lock.lock()
            defer {
                self.lock.unlock()
            }
            return try critical(&header.pointee)
        }
    }
}

extension ManagedCriticalState: Identifiable {
    var id: ObjectIdentifier {
        ObjectIdentifier(buffer)
    }
}
