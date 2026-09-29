import UIKit

protocol SettingsViewModelDelegate: AnyObject {
    func settingsDidChange()
    func didRequestResetConfirmation()
    func didCompleteReset()
}

final class SettingsViewModel {
    weak var delegate: SettingsViewModelDelegate?

    private var settings: SettingsModel

    init() {
        settings = DataManager.shared.loadSettings()
    }

    var allThemes: [AppColorTheme] { AppColorTheme.allCases }
    var currentTheme: AppColorTheme { settings.colorTheme }
    var isHapticsEnabled: Bool { settings.isHapticsEnabled }
    var isSoundEnabled: Bool { settings.isSoundEnabled }
    var showsBeamTrail: Bool { settings.showsBeamTrail }

    var avatar: UIImage? { DataManager.shared.loadAvatar() }
    var hasAvatar: Bool { DataManager.shared.hasAvatar }

    func updateAvatar(_ image: UIImage) {
        DataManager.shared.saveAvatar(image)
    }

    func clearAvatar() {
        DataManager.shared.removeAvatar()
    }

    func setColorTheme(_ theme: AppColorTheme) {
        settings.colorTheme = theme
        persist()
        ThemeManager.shared.applyTheme(theme)
        delegate?.settingsDidChange()
    }

    func toggleHaptics() {
        settings.isHapticsEnabled.toggle()
        HapticsManager.shared.setEnabled(settings.isHapticsEnabled)
        persist()
        delegate?.settingsDidChange()
    }

    func toggleSound() {
        settings.isSoundEnabled.toggle()
        AudioManager.shared.setSoundEnabled(settings.isSoundEnabled)
        persist()
        delegate?.settingsDidChange()
    }

    func toggleBeamTrail() {
        settings.showsBeamTrail.toggle()
        persist()
        delegate?.settingsDidChange()
    }

    func requestReset() {
        delegate?.didRequestResetConfirmation()
    }

    func confirmReset() {
        DataManager.shared.resetAllData()
        settings = SettingsModel()
        persist()
        HapticsManager.shared.setEnabled(settings.isHapticsEnabled)
        AudioManager.shared.setSoundEnabled(settings.isSoundEnabled)
        ThemeManager.shared.applyTheme(settings.colorTheme)
        delegate?.didCompleteReset()
    }

    private func persist() {
        DataManager.shared.saveSettings(settings)
    }
}
