import SwiftUI

struct ListingsListView: View {
    @StateObject var viewModel = ListingsViewModel()
    
    var body: some View {
        NavigationView {
            VStack {
                // Кнопки фильтров и сортировки
                HStack {
                    Button("Фильтры") {
                        // открыть экран фильтрации
                    }
                    Spacer()
                    Button("Сортировка") {
                        // открыть варианты сортировки
                    }
                }
                .padding()
                
                // Список объявлений
                List(viewModel.listings) { listing in
                    ListingRowView(listing: listing)
                        .onTapGesture {
                            // переход к детальному экрану объявления
                        }
                }
                .listStyle(PlainListStyle())
                
                // Показатель загрузки или сообщения об ошибке
                if viewModel.isLoading {
                    ProgressView().padding()
                }
                if let error = viewModel.errorMessage {
                    Text(error).foregroundColor(.red)
                }
            }
            .navigationBarHidden(true)
        }
        .onAppear {
            // Загружаем объявления при первом появлении
            Task { await viewModel.loadListings() }
        }
    }
}

struct ListingRowView: View {
    let listing: SaleListing
    
    var body: some View {
        HStack(alignment: .top) {
            // Фото объявления (миниатюра)
            if let url = listing.coverPhotoURL {
                AsyncImage(url: url) { phase in
                    if let image = phase.image {
                        image.resizable().scaledToFill()
                    } else if phase.error != nil {
                        Color.red // или изображение-заглушка "нет фото"
                    } else {
                        Color.gray // плейсхолдер пока грузится
                    }
                }
                .frame(width: 100, height: 100)
                .clipped()
                .cornerRadius(8)
            }
            // Информация об объявлении
            VStack(alignment: .leading) {
                Text("\(listing.price) ₽")
                    .font(.headline)
                Text(listing.description)
                    .lineLimit(2)
                    .font(.subheadline)
                if let address = listing.addressText {
                    Text(address)
                        .font(.footnote)
                        .foregroundColor(.secondary)
                }
            }
        }
        .padding(.vertical, 8)
    }
}
