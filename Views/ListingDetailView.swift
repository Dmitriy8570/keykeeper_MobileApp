import SwiftUI

struct ListingDetailView: View {
    @StateObject var viewModel: ListingDetailViewModel
    
    var body: some View {
        ScrollView {
            // Галерея фотографий - горизонтальный ScrollView
            if !viewModel.photos.isEmpty {
                ScrollView(.horizontal, showsIndicators: true) {
                    HStack {
                        ForEach(viewModel.photos) { photo in
                            if let url = URL(string: APIClient.shared.baseURL.absoluteString + photo.url) {
                                // загрузка изображения аналогично AsyncImage
                                AsyncImage(url: url) { phase in /* ... */ }
                                    .frame(width: 300, height: 200)
                                    .clipped().cornerRadius(10)
                            }
                        }
                    }.padding()
                }
            } else {
                Text("Нет фотографий").foregroundColor(.secondary)
            }
            
            VStack(alignment: .leading, spacing: 8) {
                Text("\(viewModel.listing.price) ₽")
                    .font(.largeTitle).bold()
                Text(viewModel.listing.description)
                    .font(.body)
                if let area = viewModel.listing.area {
                    Text("Площадь: \(area) кв.м.")
                }
                if let rooms = viewModel.listing.roomCount {
                    Text("Комнат: \(rooms)")
                }
                if let floor = viewModel.listing.floor {
                    let total = viewModel.listing.totalFloors ?? 0
                    Text("Этаж: \(floor)\(total > 0 ? " из \(total)" : "")")
                }
                if let address = viewModel.listing.addressText {
                    Text("Адрес: \(address)")
                }
                Divider()
                if let contact = viewModel.sellerContact {
                    // Показываем контакт только для авторизованных
                    Text("Контакты продавца:").font(.headline)
                    Text(contact).font(.subheadline)
                } else {
                    Text("Войдите, чтобы увидеть контакты продавца.")
                        .foregroundColor(.blue)
                        .onTapGesture {
                            // переход к экрану входа/регистрации
                        }
                }
            }
            .padding()
        }
        .navigationTitle("Объявление")
        .onAppear {
            Task { await viewModel.loadDetails() }
        }
    }
}
