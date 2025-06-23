import SwiftUI

struct ListingDetailView: View {
    @StateObject private var vm: ListingDetailViewModel
    @Environment(\.dismiss) private var dismiss
    @State private var showingLogin = false

    init(listing: SaleListing) {
        _vm = StateObject(wrappedValue: ListingDetailViewModel(listing: listing))
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading) {
                photosPager

                Text("\(vm.listing.price) ₽")
                    .font(.largeTitle).bold().padding(.top)

                if let addr = vm.listing.addressText {
                    Text(addr).font(.title3)
                }

                Divider().padding(.vertical, 4)

                Text(vm.listing.description)
                    .font(.body)

                if let contact = vm.sellerContact {
                    Divider().padding(.vertical, 8)
                    Text(contact).font(.headline)
                }

                if let err = vm.error {
                    Text(err).foregroundColor(.red).padding(.top, 6)
                }
            }
            .padding()
        }
        .navigationTitle("Объявление")
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    Task {
                        if APIClient.shared.authToken == nil {
                            showingLogin = true
                        } else {
                            await vm.toggleFavorite()
                        }
                    }
                } label: {
                    Image(systemName: vm.isFavorite ? "heart.fill" : "heart")
                }
            }
        }
        .sheet(isPresented: $showingLogin) { LoginView() }
        .task { await vm.load() }
    }

    // MARK: - Фото-карусель
    private var photosPager: some View {
        Group {
            if vm.photos.isEmpty {
                Color.gray.opacity(0.3)
                    .frame(height: 260)
                    .overlay(Image(systemName: "photo").font(.largeTitle))
            } else {
                TabView {
                    ForEach(vm.photos) { photo in
                        AsyncImage(
                            url: APIClient.shared.baseURL.appendingPathComponent(photo.url)) { phase in
                                switch phase {
                                case .success(let img):
                                    img.resizable().scaledToFill()
                                case .failure:
                                    Color.red.opacity(0.2)
                                default:
                                    Color.gray.opacity(0.2)
                                }
                            }
                    }
                }
                .frame(height: 260)
                .tabViewStyle(.page)
            }
        }
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}
