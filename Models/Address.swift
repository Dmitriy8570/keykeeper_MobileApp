import Foundation

struct Address: Codable {
    let settlementName: String?
    let regionName: String?
    let municipaliteName: String?
    let districtName: String?
    let streetName: String?
    let houseNumber: String?
    let latitude: Double?
    let longitude: Double?
}

// MARK: - Тип недвижимости
struct PropertyType: Codable, Identifiable {
    let propertyTypeId: Int
    let name: String
    
    var id: Int { propertyTypeId }
}

// MARK: - География
struct Region: Codable, Identifiable {
    let regionId: Int
    let name: String
    
    var id: Int { regionId }
}

struct Municipalite: Codable, Identifiable {
    let municipaliteId: Int
    let name: String
    let regionId: Int
    
    var id: Int { municipaliteId }
}

struct Settlement: Codable, Identifiable {
    let settlementId: Int
    let name: String
    let municipaliteId: Int
    
    var id: Int { settlementId }
}

struct District: Codable, Identifiable {
    let districtId: Int
    let name: String
    let settlementId: Int
    
    var id: Int { districtId }
}
