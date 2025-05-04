import Foundation

/// Менеджер кэширования данных
/// 
/// Этот класс отвечает за кэширование данных в памяти с поддержкой времени жизни кэша.
/// Он использует `NSCache` для эффективного хранения данных и автоматического освобождения памяти.
final class CacheManager {
    // MARK: - Singleton
    
    /// Общий экземпляр менеджера кэширования
    static let shared = CacheManager()
    
    // MARK: - Properties
    
    /// Кэш для хранения данных
    private let cache = NSCache<NSString, CacheEntry>()
    
    /// Очередь для синхронизации доступа к кэшу
    private let queue = DispatchQueue(label: "com.kartoshka.cache", qos: .utility)
    
    // MARK: - Initialization
    
    /// Приватный инициализатор для реализации паттерна Singleton
    private init() {
        cache.countLimit = 100 // Максимальное количество элементов в кэше
    }
    
    // MARK: - Public Methods
    
    /// Сохраняет данные в кэш
    /// - Parameters:
    ///   - data: Данные для кэширования
    ///   - key: Ключ для сохранения данных
    ///   - expirationInterval: Время жизни кэша в секундах (по умолчанию 300 секунд)
    /// - Note: Данные автоматически удаляются из кэша после истечения времени жизни
    func set<T: Codable>(_ data: T, forKey key: String, expirationInterval: TimeInterval = 300) {
        let entry = CacheEntry(data: data, expirationDate: Date().addingTimeInterval(expirationInterval))
        queue.async {
            self.cache.setObject(entry, forKey: key as NSString)
        }
    }
    
    /// Получает данные из кэша
    /// - Parameter key: Ключ для получения данных
    /// - Returns: Данные из кэша или nil, если данные отсутствуют или устарели
    /// - Note: Метод автоматически проверяет срок действия кэша
    func get<T: Codable>(forKey key: String) -> T? {
        queue.sync {
            guard let entry = cache.object(forKey: key as NSString),
                  entry.expirationDate > Date() else {
                return nil
            }
            return entry.data as? T
        }
    }
    
    /// Очищает кэш
    /// - Note: Метод удаляет все данные из кэша
    func clear() {
        queue.async {
            self.cache.removeAllObjects()
        }
    }
}

// MARK: - CacheEntry

/// Вспомогательный класс для хранения данных в кэше
private final class CacheEntry {
    /// Данные, хранящиеся в кэше
    let data: Any
    
    /// Дата истечения срока действия кэша
    let expirationDate: Date
    
    /// Инициализатор записи кэша
    /// - Parameters:
    ///   - data: Данные для хранения
    ///   - expirationDate: Дата истечения срока действия
    init(data: Any, expirationDate: Date) {
        self.data = data
        self.expirationDate = expirationDate
    }
} 