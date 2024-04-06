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
        observe(car.speed, options: .initialValue) { [unowned self] oldValue, newValue in
            self.contentView.speedLabel.text = "\(newValue) km/h"
        }
        contentView.presentButton.addTarget(self, action: #selector(presentNextScreen), for: .touchUpInside)
        contentView.decreaseSpeedButton.addTarget(self, action: #selector(decreaseSpeed), for: .touchUpInside)
        contentView.increaseSpeedButton.addTarget(self, action: #selector(increaseSpeed), for: .touchUpInside)
    }

    @objc private func decreaseSpeed() {
        car.speed -= 1
    }

    @objc private func increaseSpeed() {
        car.speed += 1
    }

    @objc private func presentNextScreen() {
        let viewController = MainViewController(car: car)
        navigationController?.pushViewController(viewController, animated: true)
    }
}
