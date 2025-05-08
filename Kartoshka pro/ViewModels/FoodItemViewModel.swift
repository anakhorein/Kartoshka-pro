import Foundation
import Combine

class FoodItemViewModel: ObservableObject {
    @Published var foodItems: [FoodItem] = []
    @Published var showProgress: Bool = false
    @Published var progressValue: Double = 0.0
    @Published var error: Error?
    
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        // Инициализация
    }
    
    func loadData() async {
        // Здесь будет логика загрузки данных
    }
    
    func filterFoodByTitle(_ title: String) async {
        // Здесь будет логика фильтрации по названию
    }
} 