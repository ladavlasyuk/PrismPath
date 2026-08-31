import UIKit

enum LayoutMetrics {
    static var isPad: Bool {
        UIDevice.current.userInterfaceIdiom == .pad
    }

    static var horizontalInset: CGFloat {
        isPad ? 48 : 20
    }

    static var contentMaxWidth: CGFloat {
        isPad ? 560 : .greatestFiniteMagnitude
    }

    static var menuPrimaryWidth: CGFloat {
        isPad ? 320 : 240
    }

    static var menuSecondaryWidth: CGFloat {
        isPad ? 260 : 190
    }

    static var menuAuraHeightMultiplier: CGFloat {
        isPad ? 0.30 : 0.42
    }

    static var chamberColumnCount: Int {
        isPad ? 3 : 2
    }

    static func constrainContentWidth(
        of view: UIView,
        in host: UIView,
        inset: CGFloat = horizontalInset
    ) -> [NSLayoutConstraint] {
        var constraints: [NSLayoutConstraint] = [
            view.leadingAnchor.constraint(greaterThanOrEqualTo: host.leadingAnchor, constant: inset),
            view.trailingAnchor.constraint(lessThanOrEqualTo: host.trailingAnchor, constant: -inset),
            view.centerXAnchor.constraint(equalTo: host.centerXAnchor)
        ]

        if isPad {
            constraints.append(
                view.widthAnchor.constraint(lessThanOrEqualToConstant: contentMaxWidth)
            )
            let fill = view.widthAnchor.constraint(equalTo: host.widthAnchor, constant: -inset * 2)
            fill.priority = .defaultHigh
            constraints.append(fill)
        } else {
            constraints.append(view.leadingAnchor.constraint(equalTo: host.leadingAnchor, constant: inset))
            constraints.append(view.trailingAnchor.constraint(equalTo: host.trailingAnchor, constant: -inset))
        }

        return constraints
    }
}
