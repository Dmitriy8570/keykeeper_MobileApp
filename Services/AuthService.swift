import Foundation

struct AuthService{
    func register(firstName: String, lastName: String, email: String, password: String) async throws{
        let requestData = CreateUserRequest(firstName: firstName, lastName: lastName, email: email, password: password)
        let body = try JSONEncoder().encode(requestData)
        
        let response: RegisterUserResponse = try await APIClient.shared.sendRequest("api/Users/register",
                                                                                    method: "POST",
                                                                                    body: body,
                                                                                    authorize: false)
        try await login(email: email, password: password)
    }
    
    func login(email: String, password: String) async throws{
        let requestData = LoginUserRequest(email: email, password: password)
        let body = try JSONEncoder().encode(requestData)
        let response: LoginUserResponse = try await APIClient.shared.sendRequest("api/Users/login",
                                                                                 method: "GET",
                                                                                 body: body,
                                                                                 authorize: false)
        
        APIClient.shared.authToken = response.token
    }
}

