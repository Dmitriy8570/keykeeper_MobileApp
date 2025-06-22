struct CreateUserRequest: Codable{
    let firstName: String
    let lastName: String
    let email: String
    let password: String
}

struct RegisterUserResponse: Codable{
    let userId: Int
    let email: String
}

struct LoginUserRequest: Codable{
    let email: String
    let password: String
}

struct LoginUserResponse: Codable{
    let token: String
}
