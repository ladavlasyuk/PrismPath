import UIKit

enum BeamDirection: Int, CaseIterable {
    case up
    case right
    case down
    case left

    var columnStep: Int {
        switch self {
        case .up, .down: return 0
        case .right: return 1
        case .left: return -1
        }
    }

    var rowStep: Int {
        switch self {
        case .up: return -1
        case .down: return 1
        case .right, .left: return 0
        }
    }

    var clockwise: BeamDirection {
        switch self {
        case .up: return .right
        case .right: return .down
        case .down: return .left
        case .left: return .up
        }
    }

    var counterClockwise: BeamDirection {
        switch self {
        case .up: return .left
        case .left: return .down
        case .down: return .right
        case .right: return .up
        }
    }

    var opposite: BeamDirection {
        clockwise.clockwise
    }

    var pointerAngle: CGFloat {
        switch self {
        case .up: return .pi / 2
        case .right: return 0
        case .down: return -.pi / 2
        case .left: return .pi
        }
    }
}

struct GridPosition: Hashable {
    let column: Int
    let row: Int

    func advanced(by direction: BeamDirection) -> GridPosition {
        GridPosition(column: column + direction.columnStep, row: row + direction.rowStep)
    }
}

struct LightSpectrum: OptionSet, Hashable {
    let rawValue: Int

    static let crimson = LightSpectrum(rawValue: 1 << 0)
    static let emerald = LightSpectrum(rawValue: 1 << 1)
    static let azure = LightSpectrum(rawValue: 1 << 2)

    static let amber: LightSpectrum = [.crimson, .emerald]
    static let violet: LightSpectrum = [.crimson, .azure]
    static let aqua: LightSpectrum = [.emerald, .azure]
    static let pure: LightSpectrum = [.crimson, .emerald, .azure]

    var isVisible: Bool { !isEmpty }

    var displayColor: UIColor {
        switch rawValue {
        case LightSpectrum.crimson.rawValue:
            return UIColor(red: 1.0, green: 0.32, blue: 0.38, alpha: 1.0)
        case LightSpectrum.emerald.rawValue:
            return UIColor(red: 0.35, green: 0.95, blue: 0.55, alpha: 1.0)
        case LightSpectrum.azure.rawValue:
            return UIColor(red: 0.36, green: 0.66, blue: 1.0, alpha: 1.0)
        case LightSpectrum.amber.rawValue:
            return UIColor(red: 1.0, green: 0.82, blue: 0.34, alpha: 1.0)
        case LightSpectrum.violet.rawValue:
            return UIColor(red: 0.82, green: 0.45, blue: 1.0, alpha: 1.0)
        case LightSpectrum.aqua.rawValue:
            return UIColor(red: 0.40, green: 0.94, blue: 0.94, alpha: 1.0)
        case LightSpectrum.pure.rawValue:
            return UIColor(red: 0.96, green: 0.98, blue: 1.0, alpha: 1.0)
        default:
            return UIColor(white: 0.4, alpha: 1.0)
        }
    }

    var title: String {
        switch rawValue {
        case LightSpectrum.crimson.rawValue: return "Crimson"
        case LightSpectrum.emerald.rawValue: return "Emerald"
        case LightSpectrum.azure.rawValue: return "Azure"
        case LightSpectrum.amber.rawValue: return "Amber"
        case LightSpectrum.violet.rawValue: return "Violet"
        case LightSpectrum.aqua.rawValue: return "Aqua"
        case LightSpectrum.pure.rawValue: return "Pure"
        default: return "Dark"
        }
    }
}

enum MirrorSlant {
    case ascending
    case descending

    var toggled: MirrorSlant {
        self == .ascending ? .descending : .ascending
    }

    func reflected(_ direction: BeamDirection) -> BeamDirection {
        switch self {
        case .ascending:
            switch direction {
            case .right: return .up
            case .up: return .right
            case .left: return .down
            case .down: return .left
            }
        case .descending:
            switch direction {
            case .right: return .down
            case .down: return .right
            case .left: return .up
            case .up: return .left
            }
        }
    }
}

enum SplitterTurn {
    case clockwise
    case counterClockwise

    var toggled: SplitterTurn {
        self == .clockwise ? .counterClockwise : .clockwise
    }

    func branch(from direction: BeamDirection) -> BeamDirection {
        self == .clockwise ? direction.clockwise : direction.counterClockwise
    }
}

enum TileKind {
    case empty
    case barrier
    case emitter(direction: BeamDirection, spectrum: LightSpectrum)
    case mirror(slant: MirrorSlant)
    case splitter(turn: SplitterTurn)
    case tint(spectrum: LightSpectrum)
    case gateway(pairKey: Int)
    case crystal(required: LightSpectrum)

    var isAdjustable: Bool {
        switch self {
        case .mirror, .splitter:
            return true
        default:
            return false
        }
    }
}

struct TilePlacement {
    let position: GridPosition
    let kind: TileKind

    init(_ column: Int, _ row: Int, _ kind: TileKind) {
        self.position = GridPosition(column: column, row: row)
        self.kind = kind
    }
}

struct BeamSegment {
    let start: GridPosition
    let end: GridPosition
    let spectrum: LightSpectrum
    let endsOutsideBoard: Bool
}
