import Foundation

final class StatisticsViewModel {
    let statistics: GameStatistics

    init(statistics: GameStatistics) {
        self.statistics = statistics
    }

    var headline: String {
        statistics.isCompleted ? "CHAMBER CLEARED" : "CHAMBER PAUSED"
    }

    var ratingText: String {
        statistics.rating
    }

    var starsText: String {
        String(repeating: "★", count: statistics.stars)
            + String(repeating: "☆", count: max(0, 3 - statistics.stars))
    }

    var rows: [(String, String)] {
        [
            ("Chamber", statistics.levelName),
            ("Moves used", "\(statistics.moves)"),
            ("Par moves", "\(statistics.parMoves)"),
            ("Crystals lit", "\(statistics.crystalsLit) / \(statistics.totalCrystals)"),
            ("Beam splits", "\(statistics.beamSplits)"),
            ("Gateway jumps", "\(statistics.gatewayJumps)"),
            ("Colour shifts", "\(statistics.colourShifts)"),
            ("Time", formatted(statistics.elapsedTime))
        ]
    }

    private func formatted(_ interval: TimeInterval) -> String {
        let total = Int(interval)
        return String(format: "%02d:%02d", total / 60, total % 60)
    }
}
