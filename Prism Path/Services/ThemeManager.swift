import UIKit

final class ThemeManager {
    static let shared = ThemeManager()

    private(set) var currentTheme: AppColorTheme = .aurora

    var primaryColor: UIColor { currentTheme.primaryColor }
    var secondaryColor: UIColor { currentTheme.secondaryColor }
    var accentColor: UIColor { currentTheme.accentColor }
    var buttonColor: UIColor { currentTheme.buttonColor }
    var highlightColor: UIColor { currentTheme.highlightColor }

    var backgroundColor: UIColor {
        UIColor(red: 0.05, green: 0.06, blue: 0.11, alpha: 1.0)
    }

    var deepBackgroundColor: UIColor {
        UIColor(red: 0.03, green: 0.04, blue: 0.08, alpha: 1.0)
    }

    var cardBackgroundColor: UIColor {
        UIColor(red: 0.11, green: 0.13, blue: 0.20, alpha: 1.0)
    }

    private init() {
        loadTheme()
    }

    func loadTheme() {
        currentTheme = DataManager.shared.loadSettings().colorTheme
    }

    func applyTheme(_ theme: AppColorTheme) {
        currentTheme = theme
        NotificationCenter.default.post(name: .themeDidChange, object: nil)
    }
}

extension Notification.Name {
    static let themeDidChange = Notification.Name("themeDidChange")
}
