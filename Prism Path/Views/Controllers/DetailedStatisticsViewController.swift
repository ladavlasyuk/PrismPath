import UIKit

final class DetailedStatisticsViewController: UIViewController {
    private let viewModel = DetailedStatisticsViewModel()

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "STATISTICS"
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

    private let scrollView: UIScrollView = {
        let view = UIScrollView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private let stack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 14
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        backButton.addTarget(self, action: #selector(backTapped), for: .touchUpInside)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
        viewModel.refresh()
        reload()
    }

    private func setupUI() {
        view.backgroundColor = ThemeManager.shared.backgroundColor

        view.addSubview(backButton)
        view.addSubview(titleLabel)
        view.addSubview(scrollView)
        scrollView.addSubview(stack)

        let inset = LayoutMetrics.horizontalInset
        var constraints: [NSLayoutConstraint] = [
            backButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 14),
            backButton.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: inset),

            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 14),
            titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),

            scrollView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 18),
            scrollView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            stack.topAnchor.constraint(equalTo: scrollView.topAnchor, constant: 8),
            stack.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor, constant: -30),
            stack.centerXAnchor.constraint(equalTo: scrollView.centerXAnchor)
        ]

        if LayoutMetrics.isPad {
            constraints.append(stack.widthAnchor.constraint(lessThanOrEqualToConstant: LayoutMetrics.contentMaxWidth))
            let fill = stack.widthAnchor.constraint(equalTo: scrollView.widthAnchor, constant: -inset * 2)
            fill.priority = .defaultHigh
            constraints.append(fill)
            constraints.append(stack.leadingAnchor.constraint(greaterThanOrEqualTo: scrollView.leadingAnchor, constant: inset))
            constraints.append(stack.trailingAnchor.constraint(lessThanOrEqualTo: scrollView.trailingAnchor, constant: -inset))
        } else {
            constraints.append(stack.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: inset))
            constraints.append(stack.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor, constant: -inset))
            constraints.append(stack.widthAnchor.constraint(equalTo: scrollView.widthAnchor, constant: -inset * 2))
        }

        NSLayoutConstraint.activate(constraints)
    }

    private func reload() {
        stack.arrangedSubviews.forEach { $0.removeFromSuperview() }

        stack.addArrangedSubview(makeSectionLabel("OVERALL"))
        stack.addArrangedSubview(makeCard(rows: viewModel.summaryRows))

        stack.addArrangedSubview(makeSectionLabel("PER CHAMBER"))
        for level in viewModel.levels {
            stack.addArrangedSubview(makeChamberCard(level: level))
        }
    }

    private func makeSectionLabel(_ text: String) -> UILabel {
        let label = UILabel()
        label.text = text
        label.font = UIFont.systemFont(ofSize: 13, weight: .bold)
        label.textColor = UIColor.white.withAlphaComponent(0.55)
        return label
    }

    private func makeCard(rows: [(String, String)]) -> UIView {
        let card = UIView()
        card.backgroundColor = UIColor(white: 1.0, alpha: 0.07)
        card.layer.cornerRadius = 16
        card.translatesAutoresizingMaskIntoConstraints = false

        let inner = UIStackView()
        inner.axis = .vertical
        inner.spacing = 9
        inner.translatesAutoresizingMaskIntoConstraints = false
        card.addSubview(inner)

        NSLayoutConstraint.activate([
            inner.topAnchor.constraint(equalTo: card.topAnchor, constant: 16),
            inner.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 18),
            inner.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -18),
            inner.bottomAnchor.constraint(equalTo: card.bottomAnchor, constant: -16)
        ])

        for (title, value) in rows {
            inner.addArrangedSubview(makeRow(title: title, value: value))
        }

        return card
    }

    private func makeChamberCard(level: LevelModel) -> UIView {
        let statistics = viewModel.statistics(forLevel: level.id)
        let record = viewModel.record(forLevel: level.id)

        var rows: [(String, String)] = []
        rows.append(("Status", (record?.timesCompleted ?? 0) > 0 ? "Cleared" : (record?.isUnlocked ?? false) ? "Open" : "Sealed"))
        rows.append(("Best stars", String(repeating: "★", count: record?.bestStars ?? 0) + String(repeating: "☆", count: 3 - (record?.bestStars ?? 0))))
        rows.append(("Best moves", (record?.bestMoves ?? 0) > 0 ? "\(record?.bestMoves ?? 0)" : "—"))
        rows.append(("Par", "\(level.parMoves)"))
        rows.append(("Runs", "\(statistics?.runsStarted ?? 0)"))
        rows.append(("Time", viewModel.formattedTime(statistics?.totalPlayTime ?? 0)))

        let card = makeCard(rows: rows)

        let header = UILabel()
        header.text = "\(level.id). \(level.name)"
        header.font = UIFont.systemFont(ofSize: 15, weight: .bold)
        header.textColor = ThemeManager.shared.highlightColor
        header.translatesAutoresizingMaskIntoConstraints = false

        let wrapper = UIStackView(arrangedSubviews: [header, card])
        wrapper.axis = .vertical
        wrapper.spacing = 8
        return wrapper
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
