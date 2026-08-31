import UIKit

final class StatisticsViewController: UIViewController {
    var onReplay: (() -> Void)?
    var onContinue: (() -> Void)?

    private let viewModel: StatisticsViewModel

    private let card: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(white: 1.0, alpha: 0.08)
        view.layer.cornerRadius = 24
        view.layer.borderWidth = 1
        view.layer.borderColor = UIColor.white.withAlphaComponent(0.15).cgColor
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private let headlineLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 24, weight: .black)
        label.textColor = .white
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let starsLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 34, weight: .bold)
        label.textColor = UIColor(red: 1.0, green: 0.84, blue: 0.30, alpha: 1.0)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let ratingLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 15, weight: .semibold)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let rowsStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 10
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()

    private let replayButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("TRY AGAIN", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .bold)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = UIColor.white.withAlphaComponent(0.14)
        button.layer.cornerRadius = 22
        button.layer.borderWidth = 1
        button.layer.borderColor = UIColor.white.withAlphaComponent(0.25).cgColor
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    private let continueButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("CONTINUE", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .bold)
        button.setTitleColor(.black, for: .normal)
        button.layer.cornerRadius = 22
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    init(statistics: GameStatistics) {
        self.viewModel = StatisticsViewModel(statistics: statistics)
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        populate()
        animateEntrance()
    }

    private func setupUI() {
        view.backgroundColor = ThemeManager.shared.deepBackgroundColor.withAlphaComponent(0.96)

        view.addSubview(card)
        card.addSubview(headlineLabel)
        card.addSubview(starsLabel)
        card.addSubview(ratingLabel)
        card.addSubview(rowsStack)
        view.addSubview(replayButton)
        view.addSubview(continueButton)

        continueButton.backgroundColor = ThemeManager.shared.primaryColor
        ratingLabel.textColor = ThemeManager.shared.highlightColor

        var constraints: [NSLayoutConstraint] = [
            card.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -30),
            card.centerXAnchor.constraint(equalTo: view.centerXAnchor),

            headlineLabel.topAnchor.constraint(equalTo: card.topAnchor, constant: 24),
            headlineLabel.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 16),
            headlineLabel.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -16),

            starsLabel.topAnchor.constraint(equalTo: headlineLabel.bottomAnchor, constant: 10),
            starsLabel.centerXAnchor.constraint(equalTo: card.centerXAnchor),

            ratingLabel.topAnchor.constraint(equalTo: starsLabel.bottomAnchor, constant: 4),
            ratingLabel.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 16),
            ratingLabel.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -16),

            rowsStack.topAnchor.constraint(equalTo: ratingLabel.bottomAnchor, constant: 22),
            rowsStack.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 22),
            rowsStack.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -22),
            rowsStack.bottomAnchor.constraint(equalTo: card.bottomAnchor, constant: -26),

            replayButton.topAnchor.constraint(equalTo: card.bottomAnchor, constant: 24),
            replayButton.leadingAnchor.constraint(equalTo: card.leadingAnchor),
            replayButton.widthAnchor.constraint(equalTo: continueButton.widthAnchor),
            replayButton.heightAnchor.constraint(equalToConstant: 48),

            continueButton.topAnchor.constraint(equalTo: card.bottomAnchor, constant: 24),
            continueButton.leadingAnchor.constraint(equalTo: replayButton.trailingAnchor, constant: 14),
            continueButton.trailingAnchor.constraint(equalTo: card.trailingAnchor),
            continueButton.heightAnchor.constraint(equalToConstant: 48)
        ]

        constraints += LayoutMetrics.constrainContentWidth(of: card, in: view, inset: 24)

        NSLayoutConstraint.activate(constraints)

        replayButton.addTarget(self, action: #selector(replayTapped), for: .touchUpInside)
        continueButton.addTarget(self, action: #selector(continueTapped), for: .touchUpInside)
    }

    private func populate() {
        headlineLabel.text = viewModel.headline
        starsLabel.text = viewModel.starsText
        ratingLabel.text = viewModel.ratingText

        for (title, value) in viewModel.rows {
            rowsStack.addArrangedSubview(makeRow(title: title, value: value))
        }
    }

    private func makeRow(title: String, value: String) -> UIView {
        let row = UIView()
        row.translatesAutoresizingMaskIntoConstraints = false

        let titleLabel = UILabel()
        titleLabel.text = title
        titleLabel.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        titleLabel.textColor = UIColor.white.withAlphaComponent(0.6)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false

        let valueLabel = UILabel()
        valueLabel.text = value
        valueLabel.font = UIFont.systemFont(ofSize: 14, weight: .bold)
        valueLabel.textColor = .white
        valueLabel.textAlignment = .right
        valueLabel.translatesAutoresizingMaskIntoConstraints = false

        row.addSubview(titleLabel)
        row.addSubview(valueLabel)

        NSLayoutConstraint.activate([
            row.heightAnchor.constraint(equalToConstant: 20),
            titleLabel.leadingAnchor.constraint(equalTo: row.leadingAnchor),
            titleLabel.centerYAnchor.constraint(equalTo: row.centerYAnchor),
            valueLabel.trailingAnchor.constraint(equalTo: row.trailingAnchor),
            valueLabel.centerYAnchor.constraint(equalTo: row.centerYAnchor),
            valueLabel.leadingAnchor.constraint(greaterThanOrEqualTo: titleLabel.trailingAnchor, constant: 8)
        ])

        return row
    }

    private func animateEntrance() {
        card.alpha = 0
        card.transform = CGAffineTransform(scaleX: 0.92, y: 0.92)
        UIView.animate(withDuration: 0.35, delay: 0.05, options: .curveEaseOut) {
            self.card.alpha = 1
            self.card.transform = .identity
        }
    }

    @objc private func replayTapped() {
        HapticsManager.shared.mediumImpact()
        dismiss(animated: true) { [weak self] in
            self?.onReplay?()
        }
    }

    @objc private func continueTapped() {
        HapticsManager.shared.lightImpact()
        dismiss(animated: true) { [weak self] in
            self?.onContinue?()
        }
    }

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        .portrait
    }

    override var prefersStatusBarHidden: Bool {
        true
    }
}
