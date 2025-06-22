import Foundation

struct SaleListing: Codable, Identifiable{
    let id: Int
    let userId: Int
    let propertyTypeId: Int
    let addressId: Int
    let price: Int
    let description: String
    let listingDate: String
    let isActive: Bool
    let floor: Int?
    let area: Double?
    let roomCount: Int?
    let totalFloors: Int?
    
    var addressText: String?
    var coverPhotoURL: URL?
}
