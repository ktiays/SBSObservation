import UIKit

final class MainView: UIView {
    private let carLabel: UILabel = {
        let this = UILabel()
        this.text = "🚘"
        this.font = .systemFont(ofSize: 64)
        this.textAlignment = .center
        return this
    }()
    let speedLabel: UILabel = {
        let this = UILabel()
        this.text = "0 km/h"
        this.font = .monospacedDigitSystemFont(ofSize: 32, weight: .regular)
        this.textAlignment = .center
        return this
    }()
    let presentButton: UIButton = {
        let this = UIButton(configuration: .bordered())
        this.configuration?.title = "Present Speedometer"
        return this
    }()
    let decreaseSpeedButton: UIButton = {
        let this = UIButton(configuration: .borderedProminent())
        this.configuration?.image = UIImage(systemName: "arrowtriangle.down.square")
        return this
    }()
    let increaseSpeedButton: UIButton = {
        let this = UIButton(configuration: .borderedProminent())
        this.configuration?.image = UIImage(systemName: "arrowtriangle.up.square")
        return this
    }()
    private let speedStackView: UIStackView = {
        let this = UIStackView()
        this.translatesAutoresizingMaskIntoConstraints = false
        this.axis = .horizontal
        this.spacing = 40
        this.alignment = .center
        return this
    }()
    private let contentStackView: UIStackView = {
        let this = UIStackView()
        this.translatesAutoresizingMaskIntoConstraints = false
        this.axis = .vertical
        this.spacing = 40
        this.alignment = .center
        return this
    }()

    init() {
        super.init(frame: .zero)
        setupView()
        setupLayout()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupView() {
        backgroundColor = .systemBackground
        speedStackView.addArrangedSubview(decreaseSpeedButton)
        speedStackView.addArrangedSubview(speedLabel)
        speedStackView.addArrangedSubview(increaseSpeedButton)
        contentStackView.addArrangedSubview(carLabel)
        contentStackView.addArrangedSubview(speedStackView)
        contentStackView.addArrangedSubview(presentButton)
        contentStackView.setCustomSpacing(80, after: speedStackView)
        addSubview(contentStackView)
    }

    private func setupLayout() {
        NSLayoutConstraint.activate([
            contentStackView.leadingAnchor.constraint(equalTo: layoutMarginsGuide.leadingAnchor),
            contentStackView.trailingAnchor.constraint(equalTo: layoutMarginsGuide.trailingAnchor),
            contentStackView.topAnchor.constraint(greaterThanOrEqualTo: topAnchor),
            contentStackView.bottomAnchor.constraint(lessThanOrEqualTo: bottomAnchor),
            contentStackView.centerYAnchor.constraint(equalTo: centerYAnchor)
        ])
    }
}
