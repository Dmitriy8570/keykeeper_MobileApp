import SwiftUI

struct MainTabView: View {
    @State private var selectedTab = 0
    
    var body: some View {
        TabView(selection: $selectedTab) {
            ListingsListView().tabItem {
                Image(systemName: "house.fill")
                Text("Объявления")
            }.tag(0)
            
            FavoritesView().tabItem {
                Image(systemName: "heart.fill")
                Text("Избранное")
            }.tag(1)
            
            NewListingFormView().tabItem {
                Image(systemName: "plus.circle")
                Text("Новое")
            }.tag(2)
            
            ProfileView().tabItem {
                Image(systemName: "person.fill")
                Text("Профиль")
            }.tag(3)
//
//            MapView().tabItem {
//                Image(systemName: "map.fill")
//                Text("Карта")
//            }.tag(4)
        }
    }
}
