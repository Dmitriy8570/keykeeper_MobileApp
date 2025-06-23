import Foundation

struct User: Decodable, Identifiable {
    let id: Int
    let firstName: String
    let lastName: String
    let email: String
    let phoneNumber: String?
    let favoriteListings: [SaleListing]?
}

struct AddFavoriteRequest: Encodable {
    let userId: Int
    let saleListingId: Int
}


// UserService.swift...
