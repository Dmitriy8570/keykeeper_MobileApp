import SwiftUI

struct ListingRowView: View {
    let listing: SaleListing

    var body: some View {
        HStack(spacing: 12) {
            // миниатюра
            if let url = listing.coverPhotoURL {
                AsyncImage(url: url) { phase in
                    switch phase {
                    case .success(let img): img.resizable().scaledToFill()
                    case .failure:          Color.red.opacity(0.2)
                    default:                Color.gray.opacity(0.2)
                    }
                }
                .frame(width: 90, height: 90)
                .clipped()
                .cornerRadius(6)
            } else {
                Color.gray.opacity(0.2)
                    .frame(width: 90, height: 90)
                    .cornerRadius(6)
                    .overlay(Image(systemName: "photo"))
            }

            // текст
            VStack(alignment: .leading, spacing: 4) {
                Text("\(listing.price) ₽")
                    .font(.headline)
                if let addr = listing.addressText {
                    Text(addr)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                if let type = listing.propertyTypeName {
                    Text(type)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            Spacer()
        }
        .padding(.vertical, 4)
    }
}
