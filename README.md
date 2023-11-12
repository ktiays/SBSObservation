# RunestoneObservationMacro

Tiny observation framework designed for UIKit-based apps and built with Swift macros. It automatically handles deallocation of observations supports iOS 12 and newer.

```swift
@RunestoneObservable
final class Car {
    var speed: Int = 0
}

@RunestoneObserver
final class MainViewController: UIViewController {
    private let car = Car()

    override func viewDidLoad() {
        super.viewDidLoad()
        observe(\.speed, of: car) { [weak self] _, newValue in
            self?.contentView.speedLabel.text = "\(newValue) mph"
        }
    }
}
```
