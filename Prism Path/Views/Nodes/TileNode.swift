import SpriteKit

final class TileNode: SKNode {
    let gridPosition: GridPosition
    private(set) var kind: TileKind

    private let tileSize: CGFloat
    private let basePlate = SKShapeNode()
    private let glyphLayer = SKNode()
    private let glowLayer = SKNode()

    private var isCrystalLit = false

    init(kind: TileKind, gridPosition: GridPosition, tileSize: CGFloat) {
        self.kind = kind
        self.gridPosition = gridPosition
        self.tileSize = tileSize
        super.init()

        addChild(glowLayer)
        addChild(basePlate)
        addChild(glyphLayer)

        buildBasePlate()
        rebuildGlyph()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private var inset: CGFloat { tileSize * 0.9 }

    private func buildBasePlate() {
        let side = inset
        let rect = CGRect(x: -side / 2, y: -side / 2, width: side, height: side)
        basePlate.path = CGPath(roundedRect: rect, cornerWidth: side * 0.22, cornerHeight: side * 0.22, transform: nil)
        basePlate.lineWidth = 1

        switch kind {
        case .empty:
            basePlate.fillColor = UIColor(white: 1.0, alpha: 0.03)
            basePlate.strokeColor = UIColor(white: 1.0, alpha: 0.07)
        case .barrier:
            basePlate.fillColor = UIColor(white: 0.10, alpha: 0.95)
            basePlate.strokeColor = UIColor(white: 1.0, alpha: 0.10)
        default:
            basePlate.fillColor = UIColor(white: 1.0, alpha: 0.07)
            basePlate.strokeColor = UIColor(white: 1.0, alpha: 0.16)
        }
    }

    func update(kind newKind: TileKind, animated: Bool) {
        kind = newKind
        if animated {
            glyphLayer.run(
                SKAction.sequence([
                    SKAction.group([
                        SKAction.scale(to: 0.72, duration: 0.09),
                        SKAction.fadeAlpha(to: 0.35, duration: 0.09)
                    ]),
                    SKAction.run { [weak self] in self?.rebuildGlyph() },
                    SKAction.group([
                        SKAction.scale(to: 1.0, duration: 0.14),
                        SKAction.fadeAlpha(to: 1.0, duration: 0.14)
                    ])
                ])
            )
        } else {
            rebuildGlyph()
        }
    }

    func applyEnergy(_ spectrum: LightSpectrum?, isLit: Bool) {
        switch kind {
        case .crystal(let required):
            guard isLit != isCrystalLit else { return }
            isCrystalLit = isLit
            rebuildGlyph()
            if isLit {
                pulseGlow(color: required.displayColor)
            }
        case .empty, .barrier:
            break
        default:
            let alpha: CGFloat = (spectrum?.isVisible ?? false) ? 0.20 : 0.07
            basePlate.fillColor = UIColor(white: 1.0, alpha: alpha)
        }
    }

    private func pulseGlow(color: UIColor) {
        let halo = SKShapeNode(circleOfRadius: tileSize * 0.45)
        halo.fillColor = color.withAlphaComponent(0.35)
        halo.strokeColor = .clear
        halo.blendMode = .add
        halo.zPosition = -1
        glowLayer.addChild(halo)
        halo.run(
            SKAction.sequence([
                SKAction.group([
                    SKAction.scale(to: 2.1, duration: 0.55),
                    SKAction.fadeOut(withDuration: 0.55)
                ]),
                SKAction.removeFromParent()
            ])
        )
    }

    private func rebuildGlyph() {
        glyphLayer.removeAllChildren()
        buildBasePlate()

        switch kind {
        case .empty:
            break
        case .barrier:
            buildBarrier()
        case .emitter(let direction, let spectrum):
            buildEmitter(direction: direction, spectrum: spectrum)
        case .mirror(let slant):
            buildMirror(slant: slant)
        case .splitter(let turn):
            buildSplitter(turn: turn)
        case .tint(let spectrum):
            buildTint(spectrum: spectrum)
        case .gateway(let key):
            buildGateway(key: key)
        case .crystal(let required):
            buildCrystal(required: required)
        }
    }

    private func buildBarrier() {
        let span = inset * 0.32
        for offset in [-span, 0, span] {
            let path = CGMutablePath()
            path.move(to: CGPoint(x: offset - span, y: -span))
            path.addLine(to: CGPoint(x: offset + span, y: span))
            let line = SKShapeNode(path: path)
            line.strokeColor = UIColor(white: 1.0, alpha: 0.18)
            line.lineWidth = 2
            line.lineCap = .round
            glyphLayer.addChild(line)
        }
    }

    private func buildEmitter(direction: BeamDirection, spectrum: LightSpectrum) {
        let color = spectrum.displayColor

        let body = SKShapeNode(circleOfRadius: inset * 0.30)
        body.fillColor = color.withAlphaComponent(0.85)
        body.strokeColor = color
        body.lineWidth = 2
        body.glowWidth = 3
        glyphLayer.addChild(body)

        let ring = SKShapeNode(circleOfRadius: inset * 0.40)
        ring.fillColor = .clear
        ring.strokeColor = color.withAlphaComponent(0.45)
        ring.lineWidth = 2
        glyphLayer.addChild(ring)

        let nozzle = CGMutablePath()
        let reach = inset * 0.46
        nozzle.move(to: CGPoint(x: reach, y: -inset * 0.14))
        nozzle.addLine(to: CGPoint(x: reach + inset * 0.14, y: 0))
        nozzle.addLine(to: CGPoint(x: reach, y: inset * 0.14))
        nozzle.closeSubpath()

        let arrow = SKShapeNode(path: nozzle)
        arrow.fillColor = color
        arrow.strokeColor = .clear
        arrow.zRotation = direction.pointerAngle
        glyphLayer.addChild(arrow)

        ring.run(
            SKAction.repeatForever(
                SKAction.sequence([
                    SKAction.scale(to: 1.12, duration: 1.4),
                    SKAction.scale(to: 1.0, duration: 1.4)
                ])
            )
        )
    }

    private func buildMirror(slant: MirrorSlant) {
        let reach = inset * 0.38
        let path = CGMutablePath()
        switch slant {
        case .ascending:
            path.move(to: CGPoint(x: -reach, y: -reach))
            path.addLine(to: CGPoint(x: reach, y: reach))
        case .descending:
            path.move(to: CGPoint(x: -reach, y: reach))
            path.addLine(to: CGPoint(x: reach, y: -reach))
        }

        let shadow = SKShapeNode(path: path)
        shadow.strokeColor = UIColor(white: 1.0, alpha: 0.18)
        shadow.lineWidth = inset * 0.24
        shadow.lineCap = .round
        glyphLayer.addChild(shadow)

        let surface = SKShapeNode(path: path)
        surface.strokeColor = UIColor(red: 0.82, green: 0.92, blue: 1.0, alpha: 1.0)
        surface.lineWidth = inset * 0.11
        surface.lineCap = .round
        surface.glowWidth = 1.5
        glyphLayer.addChild(surface)
    }

    private func buildSplitter(turn: SplitterTurn) {
        let reach = inset * 0.36
        let prism = CGMutablePath()
        prism.move(to: CGPoint(x: 0, y: reach))
        prism.addLine(to: CGPoint(x: reach, y: -reach * 0.7))
        prism.addLine(to: CGPoint(x: -reach, y: -reach * 0.7))
        prism.closeSubpath()

        let body = SKShapeNode(path: prism)
        body.fillColor = UIColor(white: 1.0, alpha: 0.22)
        body.strokeColor = UIColor(white: 1.0, alpha: 0.75)
        body.lineWidth = 2
        body.lineJoin = .round
        glyphLayer.addChild(body)

        let radius = inset * 0.46
        let start: CGFloat = turn == .clockwise ? .pi * 0.85 : .pi * 0.15
        let end: CGFloat = turn == .clockwise ? .pi * 0.15 : .pi * 0.85
        let arcPath = CGMutablePath()
        arcPath.addArc(
            center: .zero,
            radius: radius,
            startAngle: start,
            endAngle: end,
            clockwise: turn == .clockwise
        )

        let arc = SKShapeNode(path: arcPath)
        arc.strokeColor = ThemeManager.shared.highlightColor.withAlphaComponent(0.85)
        arc.lineWidth = 2
        arc.lineCap = .round
        glyphLayer.addChild(arc)

        let tipAngle = end
        let tip = CGPoint(x: cos(tipAngle) * radius, y: sin(tipAngle) * radius)
        let head = CGMutablePath()
        head.move(to: CGPoint(x: -inset * 0.07, y: -inset * 0.06))
        head.addLine(to: CGPoint(x: inset * 0.07, y: 0))
        head.addLine(to: CGPoint(x: -inset * 0.07, y: inset * 0.06))
        head.closeSubpath()

        let headNode = SKShapeNode(path: head)
        headNode.fillColor = ThemeManager.shared.highlightColor
        headNode.strokeColor = .clear
        headNode.position = tip
        headNode.zRotation = tipAngle + (turn == .clockwise ? -.pi / 2 : .pi / 2)
        glyphLayer.addChild(headNode)
    }

    private func buildTint(spectrum: LightSpectrum) {
        let color = spectrum.displayColor
        let side = inset * 0.74
        let rect = CGRect(x: -side / 2, y: -side / 2, width: side, height: side)

        let pane = SKShapeNode(path: CGPath(roundedRect: rect, cornerWidth: side * 0.24, cornerHeight: side * 0.24, transform: nil))
        pane.fillColor = color.withAlphaComponent(0.35)
        pane.strokeColor = color.withAlphaComponent(0.9)
        pane.lineWidth = 2
        glyphLayer.addChild(pane)

        let core = SKShapeNode(circleOfRadius: side * 0.20)
        core.fillColor = color.withAlphaComponent(0.9)
        core.strokeColor = .clear
        core.blendMode = .add
        glyphLayer.addChild(core)
    }

    private func buildGateway(key: Int) {
        let color = ThemeManager.shared.highlightColor

        let outer = SKShapeNode(circleOfRadius: inset * 0.38)
        outer.fillColor = color.withAlphaComponent(0.12)
        outer.strokeColor = color.withAlphaComponent(0.85)
        outer.lineWidth = 2
        glyphLayer.addChild(outer)

        let inner = SKShapeNode(circleOfRadius: inset * 0.20)
        inner.fillColor = .clear
        inner.strokeColor = color.withAlphaComponent(0.6)
        inner.lineWidth = 1.5
        glyphLayer.addChild(inner)

        let label = SKLabelNode(fontNamed: "AvenirNext-Bold")
        label.text = String(UnicodeScalar(UInt8(65 + max(0, min(25, key - 1)))))
        label.fontSize = inset * 0.28
        label.fontColor = color
        label.verticalAlignmentMode = .center
        label.horizontalAlignmentMode = .center
        glyphLayer.addChild(label)

        inner.run(
            SKAction.repeatForever(
                SKAction.sequence([
                    SKAction.scale(to: 1.25, duration: 1.1),
                    SKAction.scale(to: 1.0, duration: 1.1)
                ])
            )
        )
    }

    private func buildCrystal(required: LightSpectrum) {
        let color = required.displayColor
        let radius = inset * 0.36
        let path = CGMutablePath()
        for index in 0..<6 {
            let angle = CGFloat(index) * .pi / 3 + .pi / 6
            let point = CGPoint(x: cos(angle) * radius, y: sin(angle) * radius)
            if index == 0 {
                path.move(to: point)
            } else {
                path.addLine(to: point)
            }
        }
        path.closeSubpath()

        let shell = SKShapeNode(path: path)
        shell.lineWidth = 2.5
        shell.lineJoin = .round
        shell.strokeColor = color
        shell.fillColor = isCrystalLit ? color.withAlphaComponent(0.8) : color.withAlphaComponent(0.10)
        shell.glowWidth = isCrystalLit ? 4 : 0
        glyphLayer.addChild(shell)

        let facet = CGMutablePath()
        facet.move(to: CGPoint(x: 0, y: radius * 0.85))
        facet.addLine(to: CGPoint(x: 0, y: -radius * 0.85))
        let facetNode = SKShapeNode(path: facet)
        facetNode.strokeColor = color.withAlphaComponent(isCrystalLit ? 0.9 : 0.35)
        facetNode.lineWidth = 1
        glyphLayer.addChild(facetNode)

        if isCrystalLit {
            shell.run(
                SKAction.repeatForever(
                    SKAction.sequence([
                        SKAction.scale(to: 1.08, duration: 0.8),
                        SKAction.scale(to: 1.0, duration: 0.8)
                    ])
                )
            )
        }
    }
}
