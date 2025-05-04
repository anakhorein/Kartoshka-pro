//
//  DetailViewModel.swift
//  Kartoshka pro
//
//  Created by Alexander Knyazev on 03.05.2025.
//

// Kartoshka pro/ViewModels/DetailViewModel.swift

import Foundation
import Combine

/// ViewModel для отображения детальной информации о продукте питания
/// 
/// Этот класс отвечает за загрузку и кэширование детальной информации о продукте питания с сервера.
/// Он управляет состоянием загрузки, обработкой ошибок и обновлением пользовательского интерфейса.
class DetailViewModel: ObservableObject {
    /// Детальная информация о продукте питания
    @Published var foodItem: FoodItemAnswer?
    
    /// Флаг, указывающий на состояние загрузки данных
    @Published var showProgress = false
    
    /// Значение прогресса загрузки (от 0 до 1)
    @Published var progressValue = 0.0
    
    /// Ошибка, возникшая во время загрузки данных
    @Published var error: Error?
    
    /// Репозиторий для работы с данными о продуктах
    private let repository: FoodRepository
    
    /// Базовая информация о продукте питания
    let food: Food
    
    /// Набор для хранения подписок
    private var cancellables = Set<AnyCancellable>()
    
    /// Инициализатор ViewModel
    /// - Parameters:
    ///   - food: Базовая информация о продукте питания
    ///   - repository: Репозиторий для работы с данными (по умолчанию новый экземпляр)
    init(food: Food, repository: FoodRepository = FoodRepository()) {
        self.food = food
        self.repository = repository
    }
    
    /// Загружает детальную информацию о продукте питания с сервера
    /// 
    /// Метод выполняет следующие действия:
    /// 1. Обновляет состояние загрузки
    /// 2. Запрашивает данные через репозиторий
    /// 3. Обрабатывает результат и обновляет UI
    func loadFoodItem() async {
        await MainActor.run {
            showProgress = true
            progressValue = 0.0
            error = nil
        }
        
        do {
            let foodItem = try await withCheckedThrowingContinuation { continuation in
                repository.loadFoodItem(foodId: food.fdc_id)
                    .receive(on: DispatchQueue.main)
                    .sink { completion in
                        switch completion {
                        case .finished:
                            break
                        case .failure(let error):
                            continuation.resume(throwing: error)
                        }
                    } receiveValue: { foodItem in
                        continuation.resume(returning: foodItem)
                    }
                    .store(in: &cancellables)
            }
            
            await MainActor.run {
                self.foodItem = foodItem
                self.progressValue = 75.0
                self.showProgress = false
                self.progressValue = 100.0
            }
        } catch {
            await handleError(error)
        }
    }
    
    /// Обрабатывает ошибки, возникшие во время загрузки данных
    /// - Parameter error: Ошибка для обработки
    private func handleError(_ error: Error) async {
        await MainActor.run {
            self.error = error
            self.progressValue = 0.0
            self.showProgress = false
            print("Error occurred: \(error.localizedDescription)")
        }
    }
}
