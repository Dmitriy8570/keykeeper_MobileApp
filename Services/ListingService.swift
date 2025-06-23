import Foundation
import UIKit

struct ListingService {
    
    // GET /api/SaleListing?page=1&pageSize=30&minPrice=…
    func fetchListing(filter: ListingFilter) async throws -> [SaleListing] {

        // --- query-параметры --------------------------------------------------
        var q: [URLQueryItem] = [
            .init(name: "page",     value: "\(filter.page)"),
            .init(name: "pageSize", value: "\(filter.pageSize)")
        ]
        func add(_ k: String, _ v: CustomStringConvertible?) {
            if let v = v { q.append(.init(name: k, value: "\(v)")) }
        }
        add("minPrice",       filter.minPrice)
        add("maxPrice",       filter.maxPrice)
        if let rooms = filter.roomCounts {
            rooms.forEach { add("roomCounts", $0) }          // ?roomCounts=1&roomCounts=2…
        }
        add("regionId",       filter.regionId)
        add("municipaliteId", filter.municipaliteId)
        add("propertyTypeId", filter.propertyTypeId)
        add("settlementId",   filter.settlementId)
        add("districtId",     filter.districtId)
        add("sortBy",         filter.sortBy)
        add("sortDesc",       filter.sortDesc)

        // --- запрос ----------------------------------------------------------
        let page: ListingsPage = try await APIClient.shared.sendRequest(
            "api/SaleListing",
            method: "GET",
            query: q
        )

        // --- наружу отдаём только массив -------------------------------------
        return page.items
    }
    
    // GET /api/SaleListing/{id}/photos
    func fetchListingPhotos(listingId: Int) async throws -> [Photo] {
        try await APIClient.shared.sendRequest(
            "api/SaleListing/\(listingId)/photos"
        )
    }
    
    // POST /api/SaleListing
    func createListing(_ dto: NewListingData) async throws -> Int {
        let body = try JSONEncoder().encode(dto)
        let resp: CreateListingResponse = try await APIClient.shared.sendRequest(
            "api/SaleListing",
            method: "POST",
            body: body,
            authorize: true
        )
        return resp.saleListingId
    }
    
    // DELETE /api/SaleListing/{id}
    func deleteListing(listingId: Int) async throws {
        _ = try await APIClient.shared.sendRequest(
            "api/SaleListing/\(listingId)",
            method: "DELETE",
            authorize: true,
            responseType: EmptyResponse.self
        )
    }
    
    func uploadPhotos(listingId: Int,
                          images: [UIImage]) async throws {

            guard let token = APIClient.shared.authToken else {
                throw APIError.unauthorized
            }

            // --- формируем multipart
            let boundary = "Boundary-\(UUID().uuidString)"
            var body = Data()

            for (idx, img) in images.enumerated() {
                guard let jpeg = img.jpegData(compressionQuality: 0.85) else { continue }

                body.append("--\(boundary)\r\n")
                body.append("Content-Disposition: form-data; "
                            + "name=\"files\"; filename=\"photo\(idx).jpg\"\r\n")
                body.append("Content-Type: image/jpeg\r\n\r\n")
                body.append(jpeg)
                body.append("\r\n")
            }
            body.append("--\(boundary)--\r\n")

            // --- собираем запрос
            var request = URLRequest(
                url: APIClient.shared.baseURL
                    .appendingPathComponent("api/SaleListing/\(listingId)/photos"))
            request.httpMethod = "POST"
            request.setValue("multipart/form-data; boundary=\(boundary)",
                             forHTTPHeaderField: "Content-Type")
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
            request.httpBody = body

            // --- выполняем
            let (_, resp) = try await URLSession.shared.data(for: request)
            guard let http = resp as? HTTPURLResponse,
                  (200...299).contains(http.statusCode) else {
                throw APIError.invalidResponse
            }
        }
}

fileprivate extension Data {
    mutating func append(_ string: String) {
        if let d = string.data(using: .utf8) { append(d) }
    }
}
