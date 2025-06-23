import Foundation
import CoreLocation

struct StringCodingKey: CodingKey, ExpressibleByStringLiteral {
    // обязательное свойство
    let stringValue: String
    // обязательный инициализатор CodingKey
    init?(stringValue: String) { self.stringValue = stringValue }
    
    // integer-ключи нам не нужны
    let intValue: Int? = nil
    init?(intValue: Int) { return nil }
    
    // удобные вспомогательные инициализаторы
    init(_ string: String)               { self.stringValue = string }
    init(stringLiteral value: String)    { self.stringValue = value }
}

private extension Collection {
    /// Безопасный доступ по индексу (не падает при выходе за диапазон).
    subscript(safe index: Index) -> Element? {
        indices.contains(index) ? self[index] : nil
    }
}
