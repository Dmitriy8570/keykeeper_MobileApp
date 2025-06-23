struct NewListingData: Encodable {
    let userId: Int
    let propertyTypeId: Int
    let settlementName: String
    let municipaliteName: String
    let regionName: String
    let streetName: String?
    let districtName: String?
    let houseNumber: String?
    let latitude: Double
    let longitude: Double
    let price: Int
    let description: String
    let floor: Int?
    let area: Double?
    let roomCount: Int?
    let totalFloors: Int?
}

// MARK: - Ответ при создании объявления
struct CreateListingResponse: Decodable {
    let saleListingId: Int
}

struct ListingFilter: Codable {
    var page: Int
    var pageSize: Int
    var minPrice: Int?
    var maxPrice: Int?
    var roomCounts: [Int]?
    var regionId: Int?
    var municipaliteId: Int?
    var propertyTypeId: Int?
    var settlementId: Int?
    var districtId: Int?
    var sortBy: String?
    var sortDesc: Bool?
}
