import SwiftUI
import Combine

@MainActor
final class ListingsViewModel: ObservableObject {
    @Published var listings: [SaleListing] = []
    @Published var isLoading = false
    @Published var error: String?

    private let service = ListingService()

    /// Загружает ленту по фильтру (или дефолтному).
    func load(filter: ListingFilter = .init(page: 1, pageSize: 30,
                                            minPrice: nil, maxPrice: nil,
                                            roomCounts: nil, regionId: nil,
                                            municipaliteId: nil, propertyTypeId: nil,
                                            settlementId: nil, districtId: nil,
                                            sortBy: "date", sortDesc: true)) async {
        isLoading = true; error = nil
        defer { isLoading = false }
        do {
            listings = try await service.fetchListing(filter: filter)

            // — подгружаем первое фото для карточек
            for idx in listings.indices {
                let photos = try await service.fetchListingPhotos(listingId: listings[idx].id)
                if let first = photos.first {
                    listings[idx].coverPhotoURL =
                        APIClient.shared.baseURL.appendingPathComponent(first.url)
                }
            }
        } catch {
            self.error = error.localizedDescription
        }
    }
}
