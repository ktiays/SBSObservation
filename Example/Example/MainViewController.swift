import RunestoneObservation
import UIKit

@RunestoneObserver
final class MainViewController<CarType: Car>: UIViewController {
    private let car: CarType
    private let contentView = MainView()

    init(car: CarType) {
        self.car = car
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func loadView() {
        view = contentView
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // 👀 Observe the speed of the car. Get the initial value so our view is up-to-date when presented.
        observe(car.speed, options: .initialValue) { [unowned self] oldValue, newValue in
            contentView.speedLabel.text = "\(newValue) km/h"
        }
        // 🔘 Configure the buttons in the view.
        contentView.presentButton.addTarget(self, action: #selector(presentSpeedometer), for: .touchUpInside)
        contentView.decreaseSpeedButton.addTarget(self, action: #selector(decreaseSpeed), for: .touchUpInside)
        contentView.increaseSpeedButton.addTarget(self, action: #selector(increaseSpeed), for: .touchUpInside)
    }

    @objc private func decreaseSpeed() {
        // Change speed of car, causing the UI to be updated through observation.
        car.speed -= 1
    }

    @objc private func increaseSpeed() {
        // Another example of changing the speed of the car.
        car.speed += 1
    }

    @objc private func presentSpeedometer() {
        let viewController = MainViewController(car: car)
        navigationController?.pushViewController(viewController, animated: true)
    }
}
