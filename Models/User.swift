import Foundation

struct User: Codable, Identifiable{
    let id: Int
    let firstName: String
    let lastName: String
    let email: String
    let phoneNumber: String?
    let registrationDate: String
    let lastLoginDate: String
    
    let favoriteListings: [SaleListing]?
}
