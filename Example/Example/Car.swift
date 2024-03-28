import Foundation
import RunestoneObservation

protocol Car: RunestoneObservation.Observable {
    var speed: Int { get }
    func decreaseSpeed()
    func increaseSpeed()
}

@RunestoneObservable
final class Volvo: Car {
    private(set) var speed: Int = 0

    func decreaseSpeed() {
        speed -= 1
    }

    func increaseSpeed() {
        speed += 1
    }
}
