import Foundation

enum GamePhase {
    case idle
    case solving
    case solved
}

struct GameStatistics {
    var levelId: Int = 0
    var levelName: String = ""
    var moves: Int = 0
    var parMoves: Int = 0
    var crystalsLit: Int = 0
    var totalCrystals: Int = 0
    var gatewayJumps: Int = 0
    var beamSplits: Int = 0
    var colourShifts: Int = 0
    var elapsedTime: TimeInterval = 0
    var isCompleted: Bool = false

    var stars: Int {
        guard isCompleted else { return 0 }
        if moves <= parMoves { return 3 }
        if Double(moves) <= Double(parMoves) * 1.75 { return 2 }
        return 1
    }

    var rating: String {
        guard isCompleted else { return "UNFINISHED" }
        switch stars {
        case 3: return "FLAWLESS BEAM"
        case 2: return "STEADY HAND"
        default: return "PATH FOUND"
        }
    }
}

struct GameStateModel {
    var phase: GamePhase = .idle
    var moves: Int = 0
    var crystalsLit: Int = 0
    var totalCrystals: Int = 0
    var startedAt: Date = Date()
    var statistics: GameStatistics = GameStatistics()
}

struct HighScoreEntry: Codable {
    let levelId: Int
    let levelName: String
    let moves: Int
    let stars: Int
    let elapsedTime: TimeInterval
    let date: Date
}
