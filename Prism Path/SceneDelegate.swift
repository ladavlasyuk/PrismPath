import UIKit
import AppsFlyerLib
import UserNotifications

final class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    var window: UIWindow?

    func scene(
        _ scene: UIScene,
        willConnectTo session: UISceneSession,
        options connectionOptions: UIScene.ConnectionOptions
    ) {
        guard let windowScene = scene as? UIWindowScene else { return }
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }

        self.window = appDelegate.attachWindow(to: windowScene)

        if let response = connectionOptions.notificationResponse {
            appDelegate.handleSceneNotificationResponse(response)
        }

        appDelegate.startLaunchFlowIfNeeded()
    }

    func sceneDidBecomeActive(_ scene: UIScene) {
        NotificationHandler.shared.clearBadgeCount()
    }

    func sceneWillEnterForeground(_ scene: UIScene) {
        NotificationHandler.shared.clearBadgeCount()
    }

    func scene(_ scene: UIScene, openURLContexts URLContexts: Set<UIOpenURLContext>) {
        guard let context = URLContexts.first else { return }
        AppsFlyerLib.shared().handleOpen(context.url, options: [:])
    }

    func scene(_ scene: UIScene, continue userActivity: NSUserActivity) {
        AppsFlyerLib.shared().continue(userActivity, restorationHandler: nil)
    }
}
