import AVFoundation

final class AudioManager {
    static let shared = AudioManager()

    private var isSoundEnabled: Bool = true

    private init() {
        loadSettings()
        setupAudioSession()
    }

    private func setupAudioSession() {
        do {
            try AVAudioSession.sharedInstance().setCategory(.ambient, mode: .default)
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
        }
    }

    private func loadSettings() {
        isSoundEnabled = DataManager.shared.loadSettings().isSoundEnabled
    }

    func playTapSound() {
        guard isSoundEnabled else { return }
        playSystemSound(id: 1123)
    }

    func playRotateSound() {
        guard isSoundEnabled else { return }
        playSystemSound(id: 1104)
    }

    func playCrystalSound() {
        guard isSoundEnabled else { return }
        playSystemSound(id: 1057)
    }

    func playBlockedSound() {
        guard isSoundEnabled else { return }
        playSystemSound(id: 1053)
    }

    func playTeleportSound() {
        guard isSoundEnabled else { return }
        playSystemSound(id: 1110)
    }

    func playLevelCompleteSound() {
        guard isSoundEnabled else { return }
        playSystemSound(id: 1025)
    }

    func playResetSound() {
        guard isSoundEnabled else { return }
        playSystemSound(id: 1073)
    }

    private func playSystemSound(id: SystemSoundID) {
        AudioServicesPlaySystemSound(id)
    }

    func setSoundEnabled(_ enabled: Bool) {
        isSoundEnabled = enabled
    }
}
