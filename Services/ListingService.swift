import Foundation
import Alamofire

struct ListingService{
    func fetchListing(filter: ListingFilter? = nil) async throws -> [SaleListing]{
        var endpoint = "api/SaleListing"
        if let filter = filter{
            endpoint += "?" + filter.queryParameters()
        }
        let pagedResponse: PagedResponse<SaleListing> = try await APIClient.shared.sendRequest(endpoint)
        return pagedResponse.items
    }
    
    func fetchListingPhotos(listingId: Int) async throws -> [Photo] {
        let endpoint = "api/SaleListing/\(listingId)/photos"
        let photos: [Photo] = try await APIClient.shared.sendRequest(endpoint)
        return photos
    }
    
    func createListing(newListing: NewListingData) async throws -> Int{
        let body = try JSONEncoder().encode(newListing)
        
        let saleListingId: Int = try await APIClient.shared.sendRequest("api/SaleListing", method: "POST", body: body, authorize: true)
        
        return saleListingId
    }
    
    func deleteListing(listingId: Int) async throws{
        _ = try await APIClient.shared.sendRequest("api/SaleListing/\(listingId)", method: "DELTE", authorize: true)
    }
    
    func uploadPhoto(listingId: Int, imageData: Data) async throws{
        let url = APIClient.shared.baseURL.appendingPathComponent("api/SaleListing/\(listingId)/photos")
        let headers: HTTPHeaders = [
            "Authorization": "Bearer \(APIClient.shared.authToken ?? "")"
        ]
        try await AF.upload(
            multipartFormData: { formData in
                formData.append(imageData,
                                withName: "file",
                                fileName: "photo.jpg",
                                mimeType: "image/jpeg")
            },
            to: url,
            method: .post,
            headers: headers
        )
            .validate(statusCode: 200..<300)
            .serializingData()
            .value
    }
}
