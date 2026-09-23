import Foundation

struct LevelModel {
    let id: Int
    let name: String
    let hint: String
    let columns: Int
    let rows: Int
    let parMoves: Int
    let placements: [TilePlacement]

    var crystalCount: Int {
        placements.filter {
            if case .crystal = $0.kind { return true }
            return false
        }.count
    }

    static func level(withID id: Int) -> LevelModel? {
        allLevels.first { $0.id == id }
    }

    static let allLevels: [LevelModel] = [
        LevelModel(
            id: 1,
            name: "First Light",
            hint: "Tap a mirror to flip it and guide the beam into the crystal.",
            columns: 5,
            rows: 5,
            parMoves: 1,
            placements: [
                TilePlacement(0, 0, .emitter(direction: .down, spectrum: .pure)),
                TilePlacement(0, 4, .mirror(slant: .ascending)),
                TilePlacement(4, 4, .crystal(required: .pure))
            ]
        ),
        LevelModel(
            id: 2,
            name: "Twin Turns",
            hint: "Two mirrors, one path. Take the beam around the corner.",
            columns: 6,
            rows: 6,
            parMoves: 2,
            placements: [
                TilePlacement(0, 0, .emitter(direction: .down, spectrum: .pure)),
                TilePlacement(3, 0, .barrier),
                TilePlacement(0, 3, .mirror(slant: .ascending)),
                TilePlacement(5, 3, .mirror(slant: .ascending)),
                TilePlacement(0, 5, .barrier),
                TilePlacement(5, 5, .crystal(required: .pure))
            ]
        ),
        LevelModel(
            id: 3,
            name: "Quiet Detour",
            hint: "Stone blocks swallow the light. Route around them.",
            columns: 6,
            rows: 7,
            parMoves: 3,
            placements: [
                TilePlacement(0, 1, .mirror(slant: .descending)),
                TilePlacement(2, 1, .mirror(slant: .ascending)),
                TilePlacement(3, 1, .barrier),
                TilePlacement(2, 4, .mirror(slant: .ascending)),
                TilePlacement(5, 4, .crystal(required: .pure)),
                TilePlacement(0, 6, .emitter(direction: .up, spectrum: .pure))
            ]
        ),
        LevelModel(
            id: 4,
            name: "Colour Shift",
            hint: "A tinted lens repaints the beam. Match the crystal hue.",
            columns: 6,
            rows: 7,
            parMoves: 2,
            placements: [
                TilePlacement(0, 0, .emitter(direction: .down, spectrum: .pure)),
                TilePlacement(4, 2, .crystal(required: .crimson)),
                TilePlacement(0, 3, .tint(spectrum: .crimson)),
                TilePlacement(0, 6, .mirror(slant: .ascending)),
                TilePlacement(4, 6, .mirror(slant: .descending))
            ]
        ),
        LevelModel(
            id: 5,
            name: "Two Sources",
            hint: "Every crystal needs its own stream of light.",
            columns: 6,
            rows: 8,
            parMoves: 3,
            placements: [
                TilePlacement(0, 0, .emitter(direction: .down, spectrum: .pure)),
                TilePlacement(3, 1, .barrier),
                TilePlacement(0, 3, .mirror(slant: .ascending)),
                TilePlacement(2, 3, .mirror(slant: .ascending)),
                TilePlacement(4, 4, .barrier),
                TilePlacement(2, 5, .crystal(required: .pure)),
                TilePlacement(1, 6, .crystal(required: .pure)),
                TilePlacement(5, 6, .mirror(slant: .ascending)),
                TilePlacement(5, 7, .emitter(direction: .up, spectrum: .pure))
            ]
        ),
        LevelModel(
            id: 6,
            name: "Warm and Cold",
            hint: "Two lenses, two colours. Keep the streams apart.",
            columns: 6,
            rows: 8,
            parMoves: 3,
            placements: [
                TilePlacement(0, 0, .emitter(direction: .down, spectrum: .pure)),
                TilePlacement(5, 0, .emitter(direction: .down, spectrum: .pure)),
                TilePlacement(0, 2, .tint(spectrum: .crimson)),
                TilePlacement(5, 2, .tint(spectrum: .azure)),
                TilePlacement(2, 3, .mirror(slant: .descending)),
                TilePlacement(5, 3, .mirror(slant: .descending)),
                TilePlacement(0, 5, .mirror(slant: .ascending)),
                TilePlacement(5, 5, .crystal(required: .crimson)),
                TilePlacement(2, 6, .crystal(required: .azure))
            ]
        ),
        LevelModel(
            id: 7,
            name: "Split Beam",
            hint: "A splitter sends light two ways at once.",
            columns: 6,
            rows: 8,
            parMoves: 3,
            placements: [
                TilePlacement(2, 0, .emitter(direction: .down, spectrum: .pure)),
                TilePlacement(1, 3, .mirror(slant: .descending)),
                TilePlacement(2, 3, .splitter(turn: .counterClockwise)),
                TilePlacement(2, 6, .mirror(slant: .ascending)),
                TilePlacement(5, 6, .crystal(required: .pure)),
                TilePlacement(1, 7, .crystal(required: .pure))
            ]
        ),
        LevelModel(
            id: 8,
            name: "Two Tones",
            hint: "Split first, then tint each branch on its own.",
            columns: 6,
            rows: 8,
            parMoves: 3,
            placements: [
                TilePlacement(0, 0, .emitter(direction: .down, spectrum: .pure)),
                TilePlacement(0, 3, .splitter(turn: .clockwise)),
                TilePlacement(1, 3, .mirror(slant: .ascending)),
                TilePlacement(1, 5, .tint(spectrum: .crimson)),
                TilePlacement(0, 6, .tint(spectrum: .azure)),
                TilePlacement(1, 6, .crystal(required: .crimson)),
                TilePlacement(0, 7, .mirror(slant: .ascending)),
                TilePlacement(3, 7, .crystal(required: .azure))
            ]
        ),
        LevelModel(
            id: 9,
            name: "Mirror Hall",
            hint: "Four adjustments, two crystals. Take your time.",
            columns: 6,
            rows: 8,
            parMoves: 4,
            placements: [
                TilePlacement(0, 0, .barrier),
                TilePlacement(3, 1, .crystal(required: .pure)),
                TilePlacement(1, 1, .barrier),
                TilePlacement(4, 2, .barrier),
                TilePlacement(0, 4, .mirror(slant: .descending)),
                TilePlacement(2, 4, .splitter(turn: .counterClockwise)),
                TilePlacement(3, 4, .mirror(slant: .descending)),
                TilePlacement(2, 5, .mirror(slant: .ascending)),
                TilePlacement(4, 5, .tint(spectrum: .emerald)),
                TilePlacement(5, 5, .crystal(required: .emerald)),
                TilePlacement(0, 7, .emitter(direction: .up, spectrum: .pure))
            ]
        ),
        LevelModel(
            id: 10,
            name: "Gateways",
            hint: "Paired gateways carry the beam across the board.",
            columns: 6,
            rows: 8,
            parMoves: 2,
            placements: [
                TilePlacement(0, 0, .emitter(direction: .down, spectrum: .pure)),
                TilePlacement(5, 0, .barrier),
                TilePlacement(0, 3, .mirror(slant: .ascending)),
                TilePlacement(2, 3, .gateway(pairKey: 1)),
                TilePlacement(1, 6, .barrier),
                TilePlacement(2, 6, .gateway(pairKey: 1)),
                TilePlacement(3, 6, .mirror(slant: .ascending)),
                TilePlacement(3, 7, .crystal(required: .pure))
            ]
        ),
        LevelModel(
            id: 11,
            name: "Long Way Home",
            hint: "Split the tinted beam, then travel through the gateway.",
            columns: 6,
            rows: 8,
            parMoves: 3,
            placements: [
                TilePlacement(5, 0, .emitter(direction: .down, spectrum: .pure)),
                TilePlacement(3, 1, .crystal(required: .azure)),
                TilePlacement(5, 2, .tint(spectrum: .azure)),
                TilePlacement(0, 3, .crystal(required: .azure)),
                TilePlacement(2, 4, .gateway(pairKey: 1)),
                TilePlacement(3, 4, .splitter(turn: .counterClockwise)),
                TilePlacement(5, 4, .mirror(slant: .descending)),
                TilePlacement(0, 6, .mirror(slant: .ascending)),
                TilePlacement(3, 6, .gateway(pairKey: 1))
            ]
        ),
        LevelModel(
            id: 12,
            name: "Spectrum Split",
            hint: "One source, two colours, two very different routes.",
            columns: 6,
            rows: 8,
            parMoves: 4,
            placements: [
                TilePlacement(2, 0, .emitter(direction: .down, spectrum: .pure)),
                TilePlacement(2, 2, .splitter(turn: .clockwise)),
                TilePlacement(4, 2, .tint(spectrum: .crimson)),
                TilePlacement(5, 2, .mirror(slant: .ascending)),
                TilePlacement(2, 4, .tint(spectrum: .azure)),
                TilePlacement(5, 5, .crystal(required: .crimson)),
                TilePlacement(1, 6, .mirror(slant: .descending)),
                TilePlacement(2, 6, .mirror(slant: .descending)),
                TilePlacement(1, 7, .crystal(required: .azure))
            ]
        ),
        LevelModel(
            id: 13,
            name: "Crossroads",
            hint: "Beams may cross freely. Only crystals stop them.",
            columns: 6,
            rows: 8,
            parMoves: 4,
            placements: [
                TilePlacement(0, 0, .emitter(direction: .down, spectrum: .pure)),
                TilePlacement(0, 3, .mirror(slant: .ascending)),
                TilePlacement(2, 3, .splitter(turn: .counterClockwise)),
                TilePlacement(5, 3, .crystal(required: .pure)),
                TilePlacement(1, 4, .mirror(slant: .descending)),
                TilePlacement(5, 4, .mirror(slant: .ascending)),
                TilePlacement(2, 6, .tint(spectrum: .emerald)),
                TilePlacement(1, 7, .crystal(required: .pure)),
                TilePlacement(2, 7, .crystal(required: .emerald)),
                TilePlacement(5, 7, .emitter(direction: .up, spectrum: .pure))
            ]
        ),
        LevelModel(
            id: 14,
            name: "Colour Lock",
            hint: "Warm light goes up, cool light goes down.",
            columns: 6,
            rows: 8,
            parMoves: 4,
            placements: [
                TilePlacement(0, 0, .emitter(direction: .down, spectrum: .pure)),
                TilePlacement(3, 0, .crystal(required: .crimson)),
                TilePlacement(0, 2, .splitter(turn: .clockwise)),
                TilePlacement(2, 2, .tint(spectrum: .crimson)),
                TilePlacement(3, 2, .mirror(slant: .descending)),
                TilePlacement(0, 3, .mirror(slant: .ascending)),
                TilePlacement(2, 3, .tint(spectrum: .aqua)),
                TilePlacement(5, 3, .mirror(slant: .ascending)),
                TilePlacement(5, 5, .crystal(required: .aqua))
            ]
        ),
        LevelModel(
            id: 15,
            name: "Gate Prism",
            hint: "The gateway keeps the direction of the beam it swallows.",
            columns: 6,
            rows: 8,
            parMoves: 5,
            placements: [
                TilePlacement(0, 0, .emitter(direction: .down, spectrum: .pure)),
                TilePlacement(0, 3, .mirror(slant: .ascending)),
                TilePlacement(2, 3, .splitter(turn: .counterClockwise)),
                TilePlacement(3, 3, .mirror(slant: .ascending)),
                TilePlacement(4, 4, .crystal(required: .crimson)),
                TilePlacement(0, 5, .gateway(pairKey: 1)),
                TilePlacement(2, 5, .tint(spectrum: .azure)),
                TilePlacement(3, 5, .gateway(pairKey: 1)),
                TilePlacement(2, 6, .crystal(required: .azure)),
                TilePlacement(0, 7, .mirror(slant: .ascending)),
                TilePlacement(3, 7, .tint(spectrum: .crimson)),
                TilePlacement(4, 7, .mirror(slant: .descending))
            ]
        ),
        LevelModel(
            id: 16,
            name: "Grand Spectrum",
            hint: "Everything at once. Breathe, then light them all.",
            columns: 6,
            rows: 8,
            parMoves: 6,
            placements: [
                TilePlacement(0, 0, .emitter(direction: .down, spectrum: .pure)),
                TilePlacement(3, 0, .crystal(required: .azure)),
                TilePlacement(5, 0, .crystal(required: .azure)),
                TilePlacement(0, 2, .splitter(turn: .clockwise)),
                TilePlacement(2, 2, .mirror(slant: .ascending)),
                TilePlacement(3, 3, .mirror(slant: .ascending)),
                TilePlacement(5, 3, .splitter(turn: .clockwise)),
                TilePlacement(0, 4, .tint(spectrum: .violet)),
                TilePlacement(2, 4, .tint(spectrum: .emerald)),
                TilePlacement(2, 5, .crystal(required: .emerald)),
                TilePlacement(5, 5, .tint(spectrum: .azure)),
                TilePlacement(0, 6, .mirror(slant: .ascending)),
                TilePlacement(2, 6, .gateway(pairKey: 1)),
                TilePlacement(3, 6, .crystal(required: .violet)),
                TilePlacement(0, 7, .gateway(pairKey: 1)),
                TilePlacement(3, 7, .mirror(slant: .descending)),
                TilePlacement(5, 7, .emitter(direction: .up, spectrum: .pure))
            ]
        )
    ]
}

struct LevelProgress: Codable {
    var levelId: Int
    var isUnlocked: Bool = false
    var bestMoves: Int = 0
    var bestStars: Int = 0
    var bestTime: TimeInterval = 0
    var timesPlayed: Int = 0
    var timesCompleted: Int = 0

    var hasRecord: Bool { bestMoves > 0 }
}

struct LevelStatistics: Codable {
    var levelId: Int
    var totalMoves: Int = 0
    var totalCrystalsLit: Int = 0
    var totalGateways: Int = 0
    var totalSplits: Int = 0
    var totalColourShifts: Int = 0
    var totalPlayTime: TimeInterval = 0
    var runsStarted: Int = 0
    var runsCompleted: Int = 0
    var fewestMoves: Int = 0

    var completionRate: Double {
        guard runsStarted > 0 else { return 0 }
        return Double(runsCompleted) / Double(runsStarted) * 100
    }
}
