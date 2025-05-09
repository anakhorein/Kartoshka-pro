import Foundation

/// Структура, представляющая информацию о продукте питания
///
/// Эта структура содержит полную информацию о продукте питания, включая его описание,
/// идентификаторы и значения различных питательных веществ. Каждое питательное вещество
/// представлено в виде опционального значения Float, где nXXXX соответствует
/// идентификатору питательного вещества в базе данных.
///
/// ## Пример использования
/// ```swift
/// let food = Food(description: "Яблоко", fdc_id: 12345, id: 1)
/// print(food.description) // Выведет: "Яблоко"
/// ```
///
/// ## Важные замечания
/// - Все значения питательных веществ являются опциональными, так как не все продукты содержат все питательные вещества
/// - Идентификатор `fdc_id` соответствует базе данных FoodData Central
/// - Структура поддерживает кодирование и декодирование (Codable) для работы с JSON
/// - Реализует протокол Identifiable для использования в SwiftUI списках
struct Food: Codable, Identifiable {
    /// Описание продукта питания
    ///
    /// Содержит полное название и описание продукта на русском языке
    let description: String
    /// Идентификатор продукта в базе данных FoodData Central
    let fdc_id: Int
    /// Уникальный идентификатор продукта в системе
    ///
    /// Используется для внутренней идентификации продуктов в приложении
    let id: Int
    
    /// Словарь значений питательных веществ
    /// Ключ - идентификатор питательного вещества (например, "n1001")
    /// Значение - количество питательного вещества
    let nutrientValues: [String: Float]
    
    enum CodingKeys: String, CodingKey {
        case description
        case fdc_id
        case id
    }
    
    init(description: String, fdc_id: Int, id: Int, nutrientValues: [String: Float]) {
        self.description = description
        self.fdc_id = fdc_id
        self.id = id
        self.nutrientValues = nutrientValues
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        description = try container.decode(String.self, forKey: .description)
        fdc_id = try container.decode(Int.self, forKey: .fdc_id)
        id = try container.decode(Int.self, forKey: .id)
        
        // Создаем словарь из всех свойств, начинающихся с "n"
        var values: [String: Float] = [:]
        let json = try decoder.singleValueContainer().decode(JSON.self)
        if let dict = json.value as? [String: Any] {
            for (key, value) in dict {
                if key.hasPrefix("n") {
                    if let floatValue = value as? Float {
                        values[key] = floatValue
                    } else if let doubleValue = value as? Double {
                        values[key] = Float(doubleValue)
                    } else if let intValue = value as? Int {
                        values[key] = Float(intValue)
                    }
                }
            }
        }
        nutrientValues = values
    }
}

// Вспомогательная структура для декодирования JSON
private struct JSON: Codable {
    let value: Any
    
    init(value: Any) {
        self.value = value
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        if let string = try? container.decode(String.self) {
            value = string
        } else if let int = try? container.decode(Int.self) {
            value = int
        } else if let double = try? container.decode(Double.self) {
            value = double
        } else if let bool = try? container.decode(Bool.self) {
            value = bool
        } else if let array = try? container.decode([JSON].self) {
            value = array.map { $0.value }
        } else if let dict = try? container.decode([String: JSON].self) {
            value = dict.mapValues { $0.value }
        } else {
            value = NSNull()
        }
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        switch value {
        case let string as String:
            try container.encode(string)
        case let int as Int:
            try container.encode(int)
        case let double as Double:
            try container.encode(double)
        case let bool as Bool:
            try container.encode(bool)
        case let array as [Any]:
            try container.encode(array.map { JSON(value: $0) })
        case let dict as [String: Any]:
            try container.encode(dict.mapValues { JSON(value: $0) })
        case is NSNull:
            try container.encodeNil()
        default:
            try container.encodeNil()
        }
    }
}

struct FoodItem: Codable, Identifiable {
    let description: String
    let fdc_id: Int
    let id: Int
    let nutrientValues: [String: Float]
    
    enum CodingKeys: String, CodingKey {
        case description
        case fdc_id
        case id
    }
    
    init(description: String, fdc_id: Int, id: Int, nutrientValues: [String: Float]) {
        self.description = description
        self.fdc_id = fdc_id
        self.id = id
        self.nutrientValues = nutrientValues
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        description = try container.decode(String.self, forKey: .description)
        fdc_id = try container.decode(Int.self, forKey: .fdc_id)
        id = try container.decode(Int.self, forKey: .id)
        
        // Создаем словарь из всех свойств, начинающихся с "n"
        var values: [String: Float] = [:]
        let json = try decoder.singleValueContainer().decode(JSON.self)
        if let dict = json.value as? [String: Any] {
            for (key, value) in dict {
                if key.hasPrefix("n") {
                    if let floatValue = value as? Float {
                        values[key] = floatValue
                    } else if let doubleValue = value as? Double {
                        values[key] = Float(doubleValue)
                    } else if let intValue = value as? Int {
                        values[key] = Float(intValue)
                    }
                }
            }
        }
        nutrientValues = values
    }
}
