import SwiftUI

@MainActor
final class ProfileViewModel: ObservableObject {
    @Published var user: User?
    @Published var myListings: [SaleListing] = []
    @Published var isLoading = false
    @Published var error: String?

    private let userSvc = UserService()
    private let listSvc = ListingService()

    func load() async {
        guard let userId = APIClient.shared.currentUserId() else { return }
        isLoading = true; error = nil
        defer { isLoading = false }
        do {
            user = try await userSvc.fetchUserProfile(id: userId)

            // Забираем все объявления (до 1000) и фильтруем по userId,
            // т.к. бекенд не даёт энд-пойнт /myListings
            let all = try await listSvc.fetchListing(
                filter: .init(page: 1, pageSize: 1000,
                              minPrice: nil, maxPrice: nil,
                              roomCounts: nil, regionId: nil,
                              municipaliteId: nil, propertyTypeId: nil,
                              settlementId: nil, districtId: nil,
                              sortBy: nil, sortDesc: false))
            myListings = all.filter { $0.userId == userId }

            for idx in myListings.indices {
                let ph = try await listSvc.fetchListingPhotos(listingId: myListings[idx].id)
                if let first = ph.first {
                    myListings[idx].coverPhotoURL =
                        APIClient.shared.baseURL.appendingPathComponent(first.url)
                }
            }
        } catch {
            self.error = error.localizedDescription
        }
    }

    func deleteListing(_ listing: SaleListing) async {
        do {
            try await ListingService().deleteListing(listingId: listing.id)
            myListings.removeAll { $0.id == listing.id }
        } catch {
            self.error = error.localizedDescription
        }
    }

    func logout() {
        AuthService().logout()
        user = nil
        myListings = []
    }
}
