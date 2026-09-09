import SpriteKit

final class BeamLayerNode: SKNode {
    private let tileSize: CGFloat
    private var showsTrail: Bool

    init(tileSize: CGFloat, showsTrail: Bool) {
        self.tileSize = tileSize
        self.showsTrail = showsTrail
        super.init()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func setTrailVisible(_ visible: Bool) {
        showsTrail = visible
    }

    func render(segments: [BeamSegment], converter: (GridPosition) -> CGPoint) {
        removeAllChildren()

        for segment in segments {
            let start = converter(segment.start)
            var end = converter(segment.end)

            if segment.endsOutsideBoard {
                let deltaX = end.x - start.x
                let deltaY = end.y - start.y
                end = CGPoint(x: start.x + deltaX * 0.55, y: start.y + deltaY * 0.55)
            }

            let path = CGMutablePath()
            path.move(to: start)
            path.addLine(to: end)

            let color = segment.spectrum.displayColor

            let halo = SKShapeNode(path: path)
            halo.strokeColor = color.withAlphaComponent(0.16)
            halo.lineWidth = tileSize * 0.30
            halo.lineCap = .round
            halo.blendMode = .add
            halo.zPosition = 0
            addChild(halo)

            let core = SKShapeNode(path: path)
            core.strokeColor = color.withAlphaComponent(0.95)
            core.lineWidth = tileSize * 0.085
            core.lineCap = .round
            core.blendMode = .add
            core.zPosition = 1
            addChild(core)

            core.alpha = 0
            core.run(SKAction.fadeIn(withDuration: 0.12))
            halo.alpha = 0
            halo.run(SKAction.fadeAlpha(to: 1.0, duration: 0.18))

            if showsTrail && !segment.endsOutsideBoard {
                addTravellingSpark(from: start, to: end, color: color)
            }
        }
    }

    private func addTravellingSpark(from start: CGPoint, to end: CGPoint, color: UIColor) {
        let spark = SKShapeNode(circleOfRadius: tileSize * 0.055)
        spark.fillColor = color
        spark.strokeColor = .clear
        spark.blendMode = .add
        spark.alpha = 0.75
        spark.position = start
        spark.zPosition = 2
        addChild(spark)

        let travel = SKAction.move(to: end, duration: 0.6)
        travel.timingMode = .easeInEaseOut
        spark.run(
            SKAction.repeatForever(
                SKAction.sequence([
                    SKAction.group([travel, SKAction.fadeAlpha(to: 0.15, duration: 0.6)]),
                    SKAction.run { spark.position = start },
                    SKAction.fadeAlpha(to: 0.75, duration: 0.05)
                ])
            )
        )
    }
}
