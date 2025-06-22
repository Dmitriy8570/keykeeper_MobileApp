import SwiftUI

@MainActor
class ProfileViewModel: ObservableObject {
    @Published var user: User? = nil
    @Published var myListings: [SaleListing] = []
    @Published var loading = false
    
    private let userService = UserService()
    private let listingService = ListingService()
    
    func loadProfile() async {
        guard let token = APIClient.shared.authToken,
              let userId = APIClient.shared.currentUserId() else {
            return
        }
        loading = true
        defer { loading = false }
        do {
            let profile = try await userService.fetchUserProfile(userId: userId)
            self.user = profile
            let userListings = try await listingService.fetchListing(filter: ListingFilter(from: userId as! Decoder))
            self.myListings = userListings
            // Подгрузить фото для своих объявлений (как в других местах)
            for i in 0..<myListings.count {
                let photos = try await listingService.fetchListingPhotos(listingId: myListings[i].id)
                if let first = photos.first {
                    myListings[i].coverPhotoURL = APIClient.shared.baseURL.appendingPathComponent(first.url)
                }
            }
        } catch {
            print("Не удалось загрузить профиль: \(error)")
        }
    }
    
    func logout() {
        APIClient.shared.authToken = nil
        user = nil
        myListings = []
    }
}
