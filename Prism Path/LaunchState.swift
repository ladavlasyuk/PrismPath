import Foundation
import Combine

final class LaunchState: ObservableObject {
    static let shared = LaunchState()

    static let didChangeNotification = NSNotification.Name("LaunchStateDidChange")

    @Published var browserDestination: String? {
        didSet { notifyChange() }
    }
    @Published var isPrePermissionVisible: Bool = false {
        didSet { notifyChange() }
    }
    @Published var noInternetMessage: String? {
        didSet { notifyChange() }
    }

    private func notifyChange() {
        if Thread.isMainThread {
            NotificationCenter.default.post(name: LaunchState.didChangeNotification, object: nil)
        } else {
            DispatchQueue.main.async {
                NotificationCenter.default.post(name: LaunchState.didChangeNotification, object: nil)
            }
        }
    }

    private let destinationKey = "saved_browser_destination"
    private let expiresKey = "saved_browser_destination_expires"
    private let payloadKey = "saved_config_payload"
    private let permanentNativeKey = "permanent_native_flow"
    private let pushDestinationKey = "saved_push_destination"
    private let installMarkerKey = "app_install_initialized"
    private let firstServerDecisionRecordedKey = "first_server_decision_recorded"
    private let firstServerDecisionHasLinkKey = "first_server_decision_has_link"

    private(set) var pendingDestination: String?
    private(set) var didOpenPushDestination = false
    private var pushSessionLockAddress: String?

    private init() {}

    func resetPersistentStateOnFreshInstallIfNeeded() {
        let defaults = UserDefaults.standard
        guard !defaults.bool(forKey: installMarkerKey) else { return }

        defaults.set(true, forKey: installMarkerKey)

        defaults.removeObject(forKey: destinationKey)
        defaults.removeObject(forKey: expiresKey)
        defaults.removeObject(forKey: payloadKey)
        defaults.removeObject(forKey: permanentNativeKey)
        defaults.removeObject(forKey: pushDestinationKey)
        defaults.removeObject(forKey: firstServerDecisionRecordedKey)
        defaults.removeObject(forKey: firstServerDecisionHasLinkKey)
        defaults.removeObject(forKey: "push_permission_last_decline")
        defaults.removeObject(forKey: "stored_fcm_token")
        defaults.removeObject(forKey: "last_sent_push_token_in_config")
        defaults.removeObject(forKey: "push_permission_granted")

        pendingDestination = nil
        browserDestination = nil
        isPrePermissionVisible = false
        noInternetMessage = nil
        pushSessionLockAddress = nil
        didOpenPushDestination = false
    }

    func markDidOpenPushDestination() {
        didOpenPushDestination = true
    }

    func beginPushSessionLock(_ address: String) {
        pushSessionLockAddress = address
        markDidOpenPushDestination()
        noInternetMessage = nil
    }

    func shouldPersistConfigInsteadOfSessionApply() -> Bool {
        didOpenPushDestination || pushSessionLockAddress != nil
    }

    func isPushNavigationActive() -> Bool {
        shouldPersistConfigInsteadOfSessionApply()
    }

    func lastSuccessfulDestination() -> String? {
        guard !isPermanentNativeFlow() else { return nil }
        guard let destination = UserDefaults.standard.string(forKey: destinationKey),
              !destination.isEmpty else {
            return nil
        }
        return destination
    }

    func isStoredDestinationExpired(now: TimeInterval = Date().timeIntervalSince1970) -> Bool {
        guard lastSuccessfulDestination() != nil else { return true }
        let expires = UserDefaults.standard.double(forKey: expiresKey)
        if expires <= 0 {
            return true
        }
        return expires <= now
    }

    @discardableResult
    func activateStoredDestinationIfValid(now: TimeInterval = Date().timeIntervalSince1970) -> Bool {
        if isPermanentNativeFlow() {
            browserDestination = nil
            return false
        }

        guard let destination = lastSuccessfulDestination() else {
            browserDestination = nil
            return false
        }

        guard !isStoredDestinationExpired(now: now) else {
            browserDestination = nil
            return false
        }

        prepareToOpenBrowser(destination)
        return true
    }

    @discardableResult
    func activateLastSuccessfulDestinationAsFallback() -> Bool {
        if isPermanentNativeFlow() {
            return false
        }

        if isPushNavigationActive() {
            noInternetMessage = nil
            return browserDestination != nil || pendingDestination != nil || isPrePermissionVisible
        }

        guard let destination = lastSuccessfulDestination() else {
            return false
        }

        noInternetMessage = nil
        prepareToOpenBrowser(destination)
        return true
    }

    func applySessionDestination(_ destination: String) {
        guard !isPermanentNativeFlow() else { return }
        pendingDestination = nil
        isPrePermissionVisible = false
        noInternetMessage = nil
        browserDestination = destination
    }

    func saveDestination(_ destination: String, expires: TimeInterval) {
        guard !isPermanentNativeFlow() else { return }
        if didOpenPushDestination {
            persistDestinationWithoutOpening(destination, expires: expires)
            return
        }
        UserDefaults.standard.set(destination, forKey: destinationKey)
        UserDefaults.standard.set(expires, forKey: expiresKey)
        prepareToOpenBrowser(destination)
    }

    func persistDestinationWithoutOpening(_ destination: String, expires: TimeInterval) {
        guard !isPermanentNativeFlow() else { return }
        UserDefaults.standard.set(destination, forKey: destinationKey)
        UserDefaults.standard.set(expires, forKey: expiresKey)
    }

    func hasStoredDestination() -> Bool {
        lastSuccessfulDestination() != nil
    }

    func clearStoredDestination() {
        UserDefaults.standard.removeObject(forKey: destinationKey)
        UserDefaults.standard.removeObject(forKey: expiresKey)
    }

    func saveConfigPayload(_ payload: [String: Any]) {
        guard JSONSerialization.isValidJSONObject(payload),
              let data = try? JSONSerialization.data(withJSONObject: payload) else { return }
        UserDefaults.standard.set(data, forKey: payloadKey)
    }

    func storedConfigPayload() -> [String: Any]? {
        guard let data = UserDefaults.standard.data(forKey: payloadKey),
              let json = try? JSONSerialization.jsonObject(with: data),
              let payload = json as? [String: Any] else { return nil }
        return payload
    }

    func isPermanentNativeFlow() -> Bool {
        UserDefaults.standard.bool(forKey: permanentNativeKey)
    }

    func lockPermanentNativeFlow() {
        UserDefaults.standard.set(true, forKey: permanentNativeKey)
        clearStoredDestination()
        browserDestination = nil
        pushSessionLockAddress = nil
        didOpenPushDestination = false
    }

    func hasRecordedFirstServerDecision() -> Bool {
        UserDefaults.standard.bool(forKey: firstServerDecisionRecordedKey)
    }

    func recordFirstServerDecision(hasValidLink: Bool) {
        let defaults = UserDefaults.standard
        guard !defaults.bool(forKey: firstServerDecisionRecordedKey) else { return }

        defaults.set(true, forKey: firstServerDecisionRecordedKey)
        defaults.set(hasValidLink, forKey: firstServerDecisionHasLinkKey)

        if !hasValidLink {
            lockPermanentNativeFlow()
        }
    }

    func showNoInternetMessage() {
        if isPermanentNativeFlow() {
            noInternetMessage = nil
            return
        }
        if isPushNavigationActive() {
            return
        }
        if browserDestination != nil || pendingDestination != nil || isPrePermissionVisible {
            return
        }
        noInternetMessage = "No internet connection. Please turn on the internet and open the app again."
    }

    func clearNoInternetMessage() {
        noInternetMessage = nil
    }

    func clearPersistedPushDestination() {
        UserDefaults.standard.removeObject(forKey: pushDestinationKey)
    }

    func handleIncomingPushAddress(_ address: String) {
        guard !isPermanentNativeFlow() else { return }

        UserDefaults.standard.removeObject(forKey: pushDestinationKey)
        beginPushSessionLock(address)
        prepareToOpenBrowser(address)
    }

    func prepareToOpenBrowser(_ destination: String) {
        NotificationHandler.shared.shouldShowPrePermission { [weak self] shouldShow in
            guard let self = self else { return }
            if shouldShow {
                self.pendingDestination = destination
                self.browserDestination = nil
                self.isPrePermissionVisible = true
            } else {
                if self.isPrePermissionVisible {
                    return
                }
                self.pendingDestination = nil
                self.browserDestination = destination
            }
        }
    }

    func confirmPrePermissionAndOpen() {
        let target = pendingDestination
        pendingDestination = nil
        isPrePermissionVisible = false
        if let target = target {
            browserDestination = target
        }
    }
}
