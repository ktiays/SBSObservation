import RunestoneObservationMacro
import UIKit

@RunestoneObserver
final class MainViewController: UIViewController {
    private let car = Car()
    private let contentView = MainView()

    override func viewDidLoad() {
        super.viewDidLoad()
        observe(\.speed, of: car) { [unowned self] _, newValue in
            self.contentView.speedLabel.text = "\(newValue) mph"
        }
        contentView.presentButton.addTarget(self, action: #selector(presentNextScreen), for: .touchUpInside)
        car.drive()
    }

    override func loadView() {
        view = contentView
    }

    @objc private func presentNextScreen() {
        let viewController = MainViewController()
        navigationController?.pushViewController(viewController, animated: true)
    }
}
