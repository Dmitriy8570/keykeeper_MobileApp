import SwiftUI

@MainActor
final class ListingDetailViewModel: ObservableObject {
    @Published private(set) var listing: SaleListing
    @Published var photos: [Photo] = []
    @Published var sellerContact: String?
    @Published var isFavorite = false
    @Published var error: String?

    private let listingSvc = ListingService()
    private let userSvc    = UserService()

    init(listing: SaleListing) { self.listing = listing }

    func load() async {
        error = nil
        do {
            // Фото
            photos = try await listingSvc.fetchListingPhotos(listingId: listing.id)

            // Контакты продавца (только если авторизованы)
            if let userId = APIClient.shared.currentUserId() {
                let seller = try await userSvc.fetchUserProfile(id: listing.userId)
                if let phone = seller.phoneNumber, !phone.isEmpty {
                    sellerContact = "Телефон: \(phone)"
                } else {
                    sellerContact = "Email: \(seller.email)"
                }
                // Проверяем, уже ли это избранное
                let me = try await userSvc.fetchUserProfile(id: userId)
                isFavorite = me.favoriteListings?.contains(where: { $0.id == listing.id }) ?? false
            }
        } catch {
            self.error = error.localizedDescription
        }
    }

    func toggleFavorite() async {
        guard let userId = APIClient.shared.currentUserId() else {
            error = "Необходимо войти."
            return
        }
        do {
            if isFavorite {
                try await userSvc.removeFavorite(listingId: listing.id)
            } else {
                try await userSvc.addFavorite(listingId: listing.id, userId: userId)
            }
            isFavorite.toggle()
        } catch {
            self.error = error.localizedDescription
        }
    }
}
