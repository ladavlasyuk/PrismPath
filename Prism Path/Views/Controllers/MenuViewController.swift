import UIKit

final class MenuViewController: UIViewController {
    private let viewModel = MenuViewModel()

    private let auraView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private let avatarView = AvatarView(side: 66, showsBadge: false)

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "PRISM\nPATH"
        label.font = UIFont.systemFont(ofSize: LayoutMetrics.isPad ? 64 : 52, weight: .black)
        label.textColor = .white
        label.textAlignment = .center
        label.numberOfLines = 2
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let subtitleLabel: UILabel = {
        let label = UILabel()
        label.text = "Guide the light. Wake the crystals."
        label.font = UIFont.systemFont(ofSize: LayoutMetrics.isPad ? 18 : 16, weight: .medium)
        label.textColor = UIColor.white.withAlphaComponent(0.7)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let progressLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: LayoutMetrics.isPad ? 16 : 14, weight: .semibold)
        label.textColor = UIColor.white.withAlphaComponent(0.55)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let playButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("SELECT CHAMBER", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: LayoutMetrics.isPad ? 20 : 19, weight: .bold)
        button.setTitleColor(.black, for: .normal)
        button.layer.cornerRadius = 26
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    private let statisticsButton = MenuViewController.makeSecondaryButton(title: "STATISTICS")
    private let recordsButton = MenuViewController.makeSecondaryButton(title: "RECORDS")
    private let settingsButton = MenuViewController.makeSecondaryButton(title: "SETTINGS")

    private let privacyButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Privacy Policy", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 14, weight: .semibold)
        button.setTitleColor(UIColor.white.withAlphaComponent(0.5), for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    private let contentStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.alignment = .center
        stack.spacing = 10
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()

    private var beamLayers: [CAShapeLayer] = []
    private var gradientLayer: CAGradientLayer?

    private static func makeSecondaryButton(title: String) -> UIButton {
        let button = UIButton(type: .system)
        button.setTitle(title, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: LayoutMetrics.isPad ? 16 : 15, weight: .semibold)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = UIColor.white.withAlphaComponent(0.12)
        button.layer.cornerRadius = 20
        button.layer.borderWidth = 1
        button.layer.borderColor = UIColor.white.withAlphaComponent(0.25).cgColor
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupActions()

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(themeDidChange),
            name: .themeDidChange,
            object: nil
        )

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(avatarDidChange),
            name: .avatarDidChange,
            object: nil
        )
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
        viewModel.refresh()
        updateProgressLabel()
        applyTheme()
        refreshAvatar()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        gradientLayer?.frame = auraView.bounds
        layoutBeams()
    }

    private func setupUI() {
        view.backgroundColor = ThemeManager.shared.backgroundColor

        view.addSubview(auraView)
        view.addSubview(avatarView)
        view.addSubview(contentStack)
        view.addSubview(privacyButton)

        contentStack.addArrangedSubview(titleLabel)
        contentStack.addArrangedSubview(subtitleLabel)
        contentStack.addArrangedSubview(progressLabel)
        contentStack.addArrangedSubview(playButton)
        contentStack.addArrangedSubview(statisticsButton)
        contentStack.addArrangedSubview(recordsButton)
        contentStack.addArrangedSubview(settingsButton)

        contentStack.setCustomSpacing(LayoutMetrics.isPad ? 14 : 10, after: titleLabel)
        contentStack.setCustomSpacing(8, after: subtitleLabel)
        contentStack.setCustomSpacing(LayoutMetrics.isPad ? 36 : 28, after: progressLabel)
        contentStack.setCustomSpacing(LayoutMetrics.isPad ? 16 : 14, after: playButton)
        contentStack.setCustomSpacing(12, after: statisticsButton)
        contentStack.setCustomSpacing(12, after: recordsButton)

        NSLayoutConstraint.activate([
            auraView.topAnchor.constraint(equalTo: view.topAnchor),
            auraView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            auraView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            auraView.heightAnchor.constraint(
                equalTo: view.heightAnchor,
                multiplier: LayoutMetrics.menuAuraHeightMultiplier
            ),

            avatarView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 12),
            avatarView.leadingAnchor.constraint(
                equalTo: view.safeAreaLayoutGuide.leadingAnchor,
                constant: LayoutMetrics.horizontalInset
            ),

            contentStack.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            contentStack.centerYAnchor.constraint(
                equalTo: view.safeAreaLayoutGuide.centerYAnchor,
                constant: LayoutMetrics.isPad ? -8 : 0
            ),
            contentStack.leadingAnchor.constraint(
                greaterThanOrEqualTo: view.leadingAnchor,
                constant: LayoutMetrics.horizontalInset
            ),
            contentStack.trailingAnchor.constraint(
                lessThanOrEqualTo: view.trailingAnchor,
                constant: -LayoutMetrics.horizontalInset
            ),
            contentStack.topAnchor.constraint(
                greaterThanOrEqualTo: avatarView.bottomAnchor,
                constant: 16
            ),
            contentStack.bottomAnchor.constraint(
                lessThanOrEqualTo: privacyButton.topAnchor,
                constant: -16
            ),

            playButton.widthAnchor.constraint(equalToConstant: LayoutMetrics.menuPrimaryWidth),
            playButton.heightAnchor.constraint(equalToConstant: 52),

            statisticsButton.widthAnchor.constraint(equalToConstant: LayoutMetrics.menuSecondaryWidth),
            statisticsButton.heightAnchor.constraint(equalToConstant: 40),

            recordsButton.widthAnchor.constraint(equalToConstant: LayoutMetrics.menuSecondaryWidth),
            recordsButton.heightAnchor.constraint(equalToConstant: 40),

            settingsButton.widthAnchor.constraint(equalToConstant: LayoutMetrics.menuSecondaryWidth),
            settingsButton.heightAnchor.constraint(equalToConstant: 40),

            privacyButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            privacyButton.bottomAnchor.constraint(
                equalTo: view.safeAreaLayoutGuide.bottomAnchor,
                constant: -18
            )
        ])

        buildAura()
        applyTheme()
        updateProgressLabel()
    }

    private func buildAura() {
        let gradient = CAGradientLayer()
        gradient.colors = [
            ThemeManager.shared.primaryColor.withAlphaComponent(0.35).cgColor,
            ThemeManager.shared.backgroundColor.cgColor
        ]
        gradient.startPoint = CGPoint(x: 0.5, y: 0)
        gradient.endPoint = CGPoint(x: 0.5, y: 1)
        auraView.layer.insertSublayer(gradient, at: 0)
        gradientLayer = gradient

        for index in 0..<4 {
            let layer = CAShapeLayer()
            layer.strokeColor = (index % 2 == 0
                ? ThemeManager.shared.highlightColor
                : UIColor.white).withAlphaComponent(0.35).cgColor
            layer.lineWidth = 2
            layer.lineCap = .round
            layer.fillColor = UIColor.clear.cgColor
            auraView.layer.addSublayer(layer)
            beamLayers.append(layer)

            let flicker = CABasicAnimation(keyPath: "opacity")
            flicker.fromValue = 0.25
            flicker.toValue = 0.85
            flicker.duration = 2.2 + Double(index) * 0.6
            flicker.autoreverses = true
            flicker.repeatCount = .infinity
            layer.add(flicker, forKey: "flicker")
        }
    }

    private func layoutBeams() {
        guard auraView.bounds.width > 0 else { return }
        let bounds = auraView.bounds

        for (index, layer) in beamLayers.enumerated() {
            let path = UIBezierPath()
            let startY = bounds.height * (0.20 + CGFloat(index) * 0.16)
            path.move(to: CGPoint(x: 0, y: startY))
            path.addLine(to: CGPoint(x: bounds.width * 0.34, y: startY))
            path.addLine(to: CGPoint(x: bounds.width * 0.62, y: startY - bounds.height * 0.14))
            path.addLine(to: CGPoint(x: bounds.width, y: startY - bounds.height * 0.14))
            layer.path = path.cgPath
        }
    }

    private func applyTheme() {
        view.backgroundColor = ThemeManager.shared.backgroundColor
        playButton.backgroundColor = ThemeManager.shared.primaryColor
        gradientLayer?.colors = [
            ThemeManager.shared.primaryColor.withAlphaComponent(0.35).cgColor,
            ThemeManager.shared.backgroundColor.cgColor
        ]
        for (index, layer) in beamLayers.enumerated() {
            layer.strokeColor = (index % 2 == 0
                ? ThemeManager.shared.highlightColor
                : UIColor.white).withAlphaComponent(0.35).cgColor
        }
    }

    private func updateProgressLabel() {
        progressLabel.text = "★ \(viewModel.starsText)   ·   \(viewModel.summaryText)"
    }

    private func setupActions() {
        playButton.addTarget(self, action: #selector(playTapped), for: .touchUpInside)
        statisticsButton.addTarget(self, action: #selector(statisticsTapped), for: .touchUpInside)
        recordsButton.addTarget(self, action: #selector(recordsTapped), for: .touchUpInside)
        settingsButton.addTarget(self, action: #selector(settingsTapped), for: .touchUpInside)
        privacyButton.addTarget(self, action: #selector(privacyTapped), for: .touchUpInside)
        avatarView.onTap = { [weak self] in
            self?.navigationController?.pushViewController(SettingsViewController(), animated: true)
        }
    }

    private func refreshAvatar() {
        avatarView.applyTheme()
        avatarView.setImage(DataManager.shared.loadAvatar())
    }

    @objc private func playTapped() {
        HapticsManager.shared.mediumImpact()
        navigationController?.pushViewController(LevelSelectViewController(), animated: true)
    }

    @objc private func statisticsTapped() {
        HapticsManager.shared.lightImpact()
        navigationController?.pushViewController(DetailedStatisticsViewController(), animated: true)
    }

    @objc private func recordsTapped() {
        HapticsManager.shared.lightImpact()
        navigationController?.pushViewController(HighScoresViewController(), animated: true)
    }

    @objc private func settingsTapped() {
        HapticsManager.shared.lightImpact()
        navigationController?.pushViewController(SettingsViewController(), animated: true)
    }

    @objc private func privacyTapped() {
        HapticsManager.shared.selection()
        let policyController = PrivacyPolicyViewController(addressString: AppConstants.privacyPolicyAddress)
        let container = UINavigationController(rootViewController: policyController)
        present(container, animated: true)
    }

    @objc private func themeDidChange() {
        applyTheme()
        refreshAvatar()
    }

    @objc private func avatarDidChange() {
        refreshAvatar()
    }

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        .portrait
    }

    override var prefersStatusBarHidden: Bool {
        true
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}
