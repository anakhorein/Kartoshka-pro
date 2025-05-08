import XCTest
@testable import Kartoshka_pro
import Combine

final class ViewModelTests: XCTestCase {
    
    var foodViewModel: FoodViewModel!
    var detailViewModel: DetailViewModel!
    var cancellables: Set<AnyCancellable>!
    
    override func setUp() {
        super.setUp()
        foodViewModel = FoodViewModel()
        let testFood = Food(
            description: "Test Food",
            fdc_id: 12345,
            id: 1,
            nutrientValues: [
                "n2048": 100,
                "n2052": 10,
                "n2053": 5,
                "n2054": 15
            ]
        )
        detailViewModel = DetailViewModel(food: testFood)
        cancellables = Set<AnyCancellable>()
    }
    
    override func tearDown() {
        foodViewModel = nil
        detailViewModel = nil
        cancellables = nil
        super.tearDown()
    }
    
    func testFoodViewModelInitialState() {
        // Then
        XCTAssertTrue(foodViewModel.foods.isEmpty)
        XCTAssertTrue(!foodViewModel.categories.isEmpty)
        XCTAssertFalse(foodViewModel.showProgress)
    }
    
    func testDetailViewModelInitialState() {
        // Then
        XCTAssertNil(detailViewModel.foodItem)
        XCTAssertFalse(detailViewModel.showProgress)
        XCTAssertEqual(detailViewModel.progressValue, 0.0)
        XCTAssertNil(detailViewModel.error)
    }
    
    func testFoodViewModelSearch() {
        // Given
        let searchQuery = "Test"
        
        // When
        foodViewModel.searchText = searchQuery
        
        // Then
        XCTAssertEqual(foodViewModel.searchText, searchQuery)
    }
    
    func testFoodViewModel() {
        // Given
        let food = Food(
            description: "Test Food",
            fdc_id: 12345,
            id: 1,
            nutrientValues: [
                "n2048": 100,
                "n2052": 10,
                "n2053": 5,
                "n2054": 15
            ]
        )
        
        let viewModel = FoodViewModel()
        viewModel.foods = [food]
        
        // When
        let result = viewModel.foods.first
        
        // Then
        XCTAssertNotNil(result)
        XCTAssertEqual(result?.description, "Test Food")
        XCTAssertEqual(result?.fdc_id, 12345)
        XCTAssertEqual(result?.id, 1)
        XCTAssertEqual(result?.nutrientValues["n2048"], 100)
        XCTAssertEqual(result?.nutrientValues["n2052"], 10)
        XCTAssertEqual(result?.nutrientValues["n2053"], 5)
        XCTAssertEqual(result?.nutrientValues["n2054"], 15)
    }
    
    func testFoodItemViewModel() {
        // Given
        let foodItem = FoodItem(
            description: "Test Food Item",
            fdc_id: 54321,
            id: 2,
            nutrientValues: [
                "n1001": 20,
                "n1002": 30,
                "n1003": 40,
                "n1004": 50
            ]
        )
        
        let viewModel = FoodItemViewModel()
        viewModel.foodItems = [foodItem]
        
        // When
        let result = viewModel.foodItems.first
        
        // Then
        XCTAssertNotNil(result)
        XCTAssertEqual(result?.description, "Test Food Item")
        XCTAssertEqual(result?.fdc_id, 54321)
        XCTAssertEqual(result?.id, 2)
        XCTAssertEqual(result?.nutrientValues["n1001"], 20)
        XCTAssertEqual(result?.nutrientValues["n1002"], 30)
        XCTAssertEqual(result?.nutrientValues["n1003"], 40)
        XCTAssertEqual(result?.nutrientValues["n1004"], 50)
    }
} 
