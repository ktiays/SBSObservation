import UIKit

final class MainView: UIView {
    let speedLabel: UILabel = {
        let this = UILabel()
        this.text = "0 mph"
        this.font = .preferredFont(forTextStyle: .title1)
        this.textAlignment = .center
        return this
    }()
    let presentButton: UIButton = {
        let this = UIButton(configuration: .bordered())
        this.configuration?.title = "Present"
        return this
    }()
    private let stackView: UIStackView = {
        let this = UIStackView()
        this.translatesAutoresizingMaskIntoConstraints = false
        this.axis = .vertical
        this.spacing = 20
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
        stackView.addArrangedSubview(speedLabel)
        stackView.addArrangedSubview(presentButton)
        addSubview(stackView)
    }

    private func setupLayout() {
        NSLayoutConstraint.activate([
            stackView.leadingAnchor.constraint(equalTo: layoutMarginsGuide.leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: layoutMarginsGuide.trailingAnchor),
            stackView.topAnchor.constraint(greaterThanOrEqualTo: topAnchor),
            stackView.bottomAnchor.constraint(lessThanOrEqualTo: bottomAnchor),
            stackView.centerYAnchor.constraint(equalTo: centerYAnchor)
        ])
    }
}
