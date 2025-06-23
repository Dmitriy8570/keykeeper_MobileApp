import Foundation
import CryptoKit

// MARK: - Общие ошибки сети

struct EmptyResponse: Decodable {}

// MARK: - Общая ошибка сети
enum APIError: LocalizedError {
    case badURL
    case invalidResponse
    case statusCode(Int, String)
    case decoding(Error)
    case encoding(Error)
    case unauthorized
    case other(Error)
    
    var errorDescription: String? {
        switch self {
        case .badURL:                  return "Неверный URL."
        case .invalidResponse:         return "Некорректный ответ сервера."
        case .statusCode(let c, let m):return "Ошибка \(c): \(m)"
        case .decoding(let e):         return "Ошибка декодирования: \(e.localizedDescription)"
        case .encoding(let e):         return "Ошибка кодирования: \(e.localizedDescription)"
        case .unauthorized:            return "Требуется авторизация."
        case .other(let e):            return e.localizedDescription
        }
    }
}

// MARK: - Базовый HTTP-клиент
final class APIClient {
    
    static let shared = APIClient()
    
    /// Укажите фактический адрес вашего бэкенда
    var baseURL: URL = URL(string: "http://192.168.1.3:5059/")!
    
    /// JWT токен; автоматически сохраняется/стирается через KeychainHelper
    var authToken: String? {
        didSet {
            if let t = authToken { KeychainHelper.save(token: t, for: "authToken") }
            else { KeychainHelper.removeToken(for: "authToken") }
        }
    }
    
    private init() {
        authToken = KeychainHelper.retrieveToken(for: "authToken")
    }
    
    // MARK: универсальный запрос -------------------------------------------------
    @discardableResult
    func sendRequest<T: Decodable>(
        _ path: String,
        method: String = "GET",
        query: [URLQueryItem]? = nil,
        body: Data? = nil,
        authorize: Bool = false,
        responseType: T.Type = T.self
    ) async throws -> T {
        
        // 1. URL
        guard var components = URLComponents(url: baseURL.appendingPathComponent(path),
                                             resolvingAgainstBaseURL: false) else {
            throw APIError.badURL
        }
        components.queryItems = query
        guard let url = components.url else { throw APIError.badURL }
        
        // 2. Request
        var request = URLRequest(url: url)
        request.httpMethod = method
        if body != nil { request.setValue("application/json", forHTTPHeaderField: "Content-Type") }
        request.httpBody = body
        
        if authorize {
            guard let token = authToken else { throw APIError.unauthorized }
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        
        // 3. Выполняем
        let (data, response): (Data, URLResponse)
        do {
            (data, response) = try await URLSession.shared.data(for: request)
        } catch {
            throw APIError.other(error)
        }
        
        // 4. Проверяем HTTP-код
        guard let httpResp = response as? HTTPURLResponse else { throw APIError.invalidResponse }
        guard (200...299).contains(httpResp.statusCode) else {
            if httpResp.statusCode == 401 { throw APIError.unauthorized }
            let message = String(data: data, encoding: .utf8) ?? ""
            throw APIError.statusCode(httpResp.statusCode, message)
        }
        
        // 5. "пустой" ответ, который нам всё равно читать не нужно
        if T.self == EmptyResponse.self {
            return EmptyResponse() as! T
        }
        
        // 6. если данных реально ноль байт
        if data.isEmpty {
            if let coll = T.self as? any RangeReplaceableCollection.Type,
               let empty = coll.init() as? T { return empty }
            if T.self == Data.self { return Data() as! T }
            throw APIError.invalidResponse
        }
        
        // 7. обычное декодирование
        do {
            return try JSONDecoder().decode(T.self, from: data)
        } catch { throw APIError.decoding(error) }
    }
    
    // MARK: userId из JWT
    func currentUserId() -> Int? {
        guard let token = authToken else { return nil }
        let parts = token.split(separator: ".")
        guard parts.count > 1 else { return nil }
        var base64 = String(parts[1])
            .replacingOccurrences(of: "-", with: "+")
            .replacingOccurrences(of: "_", with: "/")
        while base64.count % 4 != 0 { base64.append("=") }
        guard let data = Data(base64Encoded: base64),
              let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
              let sub = json["sub"] as? String,
              let id  = Int(sub) else { return nil }
        return id
    }
}
