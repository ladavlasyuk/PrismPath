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
        label.font = UIFont.systemFont(ofSize: 52, weight: .black)
        label.textColor = .white
        label.textAlignment = .center
        label.numberOfLines = 2
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let subtitleLabel: UILabel = {
        let label = UILabel()
        label.text = "Guide the light. Wake the crystals."
        label.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        label.textColor = UIColor.white.withAlphaComponent(0.7)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let progressLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14, weight: .semibold)
        label.textColor = UIColor.white.withAlphaComponent(0.55)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let playButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("SELECT CHAMBER", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 19, weight: .bold)
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

    private var beamLayers: [CAShapeLayer] = []
    private var gradientLayer: CAGradientLayer?

    private static func makeSecondaryButton(title: String) -> UIButton {
        let button = UIButton(type: .system)
        button.setTitle(title, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 15, weight: .semibold)
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
        view.addSubview(titleLabel)
        view.addSubview(subtitleLabel)
        view.addSubview(progressLabel)
        view.addSubview(playButton)
        view.addSubview(statisticsButton)
        view.addSubview(recordsButton)
        view.addSubview(settingsButton)
        view.addSubview(privacyButton)

        NSLayoutConstraint.activate([
            auraView.topAnchor.constraint(equalTo: view.topAnchor),
            auraView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            auraView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            auraView.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 0.42),

            avatarView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 12),
            avatarView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),

            titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            titleLabel.topAnchor.constraint(equalTo: auraView.bottomAnchor, constant: 24),

            subtitleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            subtitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 10),

            progressLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            progressLabel.topAnchor.constraint(equalTo: subtitleLabel.bottomAnchor, constant: 8),

            playButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            playButton.bottomAnchor.constraint(equalTo: statisticsButton.topAnchor, constant: -18),
            playButton.widthAnchor.constraint(equalToConstant: 240),
            playButton.heightAnchor.constraint(equalToConstant: 52),

            statisticsButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            statisticsButton.bottomAnchor.constraint(equalTo: recordsButton.topAnchor, constant: -12),
            statisticsButton.widthAnchor.constraint(equalToConstant: 190),
            statisticsButton.heightAnchor.constraint(equalToConstant: 40),

            recordsButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            recordsButton.bottomAnchor.constraint(equalTo: settingsButton.topAnchor, constant: -12),
            recordsButton.widthAnchor.constraint(equalToConstant: 190),
            recordsButton.heightAnchor.constraint(equalToConstant: 40),

            settingsButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            settingsButton.bottomAnchor.constraint(equalTo: privacyButton.topAnchor, constant: -22),
            settingsButton.widthAnchor.constraint(equalToConstant: 190),
            settingsButton.heightAnchor.constraint(equalToConstant: 40),

            privacyButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            privacyButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -18)
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
