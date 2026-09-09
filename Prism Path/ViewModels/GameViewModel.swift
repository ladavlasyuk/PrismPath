import Foundation

final class GameViewModel {
    let level: LevelModel
    let board: PuzzleBoard

    private(set) var moves: Int = 0
    private(set) var trace: BeamTraceResult
    private(set) var gatewayJumps: Int = 0
    private(set) var beamSplits: Int = 0
    private(set) var colourShifts: Int = 0
    private(set) var isSolved: Bool = false

    private var startedAt: Date

    init(level: LevelModel) {
        self.level = level
        self.board = PuzzleBoard(level: level)
        self.trace = board.trace()
        self.startedAt = Date()
        refreshCounters()
    }

    var totalCrystals: Int { board.crystalPositions.count }
    var crystalsLit: Int { trace.litCrystals.count }
    var elapsedTime: TimeInterval { Date().timeIntervalSince(startedAt) }

    @discardableResult
    func adjust(at position: GridPosition) -> Bool {
        guard !isSolved else { return false }
        guard board.adjustTile(at: position) else { return false }
        moves += 1
        recalculate()
        return true
    }

    func restart() {
        board.reset()
        moves = 0
        isSolved = false
        startedAt = Date()
        recalculate()
    }

    private func recalculate() {
        trace = board.trace()
        refreshCounters()
        isSolved = totalCrystals > 0 && crystalsLit == totalCrystals
    }

    private func refreshCounters() {
        gatewayJumps = max(gatewayJumps, trace.gatewayJumps)
        beamSplits = max(beamSplits, trace.splits)
        colourShifts = max(colourShifts, trace.colourShifts)
    }

    func makeStatistics() -> GameStatistics {
        GameStatistics(
            levelId: level.id,
            levelName: level.name,
            moves: moves,
            parMoves: level.parMoves,
            crystalsLit: crystalsLit,
            totalCrystals: totalCrystals,
            gatewayJumps: gatewayJumps,
            beamSplits: beamSplits,
            colourShifts: colourShifts,
            elapsedTime: elapsedTime,
            isCompleted: isSolved
        )
    }
}
