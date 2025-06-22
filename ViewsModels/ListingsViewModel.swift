import SwiftUI
import Combine

@MainActor
final class ListingsViewModel: ObservableObject {
    // MARK: - Published свойства для UI
    @Published var listings: [SaleListing] = []
    @Published var isLoading = false
    @Published var errorMessage: String?

    private let listingService = ListingService()

    // MARK: - Загрузка объявлений
    func loadListings() async {
        isLoading = true
        defer { isLoading = false }
        do {
            // пока просто берём первую страницу без фильтров
            listings = try await listingService.fetchListing()
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
