import Foundation

struct UserService {
    func fetchUserProfile(userId: Int) async throws -> User{
        let endpoint = "api/Users/\(userId)"
        let user: User = try await APIClient.shared.sendRequest(endpoint, authorize: true)
        return user
    }
    
    func addFavorite(listingId: Int, for userId: Int) async throws {
        let request = AddFavoriteListRequest(userId: userId, saleListingId: listingId)
        let body = try JSONEncoder().encode(request)
        try await APIClient.shared.sendRequest("api/Users", method: "PATCH", body: body, authorize: true)
    }
    
    func removeFavorite(listingId: Int, for userId: Int) async throws{
        _ = try await APIClient.shared.sendRequest("api/Users/favorite/\(listingId)", method: "Delete", authorize: true)
    }
    
    func deleteAccount(userId: Int) async throws {
        _ = try await APIClient.shared.sendRequest("api/users/\(userId)", method: "DELETE", authorize: true)
    }
}
