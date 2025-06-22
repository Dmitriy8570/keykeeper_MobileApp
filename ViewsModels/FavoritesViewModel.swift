import SwiftUI

@MainActor
class FavoritesViewModel: ObservableObject {
    @Published var favorites: [SaleListing] = []
    @Published var loading = false
    
    private let userService = UserService()
    
    func loadFavorites() async {
        guard let token = APIClient.shared.authToken,
              let userId = decodeUserIdFromToken(token: token) else {
            return
        }
        loading = true
        defer { loading = false }
        do {
            // Получаем профиль текущего пользователя
            let user = try await userService.fetchUserProfile(userId: userId)
            favorites = user.favoriteListings ?? []
            
            // Загрузить для каждого избранного объявления первую фотографию (как в ListingsViewModel)
            // и при необходимости адрес.
            for i in 0..<favorites.count {
                let listingId = favorites[i].id
                let photos = try await ListingService().fetchListingPhotos(listingId: listingId)
                if let first = photos.first {
                    favorites[i].coverPhotoURL = APIClient.shared.baseURL.appendingPathComponent(first.url)
                }
            }
        } catch {
            print("Ошибка загрузки избранного: \(error)")
        }
    }
    
    func removeFromFavorites(listing: SaleListing) async {
        guard let token = APIClient.shared.authToken,
              let userId = decodeUserIdFromToken(token: token) else { return }
        do {
            try await userService.removeFavorite(listingId: listing.id, for: userId)
            // Обновляем локально список
            favorites.removeAll { $0.id == listing.id }
        } catch {
            print("Ошибка удаления из избранного: \(error)")
        }
    }
    
    private func decodeUserIdFromToken(token: String) -> Int? {
        // JWT токен содержит UserId в поле sub (JwtRegisteredClaimNames.Sub).
        // Можно декодировать JWT (например, разделить по '.', декодировать payload Base64 и прочитать JSON).
        // Для упрощения, предположим, что мы сохранили текущий userId где-то при логине.
        return nil
    }
}
