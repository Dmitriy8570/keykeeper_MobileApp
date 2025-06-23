import SwiftUI

@MainActor
final class NewListingViewModel: ObservableObject {

    // --- данные формы ---
    @Published var propertyTypes: [PropertyType] = []
    @Published var selectedTypeIndex: Int = 0

    @Published var region: String = ""
    @Published var municipalite: String = ""
    @Published var settlement: String = ""
    @Published var district: String = ""
    @Published var street: String = ""
    @Published var houseNumber: String = ""

    @Published var price: String = ""
    @Published var description: String = ""
    @Published var area: String = ""
    @Published var roomCount: String = ""
    @Published var floor: String = ""
    @Published var totalFloors: String = ""

    @Published var latitude: Double?
    @Published var longitude: Double?


// --- UI-состояние ---
    @Published var isPosting = false
    @Published var error: String?
    @Published var newListingId: Int?   // если не nil — можно пушить UploadPhotosView

    private let listSvc = ListingService()
    private let geoSvc  = GeoService()

    // MARK: - Загрузка справочников
    func loadDictionaries() async {
        do {
            propertyTypes = try await geoSvc.propertyTypes()
        } catch {
            self.error = error.localizedDescription        // ← добавили self.
        }
    }

    // MARK: - Публикация
    func publish() async {
        guard let userId = APIClient.shared.currentUserId() else {
            error = "Требуется авторизация."
            return
        }
        guard let priceInt = Int(price) else {
            error = "Цена некорректна"
            return
        }
        guard !description.isEmpty else {
            error = "Описание обязательно"
            return
        }

        let dto = NewListingData(
            userId: userId,
            propertyTypeId: (selectedTypeIndex < propertyTypes.count
                             ? propertyTypes[selectedTypeIndex].propertyTypeId
                             : 1),
            settlementName: settlement,
            municipaliteName: municipalite,
            regionName: region,
            streetName: street.isEmpty ? nil : street,
            districtName: district.isEmpty ? nil : district,
            houseNumber: houseNumber.isEmpty ? nil : houseNumber,
            latitude: latitude ?? 0,
            longitude: longitude ?? 0,
            price: priceInt,
            description: description,
            floor: Int(floor),
            area: Double(area),
            roomCount: Int(roomCount),
            totalFloors: Int(totalFloors)
        )

        isPosting = true
        defer { isPosting = false }

        do {
            let id = try await listSvc.createListing(dto)
            newListingId = id                         // ← для перехода к загрузке фото
        } catch {
            self.error = error.localizedDescription
        }
    }
}
