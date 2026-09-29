import Foundation

final class MenuViewModel {
    private(set) var totalStars: Int = 0
    private(set) var maxStars: Int = 0
    private(set) var solvedLevels: Int = 0

    init() {
        refresh()
    }

    func refresh() {
        let progress = DataManager.shared.loadProgress()
        totalStars = progress.reduce(0) { $0 + $1.bestStars }
        maxStars = LevelModel.allLevels.count * 3
        solvedLevels = progress.filter { $0.timesCompleted > 0 }.count
    }

    var summaryText: String {
        "\(solvedLevels) of \(LevelModel.allLevels.count) chambers cleared"
    }

    var starsText: String {
        "\(totalStars) / \(maxStars)"
    }
}
