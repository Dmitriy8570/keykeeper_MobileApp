struct CreateUserRequest: Codable {
    let firstName: String
    let lastName: String
    let email: String
    let password: String
}

struct LoginUserRequest: Codable {
    let email: String
    let password: String
}

struct RegisterUserResponse: Codable {
    let userId: Int
}

struct LoginUserResponse: Codable {
    let token: String
}

