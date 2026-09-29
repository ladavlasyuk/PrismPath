import UIKit

final class HapticsManager {
    static let shared = HapticsManager()

    private var isEnabled: Bool = true
    private let lightGenerator = UIImpactFeedbackGenerator(style: .light)
    private let mediumGenerator = UIImpactFeedbackGenerator(style: .medium)
    private let heavyGenerator = UIImpactFeedbackGenerator(style: .heavy)
    private let notificationGenerator = UINotificationFeedbackGenerator()
    private let selectionGenerator = UISelectionFeedbackGenerator()

    private init() {
        loadSettings()
        prepareGenerators()
    }

    private func loadSettings() {
        isEnabled = DataManager.shared.loadSettings().isHapticsEnabled
    }

    private func prepareGenerators() {
        lightGenerator.prepare()
        mediumGenerator.prepare()
        heavyGenerator.prepare()
        notificationGenerator.prepare()
        selectionGenerator.prepare()
    }

    func lightImpact() {
        guard isEnabled else { return }
        lightGenerator.impactOccurred()
    }

    func mediumImpact() {
        guard isEnabled else { return }
        mediumGenerator.impactOccurred()
    }

    func heavyImpact() {
        guard isEnabled else { return }
        heavyGenerator.impactOccurred()
    }

    func success() {
        guard isEnabled else { return }
        notificationGenerator.notificationOccurred(.success)
    }

    func warning() {
        guard isEnabled else { return }
        notificationGenerator.notificationOccurred(.warning)
    }

    func error() {
        guard isEnabled else { return }
        notificationGenerator.notificationOccurred(.error)
    }

    func selection() {
        guard isEnabled else { return }
        selectionGenerator.selectionChanged()
    }

    func setEnabled(_ enabled: Bool) {
        isEnabled = enabled
        if enabled {
            prepareGenerators()
        }
    }
}
