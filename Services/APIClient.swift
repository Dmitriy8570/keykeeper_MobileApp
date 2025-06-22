import Foundation
import JWTDecode

final class APIClient {

    /// Единый экземпляр
    static let shared = APIClient()

    /// Базовый URL вашего сервера
    let baseURL = URL(string: "http://192.168.1.3:5059/")!   // ← поменяйте на прод

    /// Текущий JWT-токен (можно менять)
    var authToken: String? {
        didSet {
            if let token = authToken {
                KeychainHelper.save(token: token, for: "authToken")
            } else {
                KeychainHelper.removeToken(for: "authToken")
            }
        }
    }

    private init() {
        authToken = KeychainHelper.retrieveToken(for: "authToken")
    }

    // MARK: - Универсальный generic-запрос

    func sendRequest<T: Decodable>(
        _ endpoint: String,
        method: String = "GET",
        body: Data? = nil,
        authorize: Bool = false
    ) async throws -> T {

        var request = URLRequest(url: baseURL.appendingPathComponent(endpoint))
        request.httpMethod = method

        if let body = body {
            request.httpBody = body
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        }
        if authorize, let token = authToken {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }

        let (data, response) = try await URLSession.shared.data(for: request)
        guard let http = response as? HTTPURLResponse, http.statusCode < 300 else {
            throw URLError(.badServerResponse)
        }
        return try JSONDecoder().decode(T.self, from: data)
    }
    
    func currentUserId() -> Int? {
        guard let token = APIClient.shared.authToken else {return nil}
        do {
            let jwt = try decode(jwt: token)
            return Int(jwt.subject ?? "")
        } catch {
            print("JWT decode error:", error)
            return nil
        }
    }
}

private struct Empty: Decodable {}

extension APIClient {

    @discardableResult
    func sendRequest(
        _ endpoint: String,
        method: String = "GET",
        body: Data? = nil,
        authorize: Bool = false
    ) async throws {
        // используем «старый» generic-метод с явным типом-заглушкой
        let _: Empty = try await sendRequest(
            endpoint,
            method: method,
            body: body,
            authorize: authorize
        )
    }
}
