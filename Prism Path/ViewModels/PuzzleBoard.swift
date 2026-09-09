import Foundation

struct BeamTraceResult {
    var segments: [BeamSegment] = []
    var litCrystals: Set<GridPosition> = []
    var energisedTiles: [GridPosition: LightSpectrum] = [:]
    var gatewayJumps: Int = 0
    var splits: Int = 0
    var colourShifts: Int = 0
}

private struct BeamState: Hashable {
    let origin: GridPosition
    let direction: BeamDirection
    let spectrum: Int
}

private struct BeamRay {
    let origin: GridPosition
    let direction: BeamDirection
    let spectrum: LightSpectrum
}

final class PuzzleBoard {
    let level: LevelModel
    private(set) var tiles: [[TileKind]]

    private let maximumSteps = 900

    init(level: LevelModel) {
        self.level = level
        self.tiles = Array(
            repeating: Array(repeating: TileKind.empty, count: level.columns),
            count: level.rows
        )
        applyInitialPlacements()
    }

    var columns: Int { level.columns }
    var rows: Int { level.rows }

    func contains(_ position: GridPosition) -> Bool {
        position.column >= 0 && position.column < columns
            && position.row >= 0 && position.row < rows
    }

    func kind(at position: GridPosition) -> TileKind {
        guard contains(position) else { return .barrier }
        return tiles[position.row][position.column]
    }

    var crystalPositions: [GridPosition] {
        var result: [GridPosition] = []
        for row in 0..<rows {
            for column in 0..<columns {
                if case .crystal = tiles[row][column] {
                    result.append(GridPosition(column: column, row: row))
                }
            }
        }
        return result
    }

    var adjustablePositions: [GridPosition] {
        var result: [GridPosition] = []
        for row in 0..<rows {
            for column in 0..<columns where tiles[row][column].isAdjustable {
                result.append(GridPosition(column: column, row: row))
            }
        }
        return result
    }

    func reset() {
        tiles = Array(
            repeating: Array(repeating: TileKind.empty, count: level.columns),
            count: level.rows
        )
        applyInitialPlacements()
    }

    @discardableResult
    func adjustTile(at position: GridPosition) -> Bool {
        guard contains(position) else { return false }
        switch tiles[position.row][position.column] {
        case .mirror(let slant):
            tiles[position.row][position.column] = .mirror(slant: slant.toggled)
            return true
        case .splitter(let turn):
            tiles[position.row][position.column] = .splitter(turn: turn.toggled)
            return true
        default:
            return false
        }
    }

    func setTile(_ kind: TileKind, at position: GridPosition) {
        guard contains(position) else { return }
        tiles[position.row][position.column] = kind
    }

    private func applyInitialPlacements() {
        for placement in level.placements {
            guard contains(placement.position) else { continue }
            tiles[placement.position.row][placement.position.column] = placement.kind
        }
    }

    private func gatewayPartner(of position: GridPosition, key: Int) -> GridPosition? {
        for row in 0..<rows {
            for column in 0..<columns {
                let candidate = GridPosition(column: column, row: row)
                guard candidate != position else { continue }
                if case .gateway(let otherKey) = tiles[row][column], otherKey == key {
                    return candidate
                }
            }
        }
        return nil
    }

    func trace() -> BeamTraceResult {
        var result = BeamTraceResult()
        var visited = Set<BeamState>()
        var pending: [BeamRay] = []

        for row in 0..<rows {
            for column in 0..<columns {
                if case .emitter(let direction, let spectrum) = tiles[row][column] {
                    let origin = GridPosition(column: column, row: row)
                    pending.append(BeamRay(origin: origin, direction: direction, spectrum: spectrum))
                    result.energisedTiles[origin] = spectrum
                }
            }
        }

        var steps = 0

        while let ray = pending.popLast() {
            steps += 1
            guard steps < maximumSteps else { break }

            let state = BeamState(
                origin: ray.origin,
                direction: ray.direction,
                spectrum: ray.spectrum.rawValue
            )
            guard !visited.contains(state) else { continue }
            visited.insert(state)

            let next = ray.origin.advanced(by: ray.direction)

            guard contains(next) else {
                result.segments.append(
                    BeamSegment(
                        start: ray.origin,
                        end: next,
                        spectrum: ray.spectrum,
                        endsOutsideBoard: true
                    )
                )
                continue
            }

            result.segments.append(
                BeamSegment(
                    start: ray.origin,
                    end: next,
                    spectrum: ray.spectrum,
                    endsOutsideBoard: false
                )
            )

            switch tiles[next.row][next.column] {
            case .empty:
                mark(&result, next, ray.spectrum)
                pending.append(
                    BeamRay(origin: next, direction: ray.direction, spectrum: ray.spectrum)
                )

            case .barrier, .emitter:
                continue

            case .mirror(let slant):
                mark(&result, next, ray.spectrum)
                pending.append(
                    BeamRay(
                        origin: next,
                        direction: slant.reflected(ray.direction),
                        spectrum: ray.spectrum
                    )
                )

            case .splitter(let turn):
                mark(&result, next, ray.spectrum)
                result.splits += 1
                pending.append(
                    BeamRay(origin: next, direction: ray.direction, spectrum: ray.spectrum)
                )
                pending.append(
                    BeamRay(
                        origin: next,
                        direction: turn.branch(from: ray.direction),
                        spectrum: ray.spectrum
                    )
                )

            case .tint(let spectrum):
                let filtered = ray.spectrum.intersection(spectrum)
                mark(&result, next, filtered.isVisible ? filtered : ray.spectrum)
                guard filtered.isVisible else { continue }
                if filtered != ray.spectrum {
                    result.colourShifts += 1
                }
                pending.append(
                    BeamRay(origin: next, direction: ray.direction, spectrum: filtered)
                )

            case .gateway(let key):
                mark(&result, next, ray.spectrum)
                guard let partner = gatewayPartner(of: next, key: key) else { continue }
                result.gatewayJumps += 1
                mark(&result, partner, ray.spectrum)
                pending.append(
                    BeamRay(origin: partner, direction: ray.direction, spectrum: ray.spectrum)
                )

            case .crystal(let required):
                mark(&result, next, ray.spectrum)
                if ray.spectrum == required {
                    result.litCrystals.insert(next)
                }
            }
        }

        return result
    }

    private func mark(_ result: inout BeamTraceResult, _ position: GridPosition, _ spectrum: LightSpectrum) {
        let existing = result.energisedTiles[position] ?? []
        result.energisedTiles[position] = existing.union(spectrum)
    }
}
