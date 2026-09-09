import SpriteKit

final class HUDNode: SKNode {
    static let menuButtonName = "hudMenuButton"
    static let resetButtonName = "hudResetButton"

    private let sceneSize: CGSize
    private let titleLabel = SKLabelNode(fontNamed: "AvenirNext-DemiBold")
    private let movesLabel = SKLabelNode(fontNamed: "AvenirNext-Bold")
    private let crystalsLabel = SKLabelNode(fontNamed: "AvenirNext-Bold")
    private let hintLabel = SKLabelNode(fontNamed: "AvenirNext-Medium")

    init(sceneSize: CGSize, topInset: CGFloat, bottomInset: CGFloat) {
        self.sceneSize = sceneSize
        super.init()
        build(topInset: topInset, bottomInset: bottomInset)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func build(topInset: CGFloat, bottomInset: CGFloat) {
        let topY = sceneSize.height - topInset - 26

        titleLabel.fontSize = 19
        titleLabel.fontColor = .white
        titleLabel.horizontalAlignmentMode = .center
        titleLabel.verticalAlignmentMode = .center
        titleLabel.position = CGPoint(x: sceneSize.width / 2, y: topY)
        addChild(titleLabel)

        let menuButton = makeButton(title: "MENU", name: HUDNode.menuButtonName, width: 84)
        menuButton.position = CGPoint(x: 22 + 42, y: topY)
        addChild(menuButton)

        let resetButton = makeButton(title: "RESET", name: HUDNode.resetButtonName, width: 84)
        resetButton.position = CGPoint(x: sceneSize.width - 22 - 42, y: topY)
        addChild(resetButton)

        movesLabel.fontSize = 15
        movesLabel.fontColor = UIColor(white: 1.0, alpha: 0.75)
        movesLabel.horizontalAlignmentMode = .left
        movesLabel.verticalAlignmentMode = .center
        movesLabel.position = CGPoint(x: 26, y: topY - 38)
        addChild(movesLabel)

        crystalsLabel.fontSize = 15
        crystalsLabel.fontColor = UIColor(white: 1.0, alpha: 0.75)
        crystalsLabel.horizontalAlignmentMode = .right
        crystalsLabel.verticalAlignmentMode = .center
        crystalsLabel.position = CGPoint(x: sceneSize.width - 26, y: topY - 38)
        addChild(crystalsLabel)

        hintLabel.fontSize = 14
        hintLabel.fontColor = UIColor(white: 1.0, alpha: 0.55)
        hintLabel.horizontalAlignmentMode = .center
        hintLabel.verticalAlignmentMode = .center
        hintLabel.preferredMaxLayoutWidth = sceneSize.width - 56
        hintLabel.numberOfLines = 2
        hintLabel.position = CGPoint(x: sceneSize.width / 2, y: bottomInset + 34)
        addChild(hintLabel)
    }

    private func makeButton(title: String, name: String, width: CGFloat) -> SKNode {
        let container = SKNode()
        container.name = name

        let rect = CGRect(x: -width / 2, y: -16, width: width, height: 32)
        let plate = SKShapeNode(path: CGPath(roundedRect: rect, cornerWidth: 16, cornerHeight: 16, transform: nil))
        plate.fillColor = UIColor(white: 1.0, alpha: 0.10)
        plate.strokeColor = UIColor(white: 1.0, alpha: 0.22)
        plate.lineWidth = 1
        plate.name = name
        container.addChild(plate)

        let label = SKLabelNode(fontNamed: "AvenirNext-DemiBold")
        label.text = title
        label.fontSize = 13
        label.fontColor = .white
        label.verticalAlignmentMode = .center
        label.horizontalAlignmentMode = .center
        label.name = name
        container.addChild(label)

        return container
    }

    func configure(levelName: String, hint: String) {
        titleLabel.text = levelName
        hintLabel.text = hint
    }

    func update(moves: Int, par: Int, crystalsLit: Int, totalCrystals: Int) {
        movesLabel.text = "MOVES \(moves)  ·  PAR \(par)"
        crystalsLabel.text = "CRYSTALS \(crystalsLit)/\(totalCrystals)"
        crystalsLabel.fontColor = crystalsLit == totalCrystals
            ? ThemeManager.shared.highlightColor
            : UIColor(white: 1.0, alpha: 0.75)
    }

    func showMessage(_ text: String) {
        hintLabel.removeAllActions()
        hintLabel.text = text
        hintLabel.alpha = 0
        hintLabel.run(SKAction.fadeAlpha(to: 0.85, duration: 0.25))
    }
}
