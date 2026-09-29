import UIKit

final class LevelSelectViewController: UIViewController {
    private let viewModel = LevelSelectViewModel()

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "CHAMBERS"
        label.font = UIFont.systemFont(ofSize: 26, weight: .black)
        label.textColor = .white
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let starsLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 15, weight: .semibold)
        label.textColor = UIColor(red: 1.0, green: 0.84, blue: 0.30, alpha: 1.0)
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

    private let collectionView: UICollectionView = {
        let inset = LayoutMetrics.horizontalInset
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.minimumLineSpacing = 16
        layout.minimumInteritemSpacing = 16
        layout.sectionInset = UIEdgeInsets(top: 20, left: inset, bottom: 30, right: inset)

        let view = UICollectionView(frame: .zero, collectionViewLayout: layout)
        view.backgroundColor = .clear
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(ChamberCell.self, forCellWithReuseIdentifier: ChamberCell.identifier)
        backButton.addTarget(self, action: #selector(backTapped), for: .touchUpInside)
        viewModel.delegate = self
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
        view.backgroundColor = ThemeManager.shared.backgroundColor
        viewModel.refreshData()
        collectionView.reloadData()
        updateStarsLabel()
    }

    private func setupUI() {
        view.backgroundColor = ThemeManager.shared.backgroundColor

        view.addSubview(backButton)
        view.addSubview(titleLabel)
        view.addSubview(starsLabel)
        view.addSubview(collectionView)

        NSLayoutConstraint.activate([
            backButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 14),
            backButton.leadingAnchor.constraint(
                equalTo: view.safeAreaLayoutGuide.leadingAnchor,
                constant: LayoutMetrics.horizontalInset
            ),

            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 14),
            titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),

            starsLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 8),
            starsLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),

            collectionView.topAnchor.constraint(equalTo: starsLabel.bottomAnchor, constant: 6),
            collectionView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }

    private func updateStarsLabel() {
        starsLabel.text = "★ \(viewModel.totalStars) / \(viewModel.maxStars)"
    }

    @objc private func backTapped() {
        HapticsManager.shared.selection()
        navigationController?.popViewController(animated: true)
    }

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        .portrait
    }

    override var prefersStatusBarHidden: Bool {
        true
    }
}

extension LevelSelectViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        viewModel.items.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: ChamberCell.identifier,
            for: indexPath
        ) as? ChamberCell, let item = viewModel.item(at: indexPath.item) else {
            return UICollectionViewCell()
        }
        cell.configure(with: item)
        return cell
    }

    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAt indexPath: IndexPath
    ) -> CGSize {
        let columns = CGFloat(LayoutMetrics.chamberColumnCount)
        let inset = LayoutMetrics.horizontalInset
        let spacing: CGFloat = 16
        let available = collectionView.bounds.width - (inset * 2) - (spacing * (columns - 1))
        let width = floor(available / columns)
        return CGSize(width: width, height: LayoutMetrics.isPad ? 160 : 148)
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        viewModel.selectLevel(at: indexPath.item)
    }
}

extension LevelSelectViewController: LevelSelectViewModelDelegate {
    func didSelectLevel(_ level: LevelModel) {
        HapticsManager.shared.mediumImpact()
        let gameController = GameViewController()
        gameController.selectedLevel = level
        navigationController?.pushViewController(gameController, animated: true)
    }

    func levelsDidUpdate() {
        collectionView.reloadData()
        updateStarsLabel()
    }

    func didSelectLockedLevel() {
        HapticsManager.shared.warning()
        let alert = UIAlertController(
            title: "Chamber Sealed",
            message: "Clear the previous chamber to open this one.",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}

final class ChamberCell: UICollectionViewCell {
    static let identifier = "ChamberCell"

    private let container: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(white: 1.0, alpha: 0.07)
        view.layer.cornerRadius = 18
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private let numberLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 30, weight: .black)
        label.textColor = .white
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let nameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 12, weight: .semibold)
        label.textColor = UIColor.white.withAlphaComponent(0.8)
        label.textAlignment = .center
        label.numberOfLines = 2
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let starsLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 15, weight: .medium)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let detailLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 10, weight: .medium)
        label.textColor = UIColor.white.withAlphaComponent(0.55)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let lockLabel: UILabel = {
        let label = UILabel()
        label.text = "SEALED"
        label.font = UIFont.systemFont(ofSize: 13, weight: .bold)
        label.textColor = UIColor.white.withAlphaComponent(0.5)
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
        contentView.addSubview(container)
        container.addSubview(numberLabel)
        container.addSubview(nameLabel)
        container.addSubview(starsLabel)
        container.addSubview(detailLabel)
        container.addSubview(lockLabel)

        NSLayoutConstraint.activate([
            container.topAnchor.constraint(equalTo: contentView.topAnchor),
            container.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            container.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            container.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),

            numberLabel.topAnchor.constraint(equalTo: container.topAnchor, constant: 14),
            numberLabel.centerXAnchor.constraint(equalTo: container.centerXAnchor),

            nameLabel.topAnchor.constraint(equalTo: numberLabel.bottomAnchor, constant: 2),
            nameLabel.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 8),
            nameLabel.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -8),

            starsLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 8),
            starsLabel.centerXAnchor.constraint(equalTo: container.centerXAnchor),

            detailLabel.bottomAnchor.constraint(equalTo: container.bottomAnchor, constant: -12),
            detailLabel.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 6),
            detailLabel.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -6),

            lockLabel.centerXAnchor.constraint(equalTo: container.centerXAnchor),
            lockLabel.centerYAnchor.constraint(equalTo: container.centerYAnchor)
        ])
    }

    func configure(with item: LevelListItem) {
        numberLabel.text = "\(item.level.id)"
        nameLabel.text = item.level.name

        let unlocked = item.progress.isUnlocked
        numberLabel.isHidden = !unlocked
        nameLabel.isHidden = !unlocked
        starsLabel.isHidden = !unlocked
        detailLabel.isHidden = !unlocked
        lockLabel.isHidden = unlocked
        container.alpha = unlocked ? 1.0 : 0.45

        guard unlocked else {
            container.layer.borderWidth = 0
            return
        }

        let earned = item.progress.bestStars
        let stars = NSMutableAttributedString()
        for index in 0..<3 {
            let symbol = index < earned ? "★" : "☆"
            stars.append(
                NSAttributedString(
                    string: symbol,
                    attributes: [
                        .foregroundColor: index < earned
                            ? UIColor(red: 1.0, green: 0.84, blue: 0.30, alpha: 1.0)
                            : UIColor.white.withAlphaComponent(0.25)
                    ]
                )
            )
        }
        starsLabel.attributedText = stars

        if item.progress.hasRecord {
            detailLabel.text = "Best \(item.progress.bestMoves) moves · par \(item.level.parMoves)"
        } else {
            detailLabel.text = "Par \(item.level.parMoves) moves"
        }

        container.layer.borderWidth = 1.5
        container.layer.borderColor = ThemeManager.shared.primaryColor.withAlphaComponent(0.45).cgColor
    }
}
