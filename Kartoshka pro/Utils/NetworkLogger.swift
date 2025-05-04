import Foundation

/// Класс для логирования сетевых запросов и ответов
/// 
/// Этот класс предоставляет методы для логирования информации о сетевых запросах,
/// ответах и ошибках. Логирование происходит только в режиме отладки (DEBUG).
class NetworkLogger {
    // MARK: - Constants
    
    /// Эмодзи для обозначения исходящего запроса
    private static let requestEmoji = "📤"
    
    /// Эмодзи для обозначения входящего ответа
    private static let responseEmoji = "📥"
    
    /// Эмодзи для обозначения ошибки
    private static let errorEmoji = "❌"
    
    /// Эмодзи для обозначения успешного ответа
    private static let successEmoji = "✅"
    
    /// Разделитель для форматирования логов
    private static let separator = "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    
    // MARK: - Public Methods
    
    /// Логирует информацию о сетевом запросе
    /// - Parameter request: URLRequest для логирования
    /// - Note: Метод логирует URL, метод, заголовки и тело запроса
    static func logRequest(_ request: URLRequest) {
        #if DEBUG
        print("\n\(separator)")
        print("\(requestEmoji) Network Request")
        print("\(separator)")
        
        // URL
        if let url = request.url?.absoluteString {
            print("📍 URL: \(url)")
        }
        
        // Method
        if let method = request.httpMethod {
            print("📝 Method: \(method)")
        }
        
        // Headers
        if let headers = request.allHTTPHeaderFields, !headers.isEmpty {
            print("📋 Headers:")
            headers.forEach { key, value in
                print("   • \(key): \(value)")
            }
        }
        
        // Body
        if let body = request.httpBody,
           let bodyString = String(data: body, encoding: .utf8) {
            print("📦 Body:")
            print(bodyString)
        }
        
        print("\(separator)\n")
        #endif
    }
    
    /// Логирует информацию о сетевом ответе
    /// - Parameters:
    ///   - response: URLResponse для логирования
    ///   - data: Данные ответа
    ///   - error: Ошибка, если она возникла
    /// - Note: Метод логирует статус код, заголовки, тело ответа и ошибки
    static func logResponse(_ response: URLResponse?, data: Data?, error: Error?) {
        #if DEBUG
        print("\n\(separator)")
        print("\(responseEmoji) Network Response")
        print("\(separator)")
        
        // Status Code
        if let httpResponse = response as? HTTPURLResponse {
            let statusEmoji = (200...299).contains(httpResponse.statusCode) ? successEmoji : errorEmoji
            print("\(statusEmoji) Status: \(httpResponse.statusCode)")
            
            // Headers
            if !httpResponse.allHeaderFields.isEmpty {
                print("📋 Headers:")
                httpResponse.allHeaderFields.forEach { key, value in
                    print("   • \(key): \(value)")
                }
            }
        }
        
        // Response Body
        if let data = data {
            print("📦 Response Body:")
            if let jsonObject = try? JSONSerialization.jsonObject(with: data),
               let prettyData = try? JSONSerialization.data(withJSONObject: jsonObject, options: .prettyPrinted),
               let prettyString = String(data: prettyData, encoding: String.Encoding.utf8) {
                print(prettyString)
            } else if let string = String(data: data, encoding: String.Encoding.utf8) {
                print(string)
            }
        }
        
        // Error
        if let error = error {
            print("\(errorEmoji) Error: \(error.localizedDescription)")
        }
        
        print("\(separator)\n")
        #endif
    }
} 