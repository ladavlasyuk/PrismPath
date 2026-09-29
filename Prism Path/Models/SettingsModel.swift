import UIKit

enum AppColorTheme: String, CaseIterable, Codable {
    case aurora
    case lagoon
    case orchid
    case ember
    case rose
    case mint
    case indigo
    case sand

    var displayName: String {
        switch self {
        case .aurora: return "Aurora"
        case .lagoon: return "Lagoon"
        case .orchid: return "Orchid"
        case .ember: return "Ember"
        case .rose: return "Rose"
        case .mint: return "Mint"
        case .indigo: return "Indigo"
        case .sand: return "Sand"
        }
    }

    var primaryColor: UIColor {
        switch self {
        case .aurora: return UIColor(red: 0.35, green: 0.85, blue: 0.80, alpha: 1.0)
        case .lagoon: return UIColor(red: 0.24, green: 0.60, blue: 0.95, alpha: 1.0)
        case .orchid: return UIColor(red: 0.66, green: 0.42, blue: 0.96, alpha: 1.0)
        case .ember: return UIColor(red: 0.96, green: 0.52, blue: 0.26, alpha: 1.0)
        case .rose: return UIColor(red: 0.95, green: 0.42, blue: 0.60, alpha: 1.0)
        case .mint: return UIColor(red: 0.34, green: 0.88, blue: 0.55, alpha: 1.0)
        case .indigo: return UIColor(red: 0.42, green: 0.45, blue: 0.94, alpha: 1.0)
        case .sand: return UIColor(red: 0.94, green: 0.80, blue: 0.40, alpha: 1.0)
        }
    }

    var secondaryColor: UIColor {
        primaryColor.withAlphaComponent(0.7)
    }

    var accentColor: UIColor {
        primaryColor.withAlphaComponent(0.3)
    }

    var buttonColor: UIColor {
        primaryColor
    }

    var highlightColor: UIColor {
        switch self {
        case .aurora: return UIColor(red: 0.52, green: 0.95, blue: 0.90, alpha: 1.0)
        case .lagoon: return UIColor(red: 0.40, green: 0.72, blue: 1.0, alpha: 1.0)
        case .orchid: return UIColor(red: 0.78, green: 0.56, blue: 1.0, alpha: 1.0)
        case .ember: return UIColor(red: 1.0, green: 0.64, blue: 0.38, alpha: 1.0)
        case .rose: return UIColor(red: 1.0, green: 0.55, blue: 0.72, alpha: 1.0)
        case .mint: return UIColor(red: 0.50, green: 0.96, blue: 0.68, alpha: 1.0)
        case .indigo: return UIColor(red: 0.56, green: 0.58, blue: 1.0, alpha: 1.0)
        case .sand: return UIColor(red: 1.0, green: 0.89, blue: 0.55, alpha: 1.0)
        }
    }
}

struct SettingsModel: Codable {
    var colorTheme: AppColorTheme = .aurora
    var isHapticsEnabled: Bool = true
    var isSoundEnabled: Bool = true
    var showsBeamTrail: Bool = true
}
