import SwiftUI

struct FavoritesView: View {
    @StateObject private var vm = FavoritesViewModel()
    @State private var showingLogin = false

    var body: some View {
        NavigationStack {
            Group {
                if APIClient.shared.authToken == nil {
                    VStack(spacing: 16) {
                        Text("Войдите, чтобы видеть избранное.")
                        Button("Войти") { showingLogin = true }
                            .buttonStyle(.borderedProminent)
                    }
                } else if vm.isLoading {
                    ProgressView("Загрузка…")
                } else if let err = vm.error {
                    Text(err).foregroundColor(.red).padding()
                } else if vm.favorites.isEmpty {
                    Text("Избранных объявлений нет.").foregroundColor(.secondary)
                } else {
                    List {
                        ForEach(vm.favorites) { fav in
                            NavigationLink(value: fav) {
                                ListingRowView(listing: fav)
                            }
                            .swipeActions {
                                Button(role: .destructive) {
                                    Task { await vm.remove(fav) }
                                } label: { Label("Удалить", systemImage: "trash") }
                            }
                        }
                    }
                    .listStyle(.plain)
                }
            }
            .navigationTitle("Избранное")
            .navigationDestination(for: SaleListing.self) { ListingDetailView(listing: $0) }
            .task {
                if APIClient.shared.authToken != nil { await vm.load() }
            }
            .refreshable {
                if APIClient.shared.authToken != nil { await vm.load() }
            }
            .sheet(isPresented: $showingLogin) { LoginView() }
        }
    }
}
