import UIKit

final class SettingsViewController: UIViewController {
    private let viewModel = SettingsViewModel()

    private let scrollView: UIScrollView = {
        let view = UIScrollView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private let contentView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "SETTINGS"
        label.font = UIFont.systemFont(ofSize: 26, weight: .black)
        label.textColor = .white
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let backButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("← BACK", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 15, weight: .semibold)
        button.setTitleColor(.white, for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    private let playerLabel: UILabel = {
        let label = UILabel()
        label.text = "PLAYER"
        label.font = UIFont.systemFont(ofSize: 13, weight: .bold)
        label.textColor = UIColor.white.withAlphaComponent(0.6)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let playerCard: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(white: 1.0, alpha: 0.07)
        view.layer.cornerRadius = 16
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private let avatarView = AvatarView(side: 76, showsBadge: true)

    private let avatarTitleLabel: UILabel = {
        let label = UILabel()
        label.text = "Portrait"
        label.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        label.textColor = .white
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let avatarHintLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 12, weight: .medium)
        label.textColor = UIColor.white.withAlphaComponent(0.55)
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let avatarButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("CHANGE", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 13, weight: .bold)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = UIColor.white.withAlphaComponent(0.12)
        button.layer.cornerRadius = 15
        button.layer.borderWidth = 1
        button.layer.borderColor = UIColor.white.withAlphaComponent(0.25).cgColor
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    private let themeLabel: UILabel = {
        let label = UILabel()
        label.text = "LIGHT PALETTE"
        label.font = UIFont.systemFont(ofSize: 13, weight: .bold)
        label.textColor = UIColor.white.withAlphaComponent(0.6)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let themeCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumInteritemSpacing = 12
        layout.itemSize = CGSize(width: 62, height: 82)

        let view = UICollectionView(frame: .zero, collectionViewLayout: layout)
        view.backgroundColor = .clear
        view.showsHorizontalScrollIndicator = false
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private let hapticsToggle: SettingsToggleView = {
        let toggle = SettingsToggleView()
        toggle.configure(title: "Haptic Feedback", icon: "◈")
        toggle.translatesAutoresizingMaskIntoConstraints = false
        return toggle
    }()

    private let soundToggle: SettingsToggleView = {
        let toggle = SettingsToggleView()
        toggle.configure(title: "Sound Effects", icon: "♪")
        toggle.translatesAutoresizingMaskIntoConstraints = false
        return toggle
    }()

    private let trailToggle: SettingsToggleView = {
        let toggle = SettingsToggleView()
        toggle.configure(title: "Beam Sparks", icon: "✦")
        toggle.translatesAutoresizingMaskIntoConstraints = false
        return toggle
    }()

    private let resetButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("RESET ALL DATA", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .bold)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = UIColor(red: 0.78, green: 0.24, blue: 0.28, alpha: 1.0)
        button.layer.cornerRadius = 12
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    private let resetWarningLabel: UILabel = {
        let label = UILabel()
        label.text = "This clears every chamber record, statistic and preference."
        label.font = UIFont.systemFont(ofSize: 12, weight: .regular)
        label.textColor = UIColor.white.withAlphaComponent(0.5)
        label.textAlignment = .center
        label.numberOfLines = 2
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupActions()
        themeCollectionView.delegate = self
        themeCollectionView.dataSource = self
        themeCollectionView.register(PaletteCell.self, forCellWithReuseIdentifier: PaletteCell.identifier)
        viewModel.delegate = self
        updateToggles()
        updateAvatar()

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(themeDidChange),
            name: .themeDidChange,
            object: nil
        )
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }

    private func setupUI() {
        view.backgroundColor = ThemeManager.shared.backgroundColor

        view.addSubview(backButton)
        view.addSubview(titleLabel)
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)

        contentView.addSubview(playerLabel)
        contentView.addSubview(playerCard)
        playerCard.addSubview(avatarView)
        playerCard.addSubview(avatarTitleLabel)
        playerCard.addSubview(avatarHintLabel)
        playerCard.addSubview(avatarButton)
        contentView.addSubview(themeLabel)
        contentView.addSubview(themeCollectionView)
        contentView.addSubview(hapticsToggle)
        contentView.addSubview(soundToggle)
        contentView.addSubview(trailToggle)
        contentView.addSubview(resetButton)
        contentView.addSubview(resetWarningLabel)

        NSLayoutConstraint.activate([
            backButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 14),
            backButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),

            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 14),
            titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),

            scrollView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 24),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),

            playerLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            playerLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),

            playerCard.topAnchor.constraint(equalTo: playerLabel.bottomAnchor, constant: 12),
            playerCard.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            playerCard.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),

            avatarView.leadingAnchor.constraint(equalTo: playerCard.leadingAnchor, constant: 16),
            avatarView.centerYAnchor.constraint(equalTo: playerCard.centerYAnchor),
            avatarView.topAnchor.constraint(greaterThanOrEqualTo: playerCard.topAnchor, constant: 16),
            avatarView.bottomAnchor.constraint(lessThanOrEqualTo: playerCard.bottomAnchor, constant: -16),

            avatarTitleLabel.leadingAnchor.constraint(equalTo: avatarView.trailingAnchor, constant: 16),
            avatarTitleLabel.topAnchor.constraint(equalTo: playerCard.topAnchor, constant: 16),
            avatarTitleLabel.trailingAnchor.constraint(lessThanOrEqualTo: playerCard.trailingAnchor, constant: -16),

            avatarHintLabel.leadingAnchor.constraint(equalTo: avatarTitleLabel.leadingAnchor),
            avatarHintLabel.topAnchor.constraint(equalTo: avatarTitleLabel.bottomAnchor, constant: 4),
            avatarHintLabel.trailingAnchor.constraint(equalTo: playerCard.trailingAnchor, constant: -16),

            avatarButton.leadingAnchor.constraint(equalTo: avatarTitleLabel.leadingAnchor),
            avatarButton.topAnchor.constraint(greaterThanOrEqualTo: avatarHintLabel.bottomAnchor, constant: 10),
            avatarButton.bottomAnchor.constraint(equalTo: playerCard.bottomAnchor, constant: -16),
            avatarButton.widthAnchor.constraint(equalToConstant: 104),
            avatarButton.heightAnchor.constraint(equalToConstant: 30),

            themeLabel.topAnchor.constraint(equalTo: playerCard.bottomAnchor, constant: 26),
            themeLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),

            themeCollectionView.topAnchor.constraint(equalTo: themeLabel.bottomAnchor, constant: 12),
            themeCollectionView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            themeCollectionView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            themeCollectionView.heightAnchor.constraint(equalToConstant: 90),

            hapticsToggle.topAnchor.constraint(equalTo: themeCollectionView.bottomAnchor, constant: 26),
            hapticsToggle.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            hapticsToggle.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            hapticsToggle.heightAnchor.constraint(equalToConstant: 58),

            soundToggle.topAnchor.constraint(equalTo: hapticsToggle.bottomAnchor, constant: 12),
            soundToggle.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            soundToggle.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            soundToggle.heightAnchor.constraint(equalToConstant: 58),

            trailToggle.topAnchor.constraint(equalTo: soundToggle.bottomAnchor, constant: 12),
            trailToggle.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            trailToggle.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            trailToggle.heightAnchor.constraint(equalToConstant: 58),

            resetButton.topAnchor.constraint(equalTo: trailToggle.bottomAnchor, constant: 44),
            resetButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 40),
            resetButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -40),
            resetButton.heightAnchor.constraint(equalToConstant: 50),

            resetWarningLabel.topAnchor.constraint(equalTo: resetButton.bottomAnchor, constant: 12),
            resetWarningLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 40),
            resetWarningLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -40),
            resetWarningLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -40)
        ])
    }

    private func setupActions() {
        backButton.addTarget(self, action: #selector(backTapped), for: .touchUpInside)
        resetButton.addTarget(self, action: #selector(resetTapped), for: .touchUpInside)
        avatarButton.addTarget(self, action: #selector(avatarTapped), for: .touchUpInside)
        avatarView.onTap = { [weak self] in
            self?.presentAvatarOptions()
        }

        hapticsToggle.onToggle = { [weak self] in
            self?.viewModel.toggleHaptics()
        }
        soundToggle.onToggle = { [weak self] in
            self?.viewModel.toggleSound()
        }
        trailToggle.onToggle = { [weak self] in
            self?.viewModel.toggleBeamTrail()
        }
    }

    private func updateToggles() {
        hapticsToggle.setOn(viewModel.isHapticsEnabled)
        soundToggle.setOn(viewModel.isSoundEnabled)
        trailToggle.setOn(viewModel.showsBeamTrail)
    }

    private func updateAvatar() {
        avatarView.applyTheme()
        avatarView.setImage(viewModel.avatar)
        avatarHintLabel.text = viewModel.hasAvatar
            ? "Your portrait is stored on this device only."
            : "Take a photo with the camera or pick one from the library."
        avatarButton.setTitle(viewModel.hasAvatar ? "CHANGE" : "ADD", for: .normal)
    }

    @objc private func avatarTapped() {
        presentAvatarOptions()
    }

    private func presentAvatarOptions() {
        let sheet = UIAlertController(
            title: "Player Portrait",
            message: nil,
            preferredStyle: .actionSheet
        )

        sheet.addAction(UIAlertAction(title: "Take Photo", style: .default) { [weak self] _ in
            guard let self else { return }
            AvatarCaptureCoordinator.shared.captureFromCamera(host: self) { image in
                self.applyPickedAvatar(image)
            }
        })

        sheet.addAction(UIAlertAction(title: "Choose from Library", style: .default) { [weak self] _ in
            guard let self else { return }
            AvatarCaptureCoordinator.shared.pickFromLibrary(host: self) { image in
                self.applyPickedAvatar(image)
            }
        })

        if viewModel.hasAvatar {
            sheet.addAction(UIAlertAction(title: "Remove Portrait", style: .destructive) { [weak self] _ in
                HapticsManager.shared.warning()
                self?.viewModel.clearAvatar()
                self?.updateAvatar()
            })
        }

        sheet.addAction(UIAlertAction(title: "Cancel", style: .cancel))

        if let popover = sheet.popoverPresentationController {
            popover.sourceView = avatarView
            popover.sourceRect = avatarView.bounds
        }

        present(sheet, animated: true)
    }

    private func applyPickedAvatar(_ image: UIImage) {
        viewModel.updateAvatar(image)
        HapticsManager.shared.success()
        updateAvatar()
    }

    @objc private func backTapped() {
        HapticsManager.shared.selection()
        navigationController?.popViewController(animated: true)
    }

    @objc private func resetTapped() {
        viewModel.requestReset()
    }

    @objc private func themeDidChange() {
        view.backgroundColor = ThemeManager.shared.backgroundColor
        themeCollectionView.reloadData()
        updateToggles()
        avatarView.applyTheme()
    }

    private func showResetConfirmation() {
        let alert = UIAlertController(
            title: "Reset All Data?",
            message: "This cannot be undone. Every chamber record and statistic will be removed.",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alert.addAction(UIAlertAction(title: "Reset", style: .destructive) { [weak self] _ in
            self?.viewModel.confirmReset()
        })
        present(alert, animated: true)
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

extension SettingsViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        viewModel.allThemes.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: PaletteCell.identifier,
            for: indexPath
        ) as? PaletteCell else {
            return UICollectionViewCell()
        }
        let theme = viewModel.allThemes[indexPath.item]
        cell.configure(with: theme, isSelected: theme == viewModel.currentTheme)
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        HapticsManager.shared.lightImpact()
        viewModel.setColorTheme(viewModel.allThemes[indexPath.item])
    }
}

extension SettingsViewController: SettingsViewModelDelegate {
    func settingsDidChange() {
        updateToggles()
        themeCollectionView.reloadData()
        view.backgroundColor = ThemeManager.shared.backgroundColor
    }

    func didRequestResetConfirmation() {
        showResetConfirmation()
    }

    func didCompleteReset() {
        updateToggles()
        updateAvatar()
        themeCollectionView.reloadData()

        let alert = UIAlertController(
            title: "Data Cleared",
            message: "Everything is back to its first light.",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}

final class PaletteCell: UICollectionViewCell {
    static let identifier = "PaletteCell"

    private let swatch: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 25
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private let nameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 10, weight: .medium)
        label.textColor = .white
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let checkmark: UILabel = {
        let label = UILabel()
        label.text = "✓"
        label.font = UIFont.systemFont(ofSize: 20, weight: .bold)
        label.textColor = .black
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        label.isHidden = true
        return label
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupCell()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupCell() {
        contentView.addSubview(swatch)
        contentView.addSubview(nameLabel)
        swatch.addSubview(checkmark)

        NSLayoutConstraint.activate([
            swatch.topAnchor.constraint(equalTo: contentView.topAnchor),
            swatch.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            swatch.widthAnchor.constraint(equalToConstant: 50),
            swatch.heightAnchor.constraint(equalToConstant: 50),

            nameLabel.topAnchor.constraint(equalTo: swatch.bottomAnchor, constant: 6),
            nameLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            nameLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),

            checkmark.centerXAnchor.constraint(equalTo: swatch.centerXAnchor),
            checkmark.centerYAnchor.constraint(equalTo: swatch.centerYAnchor)
        ])
    }

    func configure(with theme: AppColorTheme, isSelected: Bool) {
        swatch.backgroundColor = theme.primaryColor
        nameLabel.text = theme.displayName
        checkmark.isHidden = !isSelected
        swatch.layer.borderWidth = isSelected ? 3 : 0
        swatch.layer.borderColor = UIColor.white.cgColor
    }
}

final class SettingsToggleView: UIView {
    var onToggle: (() -> Void)?

    private let container: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(white: 1.0, alpha: 0.07)
        view.layer.cornerRadius = 12
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private let iconLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 20, weight: .semibold)
        label.textColor = .white
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        label.textColor = .white
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let control: UISwitch = {
        let control = UISwitch()
        control.translatesAutoresizingMaskIntoConstraints = false
        return control
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupView() {
        addSubview(container)
        container.addSubview(iconLabel)
        container.addSubview(titleLabel)
        container.addSubview(control)

        NSLayoutConstraint.activate([
            container.topAnchor.constraint(equalTo: topAnchor),
            container.leadingAnchor.constraint(equalTo: leadingAnchor),
            container.trailingAnchor.constraint(equalTo: trailingAnchor),
            container.bottomAnchor.constraint(equalTo: bottomAnchor),

            iconLabel.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 18),
            iconLabel.centerYAnchor.constraint(equalTo: container.centerYAnchor),

            titleLabel.leadingAnchor.constraint(equalTo: iconLabel.trailingAnchor, constant: 14),
            titleLabel.centerYAnchor.constraint(equalTo: container.centerYAnchor),

            control.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -16),
            control.centerYAnchor.constraint(equalTo: container.centerYAnchor)
        ])

        control.addTarget(self, action: #selector(valueChanged), for: .valueChanged)
    }

    func configure(title: String, icon: String) {
        titleLabel.text = title
        iconLabel.text = icon
    }

    func setOn(_ isOn: Bool) {
        control.isOn = isOn
        control.onTintColor = ThemeManager.shared.primaryColor
    }

    @objc private func valueChanged() {
        onToggle?()
    }
}
