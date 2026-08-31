import SpriteKit

protocol GameSceneDelegate: AnyObject {
    func gameSceneDidRequestExit(statistics: GameStatistics?)
    func gameSceneDidFinish(statistics: GameStatistics)
}

final class GameScene: SKScene {
    weak var gameDelegate: GameSceneDelegate?
    var selectedLevel: LevelModel?

    private var viewModel: GameViewModel?
    private var tileNodes: [GridPosition: TileNode] = [:]
    private var beamLayer: BeamLayerNode?
    private var hud: HUDNode?
    private let boardLayer = SKNode()

    private var tileSize: CGFloat = 44
    private var boardCenter: CGPoint = .zero
    private var hasFinished = false

    override func didMove(to view: SKView) {
        backgroundColor = ThemeManager.shared.deepBackgroundColor
        buildAtmosphere()
        buildBoard()
    }

    private func buildAtmosphere() {
        let gradient = SKShapeNode(rect: CGRect(origin: .zero, size: size))
        gradient.fillColor = ThemeManager.shared.backgroundColor
        gradient.strokeColor = .clear
        gradient.zPosition = -10
        addChild(gradient)

        for index in 0..<7 {
            let radius = CGFloat.random(in: size.width * 0.18...size.width * 0.38)
            let blob = SKShapeNode(circleOfRadius: radius)
            blob.fillColor = (index % 2 == 0
                ? ThemeManager.shared.primaryColor
                : ThemeManager.shared.highlightColor).withAlphaComponent(0.05)
            blob.strokeColor = .clear
            blob.blendMode = .add
            blob.zPosition = -9
            blob.position = CGPoint(
                x: CGFloat.random(in: 0...size.width),
                y: CGFloat.random(in: 0...size.height)
            )
            addChild(blob)

            let drift = SKAction.sequence([
                SKAction.moveBy(x: CGFloat.random(in: -40...40), y: CGFloat.random(in: -60...60), duration: Double.random(in: 9...14)),
                SKAction.moveBy(x: CGFloat.random(in: -40...40), y: CGFloat.random(in: -60...60), duration: Double.random(in: 9...14))
            ])
            blob.run(SKAction.repeatForever(drift))
        }

        for _ in 0..<40 {
            let dust = SKShapeNode(circleOfRadius: CGFloat.random(in: 0.7...1.8))
            dust.fillColor = UIColor(white: 1.0, alpha: CGFloat.random(in: 0.10...0.35))
            dust.strokeColor = .clear
            dust.zPosition = -8
            dust.position = CGPoint(
                x: CGFloat.random(in: 0...size.width),
                y: CGFloat.random(in: 0...size.height)
            )
            addChild(dust)

            let float = SKAction.sequence([
                SKAction.moveBy(x: 0, y: CGFloat.random(in: 14...36), duration: Double.random(in: 5...9)),
                SKAction.moveBy(x: 0, y: CGFloat.random(in: -36 ... -14), duration: Double.random(in: 5...9))
            ])
            dust.run(SKAction.repeatForever(float))
        }
    }

    private func buildBoard() {
        guard let level = selectedLevel else { return }

        let model = GameViewModel(level: level)
        viewModel = model

        let topInset = view?.safeAreaInsets.top ?? 44
        let bottomInset = view?.safeAreaInsets.bottom ?? 20

        let hudNode = HUDNode(sceneSize: size, topInset: topInset, bottomInset: bottomInset)
        hudNode.zPosition = 50
        hudNode.configure(levelName: level.name.uppercased(), hint: level.hint)
        addChild(hudNode)
        hud = hudNode

        let horizontalMargin: CGFloat = 20
        let reservedTop = topInset + 96
        let reservedBottom = bottomInset + 78

        let availableWidth = size.width - horizontalMargin * 2
        let availableHeight = size.height - reservedTop - reservedBottom

        tileSize = min(availableWidth / CGFloat(level.columns), availableHeight / CGFloat(level.rows))
        boardCenter = CGPoint(x: size.width / 2, y: reservedBottom + availableHeight / 2)

        boardLayer.zPosition = 10
        addChild(boardLayer)

        let boardWidth = tileSize * CGFloat(level.columns) + 14
        let boardHeight = tileSize * CGFloat(level.rows) + 14
        let backdrop = SKShapeNode(
            path: CGPath(
                roundedRect: CGRect(
                    x: boardCenter.x - boardWidth / 2,
                    y: boardCenter.y - boardHeight / 2,
                    width: boardWidth,
                    height: boardHeight
                ),
                cornerWidth: 22,
                cornerHeight: 22,
                transform: nil
            )
        )
        backdrop.fillColor = UIColor(white: 1.0, alpha: 0.035)
        backdrop.strokeColor = UIColor(white: 1.0, alpha: 0.09)
        backdrop.lineWidth = 1
        backdrop.zPosition = 5
        addChild(backdrop)

        for row in 0..<level.rows {
            for column in 0..<level.columns {
                let position = GridPosition(column: column, row: row)
                let node = TileNode(
                    kind: model.board.kind(at: position),
                    gridPosition: position,
                    tileSize: tileSize
                )
                node.position = point(for: position)
                node.zPosition = 20
                boardLayer.addChild(node)
                tileNodes[position] = node
            }
        }

        let beams = BeamLayerNode(
            tileSize: tileSize,
            showsTrail: DataManager.shared.loadSettings().showsBeamTrail
        )
        beams.zPosition = 15
        addChild(beams)
        beamLayer = beams

        refreshVisuals()
    }

    private func point(for position: GridPosition) -> CGPoint {
        guard let level = selectedLevel else { return .zero }
        let offsetX = (CGFloat(position.column) - CGFloat(level.columns - 1) / 2) * tileSize
        let offsetY = (CGFloat(position.row) - CGFloat(level.rows - 1) / 2) * tileSize
        return CGPoint(x: boardCenter.x + offsetX, y: boardCenter.y - offsetY)
    }

    private func gridPosition(at point: CGPoint) -> GridPosition? {
        guard let level = selectedLevel else { return nil }
        let column = Int(((point.x - boardCenter.x) / tileSize + CGFloat(level.columns - 1) / 2).rounded())
        let row = Int((-(point.y - boardCenter.y) / tileSize + CGFloat(level.rows - 1) / 2).rounded())
        let position = GridPosition(column: column, row: row)
        guard column >= 0, column < level.columns, row >= 0, row < level.rows else { return nil }
        return position
    }

    private func refreshVisuals() {
        guard let model = viewModel else { return }

        beamLayer?.render(segments: model.trace.segments) { [weak self] position in
            self?.point(for: position) ?? .zero
        }

        for (position, node) in tileNodes {
            node.applyEnergy(
                model.trace.energisedTiles[position],
                isLit: model.trace.litCrystals.contains(position)
            )
        }

        hud?.update(
            moves: model.moves,
            par: model.level.parMoves,
            crystalsLit: model.crystalsLit,
            totalCrystals: model.totalCrystals
        )
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)

        for node in nodes(at: location) {
            if node.name == HUDNode.menuButtonName {
                HapticsManager.shared.lightImpact()
                AudioManager.shared.playTapSound()
                let unfinished = hasFinished ? nil : viewModel?.makeStatistics()
                gameDelegate?.gameSceneDidRequestExit(statistics: unfinished)
                return
            }
            if node.name == HUDNode.resetButtonName {
                HapticsManager.shared.mediumImpact()
                AudioManager.shared.playResetSound()
                restartLevel()
                return
            }
        }

        guard !hasFinished, let position = gridPosition(at: location), let model = viewModel else { return }
        guard model.board.kind(at: position).isAdjustable else {
            if case .crystal = model.board.kind(at: position) {
                hud?.showMessage("Match the crystal colour to light it up.")
            }
            return
        }

        let previousLit = model.crystalsLit
        guard model.adjust(at: position) else { return }

        tileNodes[position]?.update(kind: model.board.kind(at: position), animated: true)
        HapticsManager.shared.lightImpact()
        AudioManager.shared.playRotateSound()
        refreshVisuals()

        if model.isSolved {
            finishLevel()
        } else if model.crystalsLit > previousLit {
            AudioManager.shared.playCrystalSound()
        }
    }

    private func restartLevel() {
        guard let model = viewModel, !hasFinished else { return }
        model.restart()
        for (position, node) in tileNodes {
            node.update(kind: model.board.kind(at: position), animated: false)
        }
        refreshVisuals()
        hud?.showMessage(model.level.hint)
    }

    private func finishLevel() {
        guard !hasFinished else { return }
        hasFinished = true

        HapticsManager.shared.success()
        AudioManager.shared.playLevelCompleteSound()
        hud?.showMessage("All crystals resonate. Beautiful path.")
        celebrate()

        let statistics = viewModel?.makeStatistics()
        run(
            SKAction.sequence([
                SKAction.wait(forDuration: 1.4),
                SKAction.run { [weak self] in
                    guard let self, let statistics else { return }
                    self.gameDelegate?.gameSceneDidFinish(statistics: statistics)
                }
            ])
        )
    }

    private func celebrate() {
        guard let model = viewModel else { return }
        for position in model.trace.litCrystals {
            guard let node = tileNodes[position] else { continue }
            for index in 0..<10 {
                let spark = SKShapeNode(circleOfRadius: tileSize * 0.05)
                spark.fillColor = UIColor(white: 1.0, alpha: 0.9)
                spark.strokeColor = .clear
                spark.blendMode = .add
                spark.position = node.position
                spark.zPosition = 30
                addChild(spark)

                let angle = CGFloat(index) * .pi / 5
                let distance = tileSize * CGFloat.random(in: 0.7...1.5)
                spark.run(
                    SKAction.sequence([
                        SKAction.group([
                            SKAction.moveBy(x: cos(angle) * distance, y: sin(angle) * distance, duration: 0.7),
                            SKAction.fadeOut(withDuration: 0.7),
                            SKAction.scale(to: 0.2, duration: 0.7)
                        ]),
                        SKAction.removeFromParent()
                    ])
                )
            }
        }
    }
}
