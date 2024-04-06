import Foundation
import RunestoneObservation

protocol Car: AnyObject {
    var speed: Int { get set }
}

// ♻️ The car is an observable object.
@RunestoneObservable
final class Volvo: Car {
    var speed: Int = 0
}
