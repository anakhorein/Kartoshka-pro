import SwiftUI
import Combine

/// `FoodViewModel` - основной класс для управления данными о продуктах питания
/// 
/// Этот класс отвечает за управление списком продуктов питания, их фильтрацию,
/// сортировку и загрузку данных с сервера. Он также управляет состоянием UI и
/// обработкой ошибок.
/// Наследуется от `ObservableObject`, что позволяет SwiftUI отслеживать изменения в этом классе
/// и автоматически обновлять пользовательский интерфейс при изменении данных
class FoodViewModel: ObservableObject {
    // MARK: - Published Properties
    /// Аннотация `@Published` позволяет SwiftUI автоматически обновлять UI при изменении этих свойств
    
    /// Массив продуктов питания, отображаемых в текущем представлении
    @Published var foods: [Food] = []
    
    /// Временное хранилище для продуктов (может использоваться для кэширования или сохранения состояния)
    @Published var stashFoods: [Food] = []
    
    /// Общее количество продуктов, доступных по текущему запросу (для пагинации)
    @Published var count: Int = 0
    
    /// Текущая страница при пагинации результатов
    @Published var page: Int = 1
    
    /// Список всех доступных категорий продуктов
    /// Каждая категория имеет идентификатор и название на русском и английском языках
    @Published var categories: [Category] = [
        Category(id: "", title: "All food", title_en: "All food"),
        Category(id: "branded_food", title: "Branded food", title_en: "Branded food"),
        Category(id: "experimental_food", title: "Experimental food", title_en: "Experimental food"),
        Category(id: "foundation_food", title: "Foundation food", title_en: "Foundation food"),
        Category(id: "sr_legacy_food", title: "SR legacy food", title_en: "SR legacy food"),
        Category(id: "survey_fndds_food", title: "Survey (FNDDS) food", title_en: "Survey (FNDDS) food")
    ]
    
    /// Текущая выбранная категория для фильтрации продуктов
    @Published var categoryCurrent: Category = Category(id: "foundation_food", title: "Foundation food", title_en: "Foundation food")
    
    /// Текст поискового запроса, используемый для фильтрации продуктов
    @Published var searchText: String = ""
    
    /// Дополнительное поле для хранения текста поиска (может использоваться для временного хранения)
    @Published var textSearch: String = ""
    
    /// Флаг, указывающий, находится ли пользователь в режиме редактирования
    @Published var isEditing: Bool = false
    
    /// Поле, по которому сортируются продукты (например, "id", "name" и т.д.)
    @Published var sortType: String = "id"
    
    /// Направление сортировки: "asc" (по возрастанию) или "desc" (по убыванию)
    @Published var sortDirection: String = "desc"
    
    /// Идентификатор выбранного продукта (для детального просмотра)
    @Published var selectedFoodId: Int = 0
    
    /// Продукт, отображаемый в модальном окне
    @Published var modalFood: Food?
    
    /// Флаг для отображения листа выбора языка
    @Published var showLanguageSheet: Bool = false
    
    /// Флаг для отображения индикатора загрузки
    @Published var showProgress: Bool = false
    
    /// Значение прогресса загрузки (от 0.0 до 1.0)
    @Published var progressValue: Double = 0.0
    
    /// Список всех доступных питательных веществ (нутриентов)
    @Published var nutrients: [Nutrient]?
    
    /// Список выбранных нутриентов для отображения в информации о продукте
    @Published var selectedNutrients: [Nutrient] = Config.defaultNutrients
    
    // MARK: - Private Properties
    
    /// Набор отменяемых подписок Combine для управления асинхронными операциями
    /// Используется для предотвращения утечек памяти при отмене запросов
    private var cancellables = Set<AnyCancellable>()
    
    /// Сессия URL для выполнения сетевых запросов
    private let session = URLSession.shared
    
    /// Кэш URL для хранения результатов запросов
    private let cache = URLCache.shared
    
    /// Декодер JSON для преобразования данных JSON в объекты Swift
    private let jsonDecoder = JSONDecoder()
    
    /// Набор отменяемых подписок Combine для управления асинхронными операциями
    /// Используется для предотвращения утечек памяти при отмене запросов
    private let foodRepository: FoodRepository
    
    /// Инициализатор класса
    /// Вызывается при создании экземпляра FoodViewModel
    /// Загружает данные о нутриентах при инициализации
    init(foodRepository: FoodRepository = FoodRepository()) {
        self.foodRepository = foodRepository
        loadNutrients()
    }
    
    // MARK: - Public Methods
    
    /// Фильтрует продукты по введенному тексту поиска
    /// - Parameter text: Текст поискового запроса для фильтрации продуктов
    /// - Note: Метод сбрасывает страницу на первую и загружает новые данные
    func filterFoodByTitle(_ text: String) async {
        await MainActor.run {
            searchText = text
            page = 1
        }
        await loadData()
    }
    
    /// Фильтрует продукты по выбранной категории
    /// - Parameter category: Категория для фильтрации, по умолчанию "All food"
    /// - Note: Метод устанавливает текущую категорию и загружает соответствующие данные
    func filterFood(_ category: Category = Category(id: "", title: "All food", title_en: "All food")) async {
        await MainActor.run {
            categoryCurrent = category
        }
        await loadData()
    }
    
    /// Изменяет порядок сортировки продуктов
    /// - Parameter sortType: Поле для сортировки, по умолчанию "id"
    /// - Note: Если выбрано то же поле, что и ранее, меняет направление сортировки
    func changeSort(_ sortType: String = "id") async {
        await MainActor.run {
            if self.sortType == sortType {
                sortDirection = sortDirection == "asc" ? "desc" : "asc"
            } else {
                self.sortType = sortType
                sortDirection = "asc"
            }
        }
        await loadData()
    }
    
    /// Загружает следующую страницу продуктов
    /// - Note: Метод увеличивает номер страницы и загружает дополнительные данные
    func loadNextPage() async {
        await MainActor.run {
            page += 1
        }
        await loadData()
    }
    
    /// Загружает данные о продуктах из API на основе текущих фильтров и настроек сортировки
    /// Этот метод выполняет сетевой запрос и обновляет список продуктов
    func loadData() async {
        // Показываем индикатор загрузки
        await MainActor.run {
            showProgress = true
        }
        
        let types = await MainActor.run { categoryCurrent.id.isEmpty ? Config.allCategories : [categoryCurrent.id] }
        let currentPage = await MainActor.run { page }
        let currentSortType = await MainActor.run { sortType }
        let currentSortDirection = await MainActor.run { sortDirection }
        let currentSearchText = await MainActor.run { searchText }
        let currentSelectedNutrients = await MainActor.run { selectedNutrients }
        
        foodRepository.loadFoods(
            page: currentPage,
            sortType: currentSortType,
            sortDirection: currentSortDirection,
            types: types,
            search: currentSearchText,
            nutrients: currentSelectedNutrients.map { $0.id }
        )
        .receive(on: DispatchQueue.main)
        .sink(
            receiveCompletion: { [weak self] completion in
                if case .failure(let error) = completion {
                    print("Ошибка загрузки данных: \(error)")
                }
                self?.showProgress = false
            },
            receiveValue: { [weak self] answer in
                self?.foods = answer.food
                self?.count = answer.count
            }
        )
        .store(in: &cancellables)
    }
    
    // MARK: - Private Methods
    
    /// Загружает список доступных нутриентов из локального JSON-файла
    /// Этот метод вызывается при инициализации ViewModel
    private func loadNutrients() {
        // Получаем URL к JSON-файлу с нутриентами в бандле приложения
        guard let url = Bundle.main.url(forResource: "nutrients", withExtension: "json") else { return }
        
        do {
            // Читаем данные из файла
            let data = try Data(contentsOf: url)
            // Декодируем JSON в массив объектов Nutrient
            let decodedNutrients = try jsonDecoder.decode([Nutrient].self, from: data)
            Task { @MainActor in
                self.nutrients = decodedNutrients
            }
        } catch {
            // Выводим ошибку в консоль, если загрузка не удалась
            Task { @MainActor in
                print("Ошибка загрузки нутриентов: \(error)")
            }
        }
    }
}