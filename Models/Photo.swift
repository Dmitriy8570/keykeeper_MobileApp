import Foundation

struct Photo: Codable, Identifiable {
    let listingPhotoId: Int
    let listingId: Int
    let url: String
    
    var id: Int { listingPhotoId }
}
