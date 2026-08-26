import UIKit

extension Notification.Name {
    static let avatarDidChange = Notification.Name("avatarDidChange")
}

final class DataManager {
    static let shared = DataManager()

    private let progressKey = "levelProgress"
    private let statisticsKey = "levelStatistics"
    private let settingsKey = "appSettings"
    private let highScoresKey = "solveRecords"

    private let avatarFileName = "player-portrait.jpg"
    private let avatarSideLimit: CGFloat = 512

    private var cachedAvatar: UIImage?

    private init() {}

    private var avatarLocation: URL {
        let directory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        return directory.appendingPathComponent(avatarFileName)
    }

    var hasAvatar: Bool {
        cachedAvatar != nil || FileManager.default.fileExists(atPath: avatarLocation.path)
    }

    func loadAvatar() -> UIImage? {
        if let cachedAvatar {
            return cachedAvatar
        }
        guard let data = try? Data(contentsOf: avatarLocation),
              let image = UIImage(data: data) else {
            return nil
        }
        cachedAvatar = image
        return image
    }

    @discardableResult
    func saveAvatar(_ image: UIImage) -> UIImage? {
        let prepared = squared(image)
        guard let data = prepared.jpegData(compressionQuality: 0.9) else { return nil }
        do {
            try data.write(to: avatarLocation, options: [.atomic])
            cachedAvatar = prepared
            NotificationCenter.default.post(name: .avatarDidChange, object: nil)
            return prepared
        } catch {
            return nil
        }
    }

    func removeAvatar() {
        try? FileManager.default.removeItem(at: avatarLocation)
        cachedAvatar = nil
        NotificationCenter.default.post(name: .avatarDidChange, object: nil)
    }

    private func squared(_ image: UIImage) -> UIImage {
        let side = min(image.size.width, image.size.height)
        let cropOrigin = CGPoint(
            x: (image.size.width - side) / 2,
            y: (image.size.height - side) / 2
        )
        let target = min(side, avatarSideLimit)

        let format = UIGraphicsImageRendererFormat.default()
        format.scale = 1
        format.opaque = true

        let renderer = UIGraphicsImageRenderer(
            size: CGSize(width: target, height: target),
            format: format
        )

        return renderer.image { _ in
            let scale = target / side
            let drawSize = CGSize(
                width: image.size.width * scale,
                height: image.size.height * scale
            )
            let drawOrigin = CGPoint(x: -cropOrigin.x * scale, y: -cropOrigin.y * scale)
            image.draw(in: CGRect(origin: drawOrigin, size: drawSize))
        }
    }

    func loadProgress() -> [LevelProgress] {
        guard let data = UserDefaults.standard.data(forKey: progressKey),
              let stored = try? JSONDecoder().decode([LevelProgress].self, from: data) else {
            return defaultProgress()
        }

        var byID: [Int: LevelProgress] = [:]
        for entry in stored {
            byID[entry.levelId] = entry
        }

        return LevelModel.allLevels.map { level in
            byID[level.id] ?? LevelProgress(levelId: level.id, isUnlocked: level.id == 1)
        }
    }

    func saveProgress(_ progress: [LevelProgress]) {
        if let encoded = try? JSONEncoder().encode(progress) {
            UserDefaults.standard.set(encoded, forKey: progressKey)
        }
    }

    func progress(forLevel levelId: Int) -> LevelProgress {
        loadProgress().first { $0.levelId == levelId }
            ?? LevelProgress(levelId: levelId, isUnlocked: levelId == 1)
    }

    private func defaultProgress() -> [LevelProgress] {
        LevelModel.allLevels.map { LevelProgress(levelId: $0.id, isUnlocked: $0.id == 1) }
    }

    func saveStatistics(_ statistics: [Int: LevelStatistics]) {
        let array = Array(statistics.values)
        if let encoded = try? JSONEncoder().encode(array) {
            UserDefaults.standard.set(encoded, forKey: statisticsKey)
        }
    }

    func loadStatistics() -> [Int: LevelStatistics] {
        guard let data = UserDefaults.standard.data(forKey: statisticsKey),
              let array = try? JSONDecoder().decode([LevelStatistics].self, from: data) else {
            return [:]
        }
        var result: [Int: LevelStatistics] = [:]
        for entry in array {
            result[entry.levelId] = entry
        }
        return result
    }

    func saveSettings(_ settings: SettingsModel) {
        if let encoded = try? JSONEncoder().encode(settings) {
            UserDefaults.standard.set(encoded, forKey: settingsKey)
        }
    }

    func loadSettings() -> SettingsModel {
        guard let data = UserDefaults.standard.data(forKey: settingsKey),
              let settings = try? JSONDecoder().decode(SettingsModel.self, from: data) else {
            return SettingsModel()
        }
        return settings
    }

    func saveHighScores(_ records: [HighScoreEntry]) {
        if let encoded = try? JSONEncoder().encode(records) {
            UserDefaults.standard.set(encoded, forKey: highScoresKey)
        }
    }

    func loadHighScores() -> [HighScoreEntry] {
        guard let data = UserDefaults.standard.data(forKey: highScoresKey),
              let records = try? JSONDecoder().decode([HighScoreEntry].self, from: data) else {
            return []
        }
        return records
    }

    func resetAllData() {
        UserDefaults.standard.removeObject(forKey: progressKey)
        UserDefaults.standard.removeObject(forKey: statisticsKey)
        UserDefaults.standard.removeObject(forKey: highScoresKey)
        removeAvatar()
    }

    func registerRun(statistics: GameStatistics) {
        updateProgress(with: statistics)
        updateStatistics(with: statistics)

        guard statistics.isCompleted else { return }

        var records = loadHighScores()
        records.append(
            HighScoreEntry(
                levelId: statistics.levelId,
                levelName: statistics.levelName,
                moves: statistics.moves,
                stars: statistics.stars,
                elapsedTime: statistics.elapsedTime,
                date: Date()
            )
        )
        records.sort { left, right in
            if left.stars != right.stars { return left.stars > right.stars }
            return left.moves < right.moves
        }
        saveHighScores(Array(records.prefix(30)))
    }

    private func updateProgress(with statistics: GameStatistics) {
        var progress = loadProgress()
        guard let index = progress.firstIndex(where: { $0.levelId == statistics.levelId }) else { return }

        progress[index].timesPlayed += 1

        if statistics.isCompleted {
            progress[index].timesCompleted += 1
            progress[index].bestStars = max(progress[index].bestStars, statistics.stars)

            if progress[index].bestMoves == 0 || statistics.moves < progress[index].bestMoves {
                progress[index].bestMoves = statistics.moves
            }
            if progress[index].bestTime == 0 || statistics.elapsedTime < progress[index].bestTime {
                progress[index].bestTime = statistics.elapsedTime
            }

            if let nextIndex = progress.firstIndex(where: { $0.levelId == statistics.levelId + 1 }) {
                progress[nextIndex].isUnlocked = true
            }
        }

        saveProgress(progress)
    }

    private func updateStatistics(with statistics: GameStatistics) {
        var allStatistics = loadStatistics()
        var entry = allStatistics[statistics.levelId] ?? LevelStatistics(levelId: statistics.levelId)

        entry.totalMoves += statistics.moves
        entry.totalCrystalsLit += statistics.crystalsLit
        entry.totalGateways += statistics.gatewayJumps
        entry.totalSplits += statistics.beamSplits
        entry.totalColourShifts += statistics.colourShifts
        entry.totalPlayTime += statistics.elapsedTime
        entry.runsStarted += 1

        if statistics.isCompleted {
            entry.runsCompleted += 1
            if entry.fewestMoves == 0 || statistics.moves < entry.fewestMoves {
                entry.fewestMoves = statistics.moves
            }
        }

        allStatistics[statistics.levelId] = entry
        saveStatistics(allStatistics)
    }

    func totalStatistics() -> LevelStatistics {
        var total = LevelStatistics(levelId: 0)
        for entry in loadStatistics().values {
            total.totalMoves += entry.totalMoves
            total.totalCrystalsLit += entry.totalCrystalsLit
            total.totalGateways += entry.totalGateways
            total.totalSplits += entry.totalSplits
            total.totalColourShifts += entry.totalColourShifts
            total.totalPlayTime += entry.totalPlayTime
            total.runsStarted += entry.runsStarted
            total.runsCompleted += entry.runsCompleted
            if entry.fewestMoves > 0 {
                total.fewestMoves = total.fewestMoves == 0
                    ? entry.fewestMoves
                    : min(total.fewestMoves, entry.fewestMoves)
            }
        }
        return total
    }
}
