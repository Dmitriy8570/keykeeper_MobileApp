import SwiftUI

struct ProfileView: View {
    @StateObject var viewModel = ProfileViewModel()
    @State private var showingEditProfile = false
    
    var body: some View {
        NavigationView {
            if APIClient.shared.authToken == nil {
                VStack {
                    Text("Войдите, чтобы просмотреть профиль и объявления.")
                        .padding()
                    Button("Войти") {
                        // переход на экран логина
                    }
                    Button("Регистрация") {
                        // переход на экран регистрации
                    }
                }
            } else {
                VStack(alignment: .leading) {
                    if let user = viewModel.user {
                        Text("\(user.firstName) \(user.lastName)")
                            .font(.title2).bold()
                        Text(user.email).foregroundColor(.secondary)
                        if let phone = user.phoneNumber, !phone.isEmpty {
                            Text("Телефон: \(phone)")
                        }
                        Button("Редактировать профиль") {
                            showingEditProfile = true
                        }.padding(.vertical, 8)
                        Divider()
                    } else if viewModel.loading {
                        ProgressView("Загрузка профиля...")
                    }
                    
                    Text("Мои объявления:")
                        .font(.headline).padding(.vertical, 5)
                    if viewModel.myListings.isEmpty {
                        Text("У вас пока нет размещенных объявлений.")
                            .foregroundColor(.secondary)
                    } else {
                        List {
                            ForEach(viewModel.myListings) { listing in
                                ListingRowView(listing: listing)
                                    .swipeActions(edge: .trailing) {
                                        Button("Удалить", role: .destructive) {
                                            Task {
                                                try? await ListingService().deleteListing(listingId: listing.id)
                                                // Обновим список после удаления
                                                await viewModel.loadProfile()
                                            }
                                        }
                                        Button("Изменить") {
                                            // Открыть экран редактирования объявления (можно переиспользовать форму NewListingFormView с предварительным заполнением)
                                        }
                                    }
                                    .onTapGesture {
                                        // открыть детальный просмотр (можно использовать тот же ListingDetailView)
                                    }
                            }
                        }
                    }
                    Spacer()
                    Button("Выйти") {
                        viewModel.logout()
                    }
                    .foregroundColor(.red)
                    .padding(.top, 20)
                }
                .padding()
                .navigationTitle("Профиль")
                //.sheet(isPresented: $showingEditProfile) {
                    //EditProfileView(user: viewModel.user!)
                //}
            }
        }
        .onAppear {
            Task { await viewModel.loadProfile() }
        }
    }
}
