import Foundation

struct UserService {

    // PATCH /api/Users   { userId, saleListingId }
    func addFavorite(listingId: Int, userId: Int) async throws {
        let body = try JSONEncoder().encode(
            AddFavoriteRequest(userId: userId, saleListingId: listingId))

        _ = try await APIClient.shared.sendRequest(
            "api/Users",
            method: "PATCH",
            body: body,
            authorize: true,
            responseType: EmptyResponse.self
        )
    }

    // DELETE /api/Users/favorite/{listingId}
    func removeFavorite(listingId: Int) async throws {
        _ = try await APIClient.shared.sendRequest(
            "api/Users/favorite/\(listingId)",
            method: "DELETE",
            authorize: true,
            responseType: EmptyResponse.self
        )
    }

    // GET /api/Users/{id}
    func fetchUserProfile(id: Int) async throws -> User {
        try await APIClient.shared.sendRequest(
            "api/Users/\(id)",
            authorize: true
        )
    }
}
