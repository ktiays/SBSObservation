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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        observe(car.speed) { oldValue, newValue in
            print("\(oldValue) => \(newValue)")
        }
        contentView.presentButton.addTarget(self, action: #selector(presentNextScreen), for: .touchUpInside)
        contentView.increaseSpeedButton.addTarget(self, action: #selector(decreaseSpeed), for: .touchUpInside)
        contentView.increaseSpeedButton.addTarget(self, action: #selector(increaseSpeed), for: .touchUpInside)
        speedUp()
    }

    override func loadView() {
        view = contentView
    }

    private func speedUp() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) { [weak self] in
            self?.car.increaseSpeed()
            self?.speedUp()
        }
    }

    @objc private func decreaseSpeed() {
        car.decreaseSpeed()
    }

    @objc private func increaseSpeed() {
        car.increaseSpeed()
    }

    @objc private func presentNextScreen() {
        let viewController = MainViewController(car: car)
        navigationController?.pushViewController(viewController, animated: true)
    }
}
