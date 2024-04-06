import RunestoneObservation
import UIKit

@RunestoneObserver
final class MainViewController<CarType: Car>: UIViewController {
    private let carA: CarType
    private let carB: CarType
    private let contentView = MainView()

    init(carA: CarType, carB: CarType) {
        self.carA = carA
        self.carB = carB
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        observe(carA.speed) { [unowned self] oldValue, newValue in
            print("A \(oldValue) => \(newValue)")
        }
        observe(carB.speed) { [unowned self] oldValue, newValue in
            print("B \(oldValue) => \(newValue)")
        }
        contentView.presentButton.addTarget(self, action: #selector(presentNextScreen), for: .touchUpInside)
        contentView.decreaseSpeedButton.addTarget(self, action: #selector(decreaseSpeed), for: .touchUpInside)
        contentView.increaseSpeedButton.addTarget(self, action: #selector(increaseSpeed), for: .touchUpInside)
        speedUp()
    }

    override func loadView() {
        view = contentView
    }

    private func speedUp() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) { [weak self] in
            self?.carA.increaseSpeed()
//            self?.carB.increaseSpeed()
            self?.speedUp()
        }
    }

    @objc private func decreaseSpeed() {
        carA.decreaseSpeed()
    }

    @objc private func increaseSpeed() {
        carA.increaseSpeed()
    }

    @objc private func presentNextScreen() {
        let viewController = MainViewController(carA: carA, carB: carB)
        navigationController?.pushViewController(viewController, animated: true)
    }
}
