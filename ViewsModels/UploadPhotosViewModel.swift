import SwiftUI

@MainActor
final class UploadPhotosViewModel: ObservableObject {
    @Published var selected: [UIImage] = []
    @Published var isUploading = false
    @Published var error: String?
    @Published var done = false

    let listingId: Int
    private let service = ListingService()

    init(listingId: Int) { self.listingId = listingId }

    func upload() async {
        guard !selected.isEmpty else {
            error = "Выберите хотя бы одно фото."
            return
        }
        isUploading = true; error = nil
        defer { isUploading = false }
        do {
            try await service.uploadPhotos(listingId: listingId, images: selected)
            done = true
        } catch {
            self.error = error.localizedDescription
        }
    }
}
