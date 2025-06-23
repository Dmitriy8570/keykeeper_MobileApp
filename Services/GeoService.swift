import Foundation

struct GeoService {
    
    func propertyTypes() async throws -> [PropertyType] {
        try await APIClient.shared.sendRequest("api/PropertyType")
    }
    func regions() async throws -> [Region] {
        try await APIClient.shared.sendRequest("api/Region")
    }
    func municipalites(regionId: Int) async throws -> [Municipalite] {
        try await APIClient.shared.sendRequest("api/Municipalite/byRegion/\(regionId)")
    }
    func settlements(municipaliteId: Int) async throws -> [Settlement] {
        try await APIClient.shared.sendRequest("api/Settlement/byMunicipalite/\(municipaliteId)")
    }
    func districts(settlementId: Int) async throws -> [District] {
        try await APIClient.shared.sendRequest("api/District/bySettlement/\(settlementId)")
    }
}
