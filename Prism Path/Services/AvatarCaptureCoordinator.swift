import UIKit
import AVFoundation

final class AvatarCaptureCoordinator: NSObject {
    static let shared = AvatarCaptureCoordinator()

    private var onCapture: ((UIImage) -> Void)?
    private var retainedSelf: AvatarCaptureCoordinator?

    private override init() {
        super.init()
    }

    var isCameraAvailable: Bool {
        UIImagePickerController.isSourceTypeAvailable(.camera)
    }

    func captureFromCamera(host: UIViewController, onCapture: @escaping (UIImage) -> Void) {
        guard isCameraAvailable else {
            presentAlert(
                on: host,
                title: "Camera Unavailable",
                message: "This device has no camera available for capturing a portrait."
            )
            return
        }

        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            presentPicker(source: .camera, host: host, onCapture: onCapture)
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { [weak self] granted in
                DispatchQueue.main.async {
                    guard granted else {
                        self?.presentDeniedAlert(on: host)
                        return
                    }
                    self?.presentPicker(source: .camera, host: host, onCapture: onCapture)
                }
            }
        default:
            presentDeniedAlert(on: host)
        }
    }

    func pickFromLibrary(host: UIViewController, onCapture: @escaping (UIImage) -> Void) {
        presentPicker(source: .photoLibrary, host: host, onCapture: onCapture)
    }

    private func presentPicker(
        source: UIImagePickerController.SourceType,
        host: UIViewController,
        onCapture: @escaping (UIImage) -> Void
    ) {
        guard UIImagePickerController.isSourceTypeAvailable(source) else { return }

        self.onCapture = onCapture
        retainedSelf = self

        let picker = UIImagePickerController()
        picker.sourceType = source
        picker.delegate = self
        picker.allowsEditing = true
        picker.modalPresentationStyle = .fullScreen

        if source == .camera {
            picker.cameraCaptureMode = .photo
            if UIImagePickerController.isCameraDeviceAvailable(.front) {
                picker.cameraDevice = .front
            }
        }

        host.present(picker, animated: true)
    }

    private func presentDeniedAlert(on host: UIViewController) {
        let alert = UIAlertController(
            title: "Camera Access Needed",
            message: "Allow camera access in system settings to take a portrait.",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "Not Now", style: .cancel))
        alert.addAction(UIAlertAction(title: "Open Settings", style: .default) { _ in
            guard let destination = URL(string: UIApplication.openSettingsURLString) else { return }
            UIApplication.shared.open(destination)
        })
        host.present(alert, animated: true)
    }

    private func presentAlert(on host: UIViewController, title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        host.present(alert, animated: true)
    }

    private func finish() {
        onCapture = nil
        retainedSelf = nil
    }
}

extension AvatarCaptureCoordinator: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(
        _ picker: UIImagePickerController,
        didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]
    ) {
        let picked = (info[.editedImage] as? UIImage) ?? (info[.originalImage] as? UIImage)
        let handler = onCapture
        picker.dismiss(animated: true) { [weak self] in
            if let picked {
                handler?(picked)
            }
            self?.finish()
        }
    }

    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true) { [weak self] in
            self?.finish()
        }
    }
}
