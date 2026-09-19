import Foundation

final class DetailedStatisticsViewModel {
    private(set) var levels: [LevelModel] = []
    private(set) var levelStatistics: [Int: LevelStatistics] = [:]
    private(set) var progress: [Int: LevelProgress] = [:]
    private(set) var totals: LevelStatistics

    init() {
        levels = LevelModel.allLevels
        levelStatistics = DataManager.shared.loadStatistics()
        totals = DataManager.shared.totalStatistics()
        progress = DetailedStatisticsViewModel.mappedProgress()
    }

    private static func mappedProgress() -> [Int: LevelProgress] {
        var mapped: [Int: LevelProgress] = [:]
        for entry in DataManager.shared.loadProgress() {
            mapped[entry.levelId] = entry
        }
        return mapped
    }

    func refresh() {
        levels = LevelModel.allLevels
        levelStatistics = DataManager.shared.loadStatistics()
        totals = DataManager.shared.totalStatistics()
        progress = DetailedStatisticsViewModel.mappedProgress()
    }

    var summaryRows: [(String, String)] {
        [
            ("Chambers cleared", "\(clearedCount) / \(levels.count)"),
            ("Stars collected", "\(totalStars) / \(levels.count * 3)"),
            ("Runs started", "\(totals.runsStarted)"),
            ("Runs completed", "\(totals.runsCompleted)"),
            ("Completion rate", String(format: "%.0f%%", totals.completionRate)),
            ("Total moves", "\(totals.totalMoves)"),
            ("Crystals lit", "\(totals.totalCrystalsLit)"),
            ("Beam splits", "\(totals.totalSplits)"),
            ("Gateway jumps", "\(totals.totalGateways)"),
            ("Colour shifts", "\(totals.totalColourShifts)"),
            ("Time in chambers", formattedTime(totals.totalPlayTime))
        ]
    }

    var clearedCount: Int {
        progress.values.filter { $0.timesCompleted > 0 }.count
    }

    var totalStars: Int {
        progress.values.reduce(0) { $0 + $1.bestStars }
    }

    func statistics(forLevel levelId: Int) -> LevelStatistics? {
        levelStatistics[levelId]
    }

    func record(forLevel levelId: Int) -> LevelProgress? {
        progress[levelId]
    }

    func formattedTime(_ interval: TimeInterval) -> String {
        let total = Int(interval)
        let hours = total / 3600
        let minutes = (total % 3600) / 60
        let seconds = total % 60
        if hours > 0 {
            return String(format: "%dh %dm", hours, minutes)
        }
        if minutes > 0 {
            return String(format: "%dm %ds", minutes, seconds)
        }
        return String(format: "%ds", seconds)
    }
}
