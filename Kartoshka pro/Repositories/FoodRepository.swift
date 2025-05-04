import Foundation
import Combine

/// `FoodRepository` - класс для работы с API продуктов питания
/// 
/// Этот класс отвечает за взаимодействие с сервером для получения данных о продуктах питания.
/// Он управляет кэшированием, обработкой ошибок и преобразованием данных.
class FoodRepository {
    // MARK: - Properties
    
    private let session = URLSession.shared
    private let jsonDecoder = JSONDecoder()
    private var cancellables = Set<AnyCancellable>()
    private let cacheManager = CacheManager.shared
    
    // MARK: - Public Methods
    
    /// Загружает список продуктов с учетом фильтров и пагинации
    /// - Parameters:
    ///   - page: Номер страницы для пагинации
    ///   - sortType: Поле для сортировки результатов
    ///   - sortDirection: Направление сортировки ("asc" или "desc")
    ///   - types: Массив типов продуктов для фильтрации
    ///   - search: Текст поиска для фильтрации по названию
    ///   - nutrients: Массив идентификаторов нутриентов для включения в ответ
    /// - Returns: Результат запроса с данными или ошибкой
    /// - Note: Метод автоматически обрабатывает кэширование и обновление данных
    func loadFoods(
        page: Int,
        sortType: String,
        sortDirection: String,
        types: [String],
        search: String,
        nutrients: [String]
    ) -> AnyPublisher<Answer, Error> {
        // Формируем ключ кэша на основе параметров запроса
        let cacheKey = "foods_\(page)_\(sortType)_\(sortDirection)_\(types.joined(separator: ","))_\(search)_\(nutrients.joined(separator: ","))"
        
        // Пытаемся получить данные из кэша
        if let cachedAnswer: Answer = cacheManager.get(forKey: cacheKey) {
            return Just(cachedAnswer)
                .setFailureType(to: Error.self)
                .eraseToAnyPublisher()
        }
        
        let parameters: [String: Any] = [
            "page": page,
            "sort": sortType,
            "sortOrder": sortDirection,
            "types": types,
            "search": search,
            "nutrients": nutrients
        ]
        
        guard let url = URL(string: Config.foodListEndpoint) else {
            return Fail(error: NetworkError.invalidURL)
                .eraseToAnyPublisher()
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("Application/json", forHTTPHeaderField: "Content-Type")
        
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: parameters)
        } catch {
            return Fail(error: NetworkError.encodingError)
                .eraseToAnyPublisher()
        }
        
        // Логируем запрос
        NetworkLogger.logRequest(request)
        
        return session.dataTaskPublisher(for: request)
            .tryMap { data, response in
                // Логируем ответ
                NetworkLogger.logResponse(response, data: data, error: nil)
                
                guard let httpResponse = response as? HTTPURLResponse else {
                    throw NetworkError.unknown
                }
                
                switch httpResponse.statusCode {
                case 200:
                    return data
                case 401:
                    throw NetworkError.unauthorized
                case 403:
                    throw NetworkError.forbidden
                case 404:
                    throw NetworkError.notFound
                default:
                    throw NetworkError.serverError("Server returned status code \(httpResponse.statusCode)")
                }
            }
            .decode(type: Answer.self, decoder: jsonDecoder)
            .map { answer in
                // Сохраняем результат в кэш
                self.cacheManager.set(answer, forKey: cacheKey)
                return answer
            }
            .mapError { error in
                // Логируем ошибку
                NetworkLogger.logResponse(nil, data: nil, error: error)
                return error
            }
            .eraseToAnyPublisher()
    }
    
    /// Загружает детальную информацию о продукте питания
    /// - Parameter foodId: Идентификатор продукта питания
    /// - Returns: Результат запроса с данными или ошибкой
    /// - Note: Метод автоматически обрабатывает кэширование и обновление данных
    func loadFoodItem(foodId: Int) -> AnyPublisher<FoodItemAnswer, Error> {
        // Формируем ключ кэша
        let cacheKey = "food_item_\(foodId)"
        
        // Пытаемся получить данные из кэша
        if let cachedAnswer: FoodItemAnswer = cacheManager.get(forKey: cacheKey) {
            return Just(cachedAnswer)
                .setFailureType(to: Error.self)
                .eraseToAnyPublisher()
        }
        
        guard let url = URL(string: Config.foodItemEndpoint) else {
            return Fail(error: NetworkError.invalidURL)
                .eraseToAnyPublisher()
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        // Создаем тело запроса с ID
        let body = [
            "id": String(foodId)
        ] as [String: Any]
        request.httpBody = try? JSONSerialization.data(withJSONObject: body)
        
        // Логируем запрос
        NetworkLogger.logRequest(request)
        
        return session.dataTaskPublisher(for: request)
            .tryMap { data, response in
                // Логируем ответ
                NetworkLogger.logResponse(response, data: data, error: nil)
                
                guard let httpResponse = response as? HTTPURLResponse else {
                    throw NetworkError.unknown
                }
                
                switch httpResponse.statusCode {
                case 200:
                    return data
                case 401:
                    throw NetworkError.unauthorized
                case 403:
                    throw NetworkError.forbidden
                case 404:
                    throw NetworkError.notFound
                default:
                    throw NetworkError.serverError("Server returned status code \(httpResponse.statusCode)")
                }
            }
            .decode(type: FoodItemAnswer.self, decoder: jsonDecoder)
            .map { answer in
                // Сохраняем результат в кэш
                self.cacheManager.set(answer, forKey: cacheKey)
                return answer
            }
            .mapError { error in
                // Логируем ошибку
                NetworkLogger.logResponse(nil, data: nil, error: error)
                return error
            }
            .eraseToAnyPublisher()
    }
}

// MARK: - NetworkError

enum NetworkError: Error {
    case invalidURL
    case encodingError
    case decodingError
    case serverError(String)
    case noData
    case unauthorized
    case forbidden
    case notFound
    case unknown
}
