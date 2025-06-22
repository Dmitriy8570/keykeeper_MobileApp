struct ListingFilter: Codable{
    let page: Int
    let pageSize: Int
    
    let minPrice: Int?
    let maxPrice: Int?
    let roomCounts: [Int]?
    let regionId: Int?
    let mumicipaliteId: Int?
    let propertyTypeId: Int?
    let settlementId: Int?
    let districtId: Int?
    
    let sortBy: String?
    let sortDesc: Bool
    
    func queryParameters() -> String {
        var components = [String]()
        
       
        components.append("page=\(page)")
        components.append("pageSize=\(pageSize)")
        
        if let minPrice = minPrice { components.append("MinPrice=\(minPrice)") }
        if let maxPrice = maxPrice { components.append("MaxPrice=\(maxPrice)") }
        if let regionId = regionId { components.append("RegionId=\(regionId)") }
        if let mumicipaliteId = mumicipaliteId { components.append("MumicipaliteId=\(mumicipaliteId)") }
        if let propertyTypeId = propertyTypeId { components.append("PropertyTypeId=\(propertyTypeId)") }
        if let settlementId = settlementId { components.append("SettlementId=\(settlementId)") }
        if let districtId = districtId { components.append("DistrictId=\(districtId)") }
        if let sortBy = sortBy { components.append("SortBy=\(sortBy)") }
        
        
        if let roomCounts = roomCounts, !roomCounts.isEmpty {
            for count in roomCounts {
                components.append("RoomCounts=\(count)")
            }
        }
        
        
        components.append("SortDesc=\(sortDesc)")
        
        return components.joined(separator: "&")
    }
}

struct PagedResponse<T: Decodable>: Decodable {
    let items: [T]
    let totalCount: Int
    let page: Int
    let pageSize: Int
}

struct NewListingData: Codable{
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

struct AddFavoriteListRequest: Codable{
    let userId: Int
    let saleListingId: Int
}
