import SwiftUI

struct ListingsListView: View {
    @StateObject private var vm = ListingsViewModel()

    var body: some View {
        NavigationStack {
            Group {
                if vm.isLoading {
                    ProgressView("Загрузка…")
                } else if let err = vm.error {
                    Text(err).foregroundColor(.red).padding()
                } else {
                    List(vm.listings) { listing in
                        NavigationLink(value: listing) {
                            ListingRowView(listing: listing)
                        }
                    }
                    .listStyle(.plain)
                }
            }
            .navigationTitle("Объявления")
            .navigationDestination(for: SaleListing.self) { listing in
                ListingDetailView(listing: listing)
            }
            .task { await vm.load() }
            .refreshable { await vm.load() }
        }
    }
}
