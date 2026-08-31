import Foundation

struct LevelListItem {
    let level: LevelModel
    let progress: LevelProgress
}

protocol LevelSelectViewModelDelegate: AnyObject {
    func didSelectLevel(_ level: LevelModel)
    func levelsDidUpdate()
    func didSelectLockedLevel()
}

final class LevelSelectViewModel {
    weak var delegate: LevelSelectViewModelDelegate?

    private(set) var items: [LevelListItem] = []

    init() {
        refreshData()
    }

    func refreshData() {
        let progress = DataManager.shared.loadProgress()
        items = LevelModel.allLevels.map { level in
            let entry = progress.first { $0.levelId == level.id }
                ?? LevelProgress(levelId: level.id, isUnlocked: level.id == 1)
            return LevelListItem(level: level, progress: entry)
        }
    }

    var totalStars: Int {
        items.reduce(0) { $0 + $1.progress.bestStars }
    }

    var maxStars: Int {
        items.count * 3
    }

    func item(at index: Int) -> LevelListItem? {
        guard index >= 0, index < items.count else { return nil }
        return items[index]
    }

    func selectLevel(at index: Int) {
        guard let item = item(at: index) else { return }
        guard item.progress.isUnlocked else {
            delegate?.didSelectLockedLevel()
            return
        }
        delegate?.didSelectLevel(item.level)
    }
}
