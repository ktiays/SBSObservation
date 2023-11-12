import Foundation
import RunestoneObservationMacro

@RunestoneObservable
final class Car {
    var speed: Int = 0
}

extension Car {
    func drive() {
        DispatchQueue.main.asyncAfter(deadline: .now() + TimeInterval.random(in: 0.3 ... 1)) { [weak self] in
            self?.speed += Int.random(in: -10 ... 10)
            self?.drive()
        }
    }
}
