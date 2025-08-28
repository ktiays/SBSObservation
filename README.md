# RunestoneObservation

> [!IMPORTANT]
> This framework is an experimental project that reimplements and backports parts of Apple’s [Observation](https://github.com/swiftlang/swift/tree/main/stdlib/public/Observation/Sources/Observation) framework to iOS 12, with similar internals and a more ergonomic API.
> 
> The source code is provided as-is, without any guarantees of correctness, stability, or future maintenance. Use it at your own risk.

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
        observe(\.speed, of: car) { [unowned self] _, newValue in
            self.contentView.speedLabel.text = "\(newValue) mph"
        }
    }
}
```
