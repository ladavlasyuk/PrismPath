import UIKit
import SpriteKit

final class GameViewController: UIViewController {
    var selectedLevel: LevelModel?

    private var gameScene: GameScene?
    private var sceneView: SKView!
    private var hasPresentedScene = false

    override func loadView() {
        sceneView = SKView()
        sceneView.backgroundColor = ThemeManager.shared.deepBackgroundColor
        view = sceneView
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        guard !hasPresentedScene, sceneView.bounds.width > 0, sceneView.bounds.height > 0 else { return }
        hasPresentedScene = true
        presentScene()
    }

    private func presentScene() {
        let scene = GameScene(size: sceneView.bounds.size)
        scene.scaleMode = .resizeFill
        scene.gameDelegate = self
        scene.selectedLevel = selectedLevel
        gameScene = scene

        sceneView.ignoresSiblingOrder = true
        sceneView.showsFPS = false
        sceneView.showsNodeCount = false
        sceneView.presentScene(scene)
    }

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        .portrait
    }

    override var prefersStatusBarHidden: Bool {
        true
    }
}

extension GameViewController: GameSceneDelegate {
    func gameSceneDidRequestExit(statistics: GameStatistics?) {
        if let statistics, statistics.moves > 0 {
            DataManager.shared.registerRun(statistics: statistics)
        }
        navigationController?.popViewController(animated: true)
    }

    func gameSceneDidFinish(statistics: GameStatistics) {
        DataManager.shared.registerRun(statistics: statistics)

        let resultsController = StatisticsViewController(statistics: statistics)
        resultsController.modalPresentationStyle = .fullScreen
        resultsController.onReplay = { [weak self] in
            self?.restartScene()
        }
        resultsController.onContinue = { [weak self] in
            self?.navigationController?.popViewController(animated: true)
        }
        present(resultsController, animated: true)
    }

    private func restartScene() {
        let scene = GameScene(size: sceneView.bounds.size)
        scene.scaleMode = .resizeFill
        scene.gameDelegate = self
        scene.selectedLevel = selectedLevel
        gameScene = scene
        sceneView.presentScene(scene, transition: SKTransition.fade(withDuration: 0.35))
    }
}
