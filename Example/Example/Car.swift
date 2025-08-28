import Foundation
import SBSObservation

protocol Car: AnyObject {
    var speed: Int { get set }
}

// ♻️ The car is an observable object.
@SBSObservable
final class Volvo: Car {
    var speed: Int = 0
}
