import SwiftUI

struct ProfileView: View {
    @StateObject private var vm = ProfileViewModel()
    @State private var showingLogin = false
    @State private var confirmLogout = false

    var body: some View {
        NavigationStack {
            Group {
                if APIClient.shared.authToken == nil {
                    VStack(spacing: 16) {
                        Text("Профиль недоступен.\nВойдите или зарегистрируйтесь.")
                            .multilineTextAlignment(.center)
                        HStack {
                            Button("Войти") { showingLogin = true }
                            Button("Регистрация") { showingLogin = true /* можно RegisterView */ }
                        }.buttonStyle(.borderedProminent)
                    }
                } else if vm.isLoading {
                    ProgressView("Загрузка…")
                } else if let err = vm.error {
                    Text(err).foregroundColor(.red)
                } else if let user = vm.user {
                    profileSection(for: user)
                }
            }
            .navigationTitle("Профиль")
            .toolbar {
                if vm.user != nil {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button("Выход") { confirmLogout = true }
                    }
                }
            }
            .confirmationDialog("Выйти из аккаунта?",
                                isPresented: $confirmLogout) {
                Button("Выйти", role: .destructive) { vm.logout() }
            }
            .task { await vm.load() }
            .sheet(isPresented: $showingLogin) { LoginView() }
        }
    }

    // MARK: - UI
    @ViewBuilder private func profileSection(for user: User) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("\(user.firstName) \(user.lastName)")
                .font(.title2).bold()
            Text(user.email).font(.subheadline)
            if let phone = user.phoneNumber, !phone.isEmpty {
                Text("Телефон: \(phone)")
            }

            Divider().padding(.vertical, 4)

            Text("Мои объявления").font(.headline)
            if vm.myListings.isEmpty {
                Text("Вы ещё не разместили объявлений.")
                    .foregroundColor(.secondary)
            } else {
                List {
                    ForEach(vm.myListings) { lst in
                        NavigationLink(value: lst) {
                            ListingRowView(listing: lst)
                        }
                        .swipeActions(edge: .trailing) {
                            Button(role: .destructive) {
                                Task { await vm.deleteListing(lst) }
                            } label: { Label("Удалить", systemImage: "trash") }
                        }
                    }
                }
                .frame(maxHeight: 350)
            }
            Spacer(minLength: 0)
        }
        .navigationDestination(for: SaleListing.self) { ListingDetailView(listing: $0) }
        .padding()
    }
}
