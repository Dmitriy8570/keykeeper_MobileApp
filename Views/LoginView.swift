import SwiftUI

struct LoginView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var email = ""
    @State private var password = ""
    @State private var error: String?
    @State private var isBusy = false

    var body: some View {
        NavigationStack {
            Form {
                TextField("E-mail", text: $email).keyboardType(.emailAddress)
                    .textInputAutocapitalization(.never)
                SecureField("Пароль", text: $password)

                if let err = error {
                    Text(err).foregroundColor(.red)
                }

                Button("Войти") {
                    Task {
                        isBusy = true
                        defer { isBusy = false }
                        do {
                            try await AuthService().login(email: email, password: password)
                            dismiss()
                        } catch {
                            self.error = error.localizedDescription
                        }
                    }
                }
                disabled(isBusy || email.isEmpty || password.isEmpty)
            }
            .navigationTitle("Вход")
            .toolbar { ToolbarItem(placement: .cancellationAction) { Button("Отмена") { dismiss() } } }
        }
    }
}

struct RegisterView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var first = ""
    @State private var last  = ""
    @State private var email = ""
    @State private var pass  = ""
    @State private var error: String?
    @State private var isBusy = false

    var body: some View {
        NavigationStack {
            Form {
                TextField("Имя", text: $first)
                TextField("Фамилия", text: $last)
                TextField("E-mail", text: $email)
                    .keyboardType(.emailAddress)
                    .textInputAutocapitalization(.never)
                SecureField("Пароль", text: $pass)

                if let err = error {
                    Text(err).foregroundColor(.red)
                }

                Button("Создать аккаунт") {
                    Task {
                        isBusy = true
                        defer { isBusy = false }
                        do {
                            try await AuthService()
                                .register(firstName: first, lastName: last,
                                          email: email, password: pass)
                            dismiss()
                        } catch {
                            self.error = error.localizedDescription
                        }
                    }
                }
                disabled(isBusy || first.isEmpty || last.isEmpty ||
                                           email.isEmpty || pass.isEmpty)
            }
            .navigationTitle("Регистрация")
            .toolbar { ToolbarItem(placement: .cancellationAction) { Button("Отмена") { dismiss() } } }
        }
    }
}
