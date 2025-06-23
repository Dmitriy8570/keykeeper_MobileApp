import SwiftUI

struct ContentView: View {
    var body: some View {
        TabView {
            ListingsListView()
                .tabItem { Label("Лента", systemImage: "house") }

            FavoritesView()
                .tabItem { Label("Избранное", systemImage: "heart") }

            NewListingFormView()
                .tabItem { Label("Новое", systemImage: "plus.circle") }

            ProfileView()
                .tabItem { Label("Профиль", systemImage: "person") }
        }
    }
}
