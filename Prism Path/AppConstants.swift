import Foundation

enum AppConstants {
    static let appsFlyerDevKey = "VD2TTdSGyE3xaQckAUL559"
    static let appsFlyerAppleAppID = "6803726021"

    static var bundleID: String {
        Bundle.main.bundleIdentifier ?? "com.PrismPathLightPuzzle"
    }
    static var storeID: String {
        "id\(appsFlyerAppleAppID)"
    }

    static let configEndpoint = "https://prismpathlightpuzzle.site/config.php"

    static let privacyPolicyAddress = "https://prismpathlightpuzzle.site/privacy-policy.html"

    static let osName = "IOS"
    static let pushTokenPlaceholder = "00000000000000000000"
    static let firebaseProjectID = "798631805186"

    static let gcdRetryDelay: TimeInterval = 1.0
    static let mergeWaitInterval: TimeInterval = 3.0
    static let launchLoaderDuration: TimeInterval = 15.0

    static let pushPermissionRetryDelay: TimeInterval = 60 * 60 * 24 * 3

    static let pushDataAddressKey = "url"
}
