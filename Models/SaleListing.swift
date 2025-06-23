import Foundation
import CoreLocation

struct SaleListing: Identifiable, Decodable {
    // ------------ базовые поля ------------
    let id: Int
    let userId: Int
    let price: Int
    let description: String
    let listingDate: String     // ISO-строка
    let isActive: Bool
    let floor: Int?
    let area: Double?
    let roomCount: Int?
    let totalFloors: Int?
    
    // ------------ тип недвижимости ------------
    let propertyTypeId: Int?
    let propertyTypeName: String?
    
    // ------------ заполняются в рантайме ------------
    var addressText: String?
    var coverPhotoURL: URL?
    
    // ------------ кастомное декодирование ------------
    private enum CodingKeys: String, CodingKey {
        case id = "saleListingId"
        case userId, price, description, listingDate, isActive,
             floor, area, roomCount, totalFloors,
             propertyTypeId, propertyTypeName, address
    }
    
    init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        id              = try c.decode(Int.self,    forKey: .id)
        userId          = try c.decode(Int.self,    forKey: .userId)
        price           = try c.decode(Int.self,    forKey: .price)
        description     = try c.decode(String.self, forKey: .description)
        listingDate     = try c.decode(String.self, forKey: .listingDate)
        isActive        = try c.decode(Bool.self,   forKey: .isActive)
        floor           = try c.decodeIfPresent(Int.self,    forKey: .floor)
        area            = try c.decodeIfPresent(Double.self, forKey: .area)
        roomCount       = try c.decodeIfPresent(Int.self,    forKey: .roomCount)
        totalFloors     = try c.decodeIfPresent(Int.self,    forKey: .totalFloors)
        propertyTypeId  = try c.decodeIfPresent(Int.self,    forKey: .propertyTypeId)
        propertyTypeName = try c.decodeIfPresent(String.self, forKey: .propertyTypeName)
        
        // -------- адрес (вложенный объект) --------
        if let addr = try? c.nestedContainer(keyedBy: StringCodingKey.self, forKey: .address) {
            let settlement = try addr.decodeIfPresent(String.self, forKey: "SettlementName") ?? ""
            let region     = try addr.decodeIfPresent(String.self, forKey: "RegionName") ?? ""
            let district   = try addr.decodeIfPresent(String.self, forKey: "DistrictName") ?? ""
            let street     = try addr.decodeIfPresent(String.self, forKey: "StreetName") ?? ""
            let house      = try addr.decodeIfPresent(String.self, forKey: "HouseNumber") ?? ""
            
            // собираем читабельную строку адреса
            switch true {
            case !street.isEmpty:
                addressText = street + (house.isEmpty ? "" : " \(house)")
            case !district.isEmpty:
                addressText = district
            case !settlement.isEmpty:
                addressText = settlement
            default:
                addressText = nil
            }
            if !region.isEmpty, var text = addressText { text += ", \(region)"; addressText = text }
        } else {
            addressText = nil
        }
        
        coverPhotoURL = nil          // позже дописывается после запроса фото
    }
}

extension SaleListing: Hashable {
    static func == (lhs: SaleListing, rhs: SaleListing) -> Bool { lhs.id == rhs.id }
    func hash(into hasher: inout Hasher) { hasher.combine(id) }
}

struct ListingsPage: Decodable {
    let items:      [SaleListing]
    let totalCount: Int
    let page:       Int
    let pageSize:   Int
}
