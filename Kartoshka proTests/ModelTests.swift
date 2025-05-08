import XCTest
@testable import Kartoshka_pro

final class ModelTests: XCTestCase {
    
    func testFoodModel() {
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
        
        // Then
        XCTAssertEqual(food.description, "Test Food")
        XCTAssertEqual(food.fdc_id, 12345)
        XCTAssertEqual(food.id, 1)
        XCTAssertEqual(food.nutrientValues["n2048"], 100)
        XCTAssertEqual(food.nutrientValues["n2052"], 10)
        XCTAssertEqual(food.nutrientValues["n2053"], 5)
        XCTAssertEqual(food.nutrientValues["n2054"], 15)
    }
    
    func testFoodItemModel() {
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
        
        // Then
        XCTAssertEqual(foodItem.description, "Test Food Item")
        XCTAssertEqual(foodItem.fdc_id, 54321)
        XCTAssertEqual(foodItem.id, 2)
        XCTAssertEqual(foodItem.nutrientValues["n1001"], 20)
        XCTAssertEqual(foodItem.nutrientValues["n1002"], 30)
        XCTAssertEqual(foodItem.nutrientValues["n1003"], 40)
        XCTAssertEqual(foodItem.nutrientValues["n1004"], 50)
    }
    
    func testNutrientModel() {
        // Given
        let nutrient = Nutrient(
            id: "1001",
            name: "Белок",
            nutrient_nbr: "203",
            rank: "1",
            unit_name: "г"
        )
        
        // Then
        XCTAssertEqual(nutrient.id, "1001")
        XCTAssertEqual(nutrient.name, "Белок")
        XCTAssertEqual(nutrient.nutrient_nbr, "203")
        XCTAssertEqual(nutrient.rank, "1")
        XCTAssertEqual(nutrient.unit_name, "г")
    }
    
    func testCategoryModel() {
        // Given
        let category = Category(
            id: "1",
            title: "Фрукты",
            title_en: "Fruits"
        )
        
        // Then
        XCTAssertEqual(category.id, "1")
        XCTAssertEqual(category.title, "Фрукты")
        XCTAssertEqual(category.title_en, "Fruits")
    }
} 