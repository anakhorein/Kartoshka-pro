import Foundation

/// Конфигурация приложения
/// 
/// Этот enum содержит все константы и настройки, используемые в приложении.
/// Он включает в себя URL-адреса API, настройки сети, параметры UI и значения по умолчанию.
enum Config {
    // MARK: - API URLs
    
    /// Базовый URL для API
    static let baseURL = "https://api.knyazev.site"
    
    /// Endpoint для получения списка продуктов
    static let foodListEndpoint = "\(baseURL)/food/"
    
    /// Endpoint для получения информации о конкретном продукте
    static let foodItemEndpoint = "\(baseURL)/food/item"
    
    // MARK: - Network
    
    /// Таймаут для сетевых запросов в секундах
    static let timeoutInterval: TimeInterval = 30
    
    /// Политика кэширования по умолчанию
    static let defaultCachePolicy: URLRequest.CachePolicy = .returnCacheDataElseLoad
    
    // MARK: - UI
    
    /// Размер страницы по умолчанию для пагинации
    static let defaultPageSize = 20
    
    /// Минимальная длина текста для поиска
    static let searchMinLength = 3
    
    // MARK: - Default Nutrients
    
    /// Список нутриентов по умолчанию для отображения
    static let defaultNutrients = [
        Nutrient(id: "1008", name: "Energy", nutrient_nbr: "208", rank: "300", unit_name: "KCAL"),
        Nutrient(id: "1003", name: "Protein", nutrient_nbr: "203", rank: "600", unit_name: "G"),
        Nutrient(id: "1004", name: "Total lipid (fat)", nutrient_nbr: "204", rank: "800", unit_name: "G"),
        Nutrient(id: "1005", name: "Carbohydrate, by difference", nutrient_nbr: "205", rank: "1110", unit_name: "G")
    ]
    
    // MARK: - Food Categories
    
    /// Список всех доступных категорий продуктов
    static let allCategories = [
        "branded_food",
        "experimental_food",
        "foundation_food",
        "sr_legacy_food",
        "survey_fndds_food"
    ]
} 