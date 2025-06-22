import SwiftUI

@MainActor
class ListingDetailViewModel: ObservableObject {
    @Published var listing: SaleListing
    @Published var photos: [Photo] = []
    @Published var sellerContact: String? = nil 
    
    private let listingService = ListingService()
    private let userService = UserService()
    
    init(listing: SaleListing) {
        self.listing = listing
    }
    
    func loadDetails() async {
        do {
            // Загрузить все фотографии объявления
            self.photos = try await listingService.fetchListingPhotos(listingId: listing.id)
            // Если пользователь авторизован, получить контакт продавца
            if let token = APIClient.shared.authToken {
                let user = try await userService.fetchUserProfile(userId: listing.userId)
                // Контактные данные – можно показать телефон или email
                if let phone = user.phoneNumber, !phone.isEmpty {
                    Text("Телефон: \(phone)")
                } else {
                    Text("Email: \(user.email)")
                }
            }
        } catch {
            print("Ошибка при загрузке деталей: \(error)")
        }
    }
}
