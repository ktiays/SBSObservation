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
        observe(\.speed, of: car) { [unowned self] _, newValue in
            self.contentView.speedLabel.text = "\(newValue) mph"
        }
        contentView.presentButton.addTarget(self, action: #selector(presentNextScreen), for: .touchUpInside)
        contentView.increaseSpeedButton.addTarget(self, action: #selector(decreaseSpeed), for: .touchUpInside)
        contentView.increaseSpeedButton.addTarget(self, action: #selector(increaseSpeed), for: .touchUpInside)
    }

    override func loadView() {
        view = contentView
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
