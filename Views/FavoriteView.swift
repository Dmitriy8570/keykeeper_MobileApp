import SwiftUI

struct FavoritesView: View {
    @StateObject var viewModel = FavoritesViewModel()
    
    var body: some View {
        NavigationView {
            if APIClient.shared.authToken == nil {
                // Неавторизованный пользователь
                VStack {
                    Text("Войдите, чтобы просматривать избранные объявления.")
                        .padding()
                    HStack {
                        Button("Войти") {
                            // открыть экран логина
                        }
                        Button("Регистрация") {
                            // открыть экран регистрации
                        }
                    }
                }
            } else {
                VStack {
                    if viewModel.loading {
                        ProgressView("Загрузка избранного...")
                    }
                    if viewModel.favorites.isEmpty && !viewModel.loading {
                        Text("У вас пока нет избранных объявлений.")
                            .foregroundColor(.secondary)
                    } else {
                        List {
                            ForEach(viewModel.favorites) { listing in
                                ListingRowView(listing: listing)
                                    .swipeActions {  // удобный способ для SwiftUI
                                        Button(role: .destructive) {
                                            Task { await viewModel.removeFromFavorites(listing: listing) }
                                        } label: {
                                            Text("Удалить")
                                        }
                                    }
                                    .onTapGesture {
                                        // перейти к деталям объявления
                                    }
                            }
                        }
                    }
                }
                .navigationTitle("Избранное")
            }
        }
        .onAppear {
            if APIClient.shared.authToken != nil {
                Task { await viewModel.loadFavorites() }
            }
        }
    }
}
