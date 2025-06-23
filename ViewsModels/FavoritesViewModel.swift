import SwiftUI

@MainActor
final class FavoritesViewModel: ObservableObject {
    @Published var favorites: [SaleListing] = []
    @Published var isLoading = false
    @Published var error: String?

    private let userSvc = UserService()
    private let listSvc = ListingService()


func load() async {
        guard let userId = APIClient.shared.currentUserId() else { return }
        isLoading = true; error = nil
        defer { isLoading = false }
        do {
            let me = try await userSvc.fetchUserProfile(id: userId)
            favorites = me.favoriteListings ?? []

            for idx in favorites.indices {
                let photos = try await listSvc.fetchListingPhotos(listingId: favorites[idx].id)
                if let first = photos.first {
                    favorites[idx].coverPhotoURL =
                        APIClient.shared.baseURL.appendingPathComponent(first.url)
                }
            }
        } catch {
            self.error = error.localizedDescription
        }
    }

    func remove(_ listing: SaleListing) async {
        guard let userId = APIClient.shared.currentUserId() else { return }
        do {
            try await userSvc.removeFavorite(listingId: listing.id)
            favorites.removeAll { $0.id == listing.id }
        } catch {
            self.error = error.localizedDescription
        }
    }
}
