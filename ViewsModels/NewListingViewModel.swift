import SwiftUI

@MainActor
class NewListingViewModel: ObservableObject {
    // Поля формы
    @Published var propertyTypeIndex: Int = 0
    @Published var region: String = ""
    @Published var municipalite: String = ""
    @Published var settlement: String = ""
    @Published var street: String = ""
    @Published var district: String = ""
    @Published var houseNumber: String = ""
    @Published var latitude: Double? = nil
    @Published var longitude: Double? = nil
    @Published var price: String = ""          // будем конвертировать в Int
    @Published var description: String = ""
    @Published var floor: String = ""
    @Published var totalFloors: String = ""
    @Published var roomCount: String = ""
    @Published var area: String = ""
    
    @Published var isPosting = false
    @Published var postSuccess = false
    @Published var errorMessage: String? = nil
    
    private let listingService = ListingService()
    
    // Справочные данные
    let propertyTypes = ["Квартира", "Дом", "Комната"]  // пример, ID по индексу+1
    
    func publishListing() async {
        guard let lat = latitude, let lon = longitude else {
            errorMessage = "Укажите местоположение на карте."
            return
        }
        guard let priceInt = Int(price) else {
            errorMessage = "Некорректно указана цена."
            return
        }
        isPosting = true
        defer { isPosting = false }
        do {
            // Собираем данные в структуру запроса
            let userId = /* текущий userId из токена */ 0
            let newListing = NewListingData(
                userId: userId,
                propertyTypeId: propertyTypeIndex + 1,
                settlementName: settlement,
                municipaliteName: municipalite,
                regionName: region,
                streetName: street,
                districtName: district,
                houseNumber: houseNumber,
                latitude: lat,
                longitude: lon,
                price: priceInt,
                description: description,
                floor: Int(floor),
                area: Double(area),
                roomCount: Int(roomCount),
                totalFloors: Int(totalFloors)
            )
            let listingId = try await listingService.createListing(newListing: newListing)
            postSuccess = true
            // Можно уведомить пользователя об успехе или сразу предложить добавить фото.
        } catch {
            errorMessage = "Ошибка при публикации: \(error)"
        }
    }
}
