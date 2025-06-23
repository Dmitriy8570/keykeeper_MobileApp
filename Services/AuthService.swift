import Foundation

struct AuthService {
    
    // POST /api/Users/register
    func register(firstName: String,
                  lastName: String,
                  email: String,
                  password: String) async throws {
        let dto  = CreateUserRequest(firstName: firstName,
                                     lastName: lastName,
                                     email: email,
                                     password: password)
        let body = try JSONEncoder().encode(dto)
        _ = try await APIClient.shared.sendRequest(
            "api/Users/register",
            method: "POST",
            body: body,
            authorize: false,
            responseType: EmptyResponse.self
        )
        try await login(email: email, password: password)
    }
    
    // POST /api/Users/login
    func login(email: String, password: String) async throws {
        let dto  = LoginUserRequest(email: email, password: password)
        let body = try JSONEncoder().encode(dto)
        let resp: LoginUserResponse = try await APIClient.shared.sendRequest(
            "api/Users/login",
            method: "POST",
            body: body,
            authorize: false
        )
        APIClient.shared.authToken = resp.token
    }
    
    func logout() { APIClient.shared.authToken = nil }
}
