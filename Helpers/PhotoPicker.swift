import SwiftUI
import PhotosUI

/// Обёртка над PHPicker, возвращает массив UIImage.
struct PhotoPicker: UIViewControllerRepresentable {
    typealias Callback = ([UIImage]) -> Void

    let maxCount: Int
    let onComplete: Callback

    // MARK: UIViewControllerRepresentable
    func makeUIViewController(context: Context) -> PHPickerViewController {
        var cfg = PHPickerConfiguration()
        cfg.filter = .images
        cfg.selectionLimit = maxCount
        let picker = PHPickerViewController(configuration: cfg)
        picker.delegate = context.coordinator
        return picker
    }

    func updateUIViewController(_: PHPickerViewController, context _: Context) {}

    func makeCoordinator() -> Coordinator { Coordinator(onComplete: onComplete) }

    // MARK: - Coordinator
    final class Coordinator: NSObject, PHPickerViewControllerDelegate {
        let onComplete: Callback
        init(onComplete: @escaping Callback) { self.onComplete = onComplete }

        func picker(_ picker: PHPickerViewController,
                    didFinishPicking results: [PHPickerResult]) {

            picker.dismiss(animated: true)
            guard !results.isEmpty else { onComplete([]); return }

            var images: [UIImage] = []
            let group = DispatchGroup()

            for res in results {
                if res.itemProvider.canLoadObject(ofClass: UIImage.self) {
                    group.enter()
                    res.itemProvider.loadObject(ofClass: UIImage.self) { object, _ in
                        defer { group.leave() }
                        if let img = object as? UIImage {
                            images.append(img)
                        }
                    }
                }
            }

            group.notify(queue: .main) {
                self.onComplete(images)
            }
        }
    }
}
