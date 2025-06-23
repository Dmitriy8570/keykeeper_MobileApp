import Foundation
import Security

struct KeychainHelper {
/// Save token to persistent storage (using UserDefaults for simplicity)
    static func save(token: String, for key: String) {
        UserDefaults.standard.set(token, forKey: key)
    }
    /// Retrieve token from storage
    static func retrieveToken(for key: String) -> String? {
        return UserDefaults.standard.string(forKey: key)
    }
    /// Remove token from storage
    static func removeToken(for key: String) {
        UserDefaults.standard.removeObject(forKey: key)
    }
}
