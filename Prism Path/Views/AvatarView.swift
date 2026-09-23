import UIKit

final class AvatarView: UIView {
    var onTap: (() -> Void)?

    private let imageView: UIImageView = {
        let view = UIImageView()
        view.contentMode = .scaleAspectFill
        view.clipsToBounds = true
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private let placeholderLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 26, weight: .bold)
        label.textColor = UIColor.white.withAlphaComponent(0.65)
        label.textAlignment = .center
        label.text = "?"
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let badgeView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 13
        view.layer.borderWidth = 2
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private let badgeIcon: UIImageView = {
        let view = UIImageView()
        view.image = UIImage(systemName: "camera.fill")
        view.tintColor = .black
        view.contentMode = .scaleAspectFit
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private let side: CGFloat
    private let showsBadge: Bool

    init(side: CGFloat, showsBadge: Bool) {
        self.side = side
        self.showsBadge = showsBadge
        super.init(frame: .zero)
        setupView()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupView() {
        translatesAutoresizingMaskIntoConstraints = false
        backgroundColor = UIColor(white: 1.0, alpha: 0.08)
        layer.cornerRadius = side / 2
        layer.borderWidth = 2
        clipsToBounds = false

        imageView.layer.cornerRadius = side / 2

        addSubview(imageView)
        addSubview(placeholderLabel)

        NSLayoutConstraint.activate([
            widthAnchor.constraint(equalToConstant: side),
            heightAnchor.constraint(equalToConstant: side),

            imageView.topAnchor.constraint(equalTo: topAnchor),
            imageView.bottomAnchor.constraint(equalTo: bottomAnchor),
            imageView.leadingAnchor.constraint(equalTo: leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: trailingAnchor),

            placeholderLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
            placeholderLabel.centerYAnchor.constraint(equalTo: centerYAnchor)
        ])

        if showsBadge {
            addSubview(badgeView)
            badgeView.addSubview(badgeIcon)

            NSLayoutConstraint.activate([
                badgeView.widthAnchor.constraint(equalToConstant: 26),
                badgeView.heightAnchor.constraint(equalToConstant: 26),
                badgeView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: 2),
                badgeView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: 2),

                badgeIcon.centerXAnchor.constraint(equalTo: badgeView.centerXAnchor),
                badgeIcon.centerYAnchor.constraint(equalTo: badgeView.centerYAnchor),
                badgeIcon.widthAnchor.constraint(equalToConstant: 13),
                badgeIcon.heightAnchor.constraint(equalToConstant: 13)
            ])
        }

        let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        addGestureRecognizer(tapRecognizer)
        isUserInteractionEnabled = true

        applyTheme()
    }

    func applyTheme() {
        layer.borderColor = ThemeManager.shared.primaryColor.withAlphaComponent(0.7).cgColor
        badgeView.backgroundColor = ThemeManager.shared.primaryColor
        badgeView.layer.borderColor = ThemeManager.shared.backgroundColor.cgColor
        placeholderLabel.textColor = ThemeManager.shared.primaryColor.withAlphaComponent(0.8)
    }

    func setImage(_ image: UIImage?) {
        imageView.image = image
        placeholderLabel.isHidden = image != nil
    }

    @objc private func handleTap() {
        HapticsManager.shared.selection()
        UIView.animate(withDuration: 0.09, animations: {
            self.transform = CGAffineTransform(scaleX: 0.94, y: 0.94)
        }, completion: { _ in
            UIView.animate(withDuration: 0.12) {
                self.transform = .identity
            }
        })
        onTap?()
    }
}
