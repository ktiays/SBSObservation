import Foundation
import RunestoneObservation

protocol Car: RunestoneObservation.Observable {
    var speed: Int { get set }
}

@RunestoneObservable
final class Volvo: Car {
    var speed: Int = 0
}
